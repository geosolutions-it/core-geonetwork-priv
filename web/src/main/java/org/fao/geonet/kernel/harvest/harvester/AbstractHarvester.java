//=============================================================================
//===	Copyright (C) 2001-2007 Food and Agriculture Organization of the
//===	United Nations (FAO-UN), United Nations World Food Programme (WFP)
//===	and United Nations Environment Programme (UNEP)
//===
//===	This program is free software; you can redistribute it and/or modify
//===	it under the terms of the GNU General Public License as published by
//===	the Free Software Foundation; either version 2 of the License, or (at
//===	your option) any later version.
//===
//===	This program is distributed in the hope that it will be useful, but
//===	WITHOUT ANY WARRANTY; without even the implied warranty of
//===	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
//===	General Public License for more details.
//===
//===	You should have received a copy of the GNU General Public License
//===	along with this program; if not, write to the Free Software
//===	Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301, USA
//===
//===	Contact: Jeroen Ticheler - FAO - Viale delle Terme di Caracalla 2,
//===	Rome - Italy. email: geonetwork@osgeo.org
//==============================================================================

package org.fao.geonet.kernel.harvest.harvester;

import jeeves.exceptions.BadInputEx;
import jeeves.exceptions.BadParameterEx;
import jeeves.exceptions.JeevesException;
import jeeves.exceptions.OperationAbortedEx;
import jeeves.interfaces.Logger;
import jeeves.resources.dbms.Dbms;
import jeeves.server.context.ServiceContext;
import jeeves.server.resources.ResourceManager;
import jeeves.utils.Log;
import org.fao.geonet.constants.Geonet;
import org.fao.geonet.kernel.DataManager;
import org.fao.geonet.kernel.MetadataIndexerProcessor;
import org.fao.geonet.kernel.harvest.Common.OperResult;
import org.fao.geonet.kernel.harvest.Common.Status;
import org.fao.geonet.kernel.harvest.harvester.arcsde.ArcSDEHarvester;
import org.fao.geonet.kernel.harvest.harvester.csw.CswHarvester;
import org.fao.geonet.kernel.harvest.harvester.geonet.GeonetHarvester;
import org.fao.geonet.kernel.harvest.harvester.geonet20.Geonet20Harvester;
import org.fao.geonet.kernel.harvest.harvester.localfilesystem.LocalFilesystemHarvester;
import org.fao.geonet.kernel.harvest.harvester.metadatafragments.MetadataFragmentsHarvester;
import org.fao.geonet.kernel.harvest.harvester.oaipmh.OaiPmhHarvester;
import org.fao.geonet.kernel.harvest.harvester.ogcwxs.OgcWxSHarvester;
import org.fao.geonet.kernel.harvest.harvester.thredds.ThreddsHarvester;
import org.fao.geonet.kernel.harvest.harvester.webdav.WebDavHarvester;
import org.fao.geonet.kernel.harvest.harvester.z3950.Z3950Harvester;
import org.fao.geonet.kernel.setting.SettingManager;
import org.fao.geonet.util.ISODate;
import org.jdom.Element;

import java.lang.reflect.Method;
import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;

//=============================================================================

public abstract class AbstractHarvester
{
	//---------------------------------------------------------------------------
	//---
	//--- Static API methods
	//---
	//---------------------------------------------------------------------------

	public static void staticInit(ServiceContext context) throws Exception
	{
		register(context, GeonetHarvester  .class);
		register(context, Geonet20Harvester.class);
		register(context, WebDavHarvester  .class);
		register(context, CswHarvester     .class);
		register(context, Z3950Harvester   .class);
		register(context, OaiPmhHarvester  .class);
		register(context, OgcWxSHarvester  .class);
		register(context, ThreddsHarvester .class);
		register(context, ArcSDEHarvester  .class);
		register(context, LocalFilesystemHarvester	.class);
		register(context, MetadataFragmentsHarvester  .class);
		register(context, LocalFilesystemHarvester      .class);
	}

	//---------------------------------------------------------------------------

	private static void register(ServiceContext context, Class harvester) throws Exception
	{
		try
		{
			Method initMethod = harvester.getMethod("init", context.getClass());
			initMethod.invoke(null, context);

			AbstractHarvester ah = (AbstractHarvester) harvester.newInstance();

			hsHarvesters.put(ah.getType(), harvester);
		}
		catch(Exception e)
		{
			throw new Exception("Cannot register harvester : "+harvester, e);
		}
	}

	//---------------------------------------------------------------------------

	public static AbstractHarvester create(String type, ServiceContext context,
														SettingManager sm, DataManager dm)
														throws BadParameterEx, OperationAbortedEx
	{
		//--- raises an exception if type is null

		if (type == null)
			throw new BadParameterEx("type", type);

		Class c = hsHarvesters.get(type);

		if (c == null)
			throw new BadParameterEx("type", type);

		try
		{
			AbstractHarvester ah = (AbstractHarvester) c.newInstance();

			ah.context    = context;
			ah.settingMan = sm;
			ah.dataMan    = dm;

			return ah;
		}
		catch(Exception e)
		{
			throw new OperationAbortedEx("Cannot instantiate harvester", e);
		}
	}

	//--------------------------------------------------------------------------
	//---
	//--- API methods
	//---
	//--------------------------------------------------------------------------

	public void add(Dbms dbms, Element node) throws BadInputEx, SQLException
	{
		status   = Status.INACTIVE;
		executor = null;
		error    = null;
		id       = doAdd(dbms, node);
	}

	//--------------------------------------------------------------------------

	public void init(Element node) throws BadInputEx
	{
		id       = node.getAttributeValue("id");
		status   = Status.parse(node.getChild("options").getChildText("status"));
		executor = null;
		error    = null;

		//--- init harvester

		doInit(node);

		if (status == Status.ACTIVE)
		{
			executor = new Executor(this);
			executor.setTimeout(getParams().every);
			executor.start();
		}
	}

	//--------------------------------------------------------------------------
	/** Called when the application is shutdown */

	public void shutdown()
	{
		if (executor != null)
			executor.terminate();
	}

	//--------------------------------------------------------------------------
	/** Called when the harvesting entry is removed from the system.
	  * It is used to remove harvested metadata.
	  */

	public synchronized void destroy(Dbms dbms) throws Exception
	{
		if (executor != null)
			executor.terminate();

		executor = null;

		//--- remove all harvested metadata

		String getQuery = "SELECT id FROM Metadata WHERE harvestUuid=?";

		for (Object o : dbms.select(getQuery, getParams().uuid).getChildren())
		{
			Element el = (Element) o;
			String  id = el.getChildText("id");

			dataMan.deleteMetadata(dbms, id);
			dbms.commit();
		}

		doDestroy(dbms);
	}

	//--------------------------------------------------------------------------

	public synchronized OperResult start(Dbms dbms) throws SQLException
	{
		if (status != Status.INACTIVE)
			return OperResult.ALREADY_ACTIVE;

		settingMan.setValue(dbms, "harvesting/id:"+id+"/options/status", Status.ACTIVE);

		status     = Status.ACTIVE;
		error      = null;
		executor   = new Executor(this);
		executor.setTimeout(getParams().every);
		executor.start();

		return OperResult.OK;
	}

	//--------------------------------------------------------------------------

	public synchronized OperResult stop(Dbms dbms) throws SQLException
	{
		if (status != Status.ACTIVE)
			return OperResult.ALREADY_INACTIVE;

		settingMan.setValue(dbms, "harvesting/id:"+id+"/options/status", Status.INACTIVE);

		executor.terminate();
		status   = Status.INACTIVE;
		executor = null;

		return OperResult.OK;
	}

	//--------------------------------------------------------------------------

	public synchronized OperResult run(Dbms dbms) throws SQLException {
		if (status == Status.INACTIVE)
			start(dbms);

		if (executor.isRunning())
			return OperResult.ALREADY_RUNNING;

		executor.interrupt();

		return OperResult.OK;
	}

	//--------------------------------------------------------------------------

	public synchronized OperResult invoke(ResourceManager rm)
	{
		// Cannot do invoke if this harvester was started (iei active)
		if (status != Status.INACTIVE)
			return OperResult.ALREADY_ACTIVE;

		Logger logger = Log.createLogger(Geonet.HARVESTER);
		String nodeName = getParams().name +" ("+ getClass().getSimpleName() +")";
		OperResult result = OperResult.OK;

		try
		{
			status = Status.ACTIVE;
			logger.info("Started harvesting from node : "+ nodeName);
			doHarvest(logger, rm);
			logger.info("Ended harvesting from node : "+ nodeName);

			rm.close();
		}
		catch(Throwable t)
		{
			result = OperResult.ERROR;
			logger.warning("Raised exception while harvesting from : "+ nodeName);
			logger.warning(" (C) Class   : "+ t.getClass().getSimpleName());
			logger.warning(" (C) Message : "+ t.getMessage());
			error = t;
			t.printStackTrace();

			try
			{
				rm.abort();
			}
			catch (Exception ex)
			{
				logger.warning("CANNOT ABORT EXCEPTION");
				logger.warning(" (C) Exc : "+ ex);
			}
		} finally {
			status = Status.INACTIVE;
		}

		return result;
	}

	//--------------------------------------------------------------------------

	public synchronized void update(Dbms dbms, Element node) throws BadInputEx, SQLException
	{
		doUpdate(dbms, id, node);

		if (status == Status.ACTIVE)
		{
			//--- stop executor
			executor.terminate();

			//--- restart executor
			error      = null;
			executor   = new Executor(this);
			executor.setTimeout(getParams().every);
			executor.start();
		}
	}

	//--------------------------------------------------------------------------

	public String getID() { return id; }

	//--------------------------------------------------------------------------
	/** Adds harvesting result information to each harvesting entry */

	public void addInfo(Element node)
	{
		Element info = node.getChild("info");

		//--- 'running'

		boolean running = false;
		if (status != null && executor != null) {
			running = (status == Status.ACTIVE && executor.isRunning());
		}
		info.addContent(new Element("running").setText(running+""));

		//--- harvester specific info

		doAddInfo(node);

		//--- add error information

		if (error != null)
			node.addContent(JeevesException.toElement(error));
	}

	//---------------------------------------------------------------------------
	/** Adds harvesting information to each metadata element. Some sites can generate
	  * url for thumbnails */

	public void addHarvestInfo(Element info, String id, String uuid)
	{
		info.addContent(new Element("type").setText(getType()));
	}

	//---------------------------------------------------------------------------
	//---
	//--- Package methods (called by Executor)
	//---
	//---------------------------------------------------------------------------

	// Nested class to handle harvesting with fast indexing
	public class HarvestWithIndexProcessor extends MetadataIndexerProcessor {
		ResourceManager rm;
		Logger logger;

		public HarvestWithIndexProcessor(DataManager dm, Logger logger, ResourceManager rm) {
			super(dm);
			this.logger = logger;
			this.rm = rm;
		}

		@Override
		public void process() throws Exception {
			doHarvest(logger, rm);
		}
	}

	void harvest()
	{
		ResourceManager rm = new ResourceManager(context.getProviderManager());

		Logger logger = Log.createLogger(Geonet.HARVESTER);
		
		String nodeName = getParams().name +" ("+ getClass().getSimpleName() +")";

		error = null;

		try
		{
			Dbms dbms = (Dbms) rm.open(Geonet.Res.MAIN_DB);

			//--- update lastRun

			String lastRun = new ISODate(System.currentTimeMillis()).toString();
			settingMan.setValue(dbms, "harvesting/id:"+ id +"/info/lastRun", lastRun);

			//--- proper harvesting

			logger.info("Started harvesting from node : "+ nodeName);
			HarvestWithIndexProcessor h = new HarvestWithIndexProcessor(dataMan, logger, rm);
			h.processWithFastIndexing();
			logger.info("Ended harvesting from node : "+ nodeName);

			if (getParams().oneRunOnly)
				stop(dbms);

			rm.close();
		}
		catch(Throwable t)
		{
			logger.warning("Raised exception while harvesting from : "+ nodeName);
			logger.warning(" (C) Class   : "+ t.getClass().getSimpleName());
			logger.warning(" (C) Message : "+ t.getMessage());

			error = t;
			t.printStackTrace();

			try
			{
				rm.abort();
			}
			catch (Exception ex)
			{
				logger.warning("CANNOT ABORT EXCEPTION");
				logger.warning(" (C) Exc : "+ ex);
			}
		}
	}

	//---------------------------------------------------------------------------
	//---
	//--- Abstract methods that must be overridden
	//---
	//---------------------------------------------------------------------------

	public abstract String getType();

	public abstract AbstractParams getParams();

	protected abstract void doInit(Element entry) throws BadInputEx;

	protected abstract void doDestroy(Dbms dbms) throws SQLException;

	protected abstract String doAdd(Dbms dbms, Element node)
											throws BadInputEx, SQLException;

	protected abstract void doUpdate(Dbms dbms, String id, Element node)
											throws BadInputEx, SQLException;

	protected abstract void doAddInfo(Element node);
	protected abstract void doHarvest(Logger l, ResourceManager rm) throws Exception;

	//---------------------------------------------------------------------------
	//---
	//--- Protected storage methods
	//---
	//---------------------------------------------------------------------------

	protected void storeNode(Dbms dbms, AbstractParams params, String path) throws SQLException
	{
		String siteId    = settingMan.add(dbms, path, "site",    "");
		String optionsId = settingMan.add(dbms, path, "options", "");
		String infoId    = settingMan.add(dbms, path, "info",    "");
		String contentId = settingMan.add(dbms, path, "content", "");

		//--- setup site node ----------------------------------------

		settingMan.add(dbms, "id:"+siteId, "name",     params.name);
		settingMan.add(dbms, "id:"+siteId, "uuid",     params.uuid);

		String useAccId = settingMan.add(dbms, "id:"+siteId, "useAccount", params.useAccount);

		settingMan.add(dbms, "id:"+useAccId, "username", params.username);
		settingMan.add(dbms, "id:"+useAccId, "password", params.password);

		//--- setup options node ---------------------------------------

		settingMan.add(dbms, "id:"+optionsId, "every",      params.every);
		settingMan.add(dbms, "id:"+optionsId, "oneRunOnly", params.oneRunOnly);
		settingMan.add(dbms, "id:"+optionsId, "status",     status);

		//--- setup content node ---------------------------------------

		settingMan.add(dbms, "id:"+contentId, "importxslt", params.importXslt);
		settingMan.add(dbms, "id:"+contentId, "validate",   params.validate);

		//--- setup stats node ----------------------------------------

		settingMan.add(dbms, "id:"+infoId, "lastRun", "");

		//--- store privileges and categories ------------------------

		storePrivileges(dbms, params, path);
		storeCategories(dbms, params, path);

		storeNodeExtra(dbms, params, path, siteId, optionsId);
	}

	//---------------------------------------------------------------------------
	/** Override this method with an empty body to avoid privileges storage */

	protected void storePrivileges(Dbms dbms, AbstractParams params, String path) throws SQLException
	{
		String privId = settingMan.add(dbms, path, "privileges", "");

		for (Privileges p : params.getPrivileges())
		{
			String groupId = settingMan.add(dbms, "id:"+ privId, "group", p.getGroupId());

			for (int oper : p.getOperations())
				settingMan.add(dbms, "id:"+ groupId, "operation", oper);
		}
	}

	//---------------------------------------------------------------------------
	/** Override this method with an empty body to avoid categories storage */

	protected void storeCategories(Dbms dbms, AbstractParams params, String path) throws SQLException
	{
		String categId = settingMan.add(dbms, path, "categories", "");

		for (String id : params.getCategories())
			settingMan.add(dbms, "id:"+ categId, "category", id);
	}

	//---------------------------------------------------------------------------
	/** Override this method to store harvesting node's specific settings */

	protected void storeNodeExtra(Dbms dbms, AbstractParams params, String path,
											String siteId, String optionsId) throws SQLException {}

	//---------------------------------------------------------------------------

	protected void setValue(Map<String, Object> values, String path, Element el, String name)
	{
		if (el == null)
			return ;

		String value = el.getChildText(name);

		if (value != null)
			values.put(path, value);
	}

	//---------------------------------------------------------------------------

	protected void add(Element el, String name, int value)
	{
		el.addContent(new Element(name).setText(Integer.toString(value)));
	}

	//--------------------------------------------------------------------------
	//---
	//--- Variables
	//---
	//--------------------------------------------------------------------------

	private String id;
	private Status status;

	private Executor  executor;
	private Throwable error;

	protected ServiceContext context;
	protected SettingManager settingMan;
	protected DataManager    dataMan;

	private static Map<String, Class> hsHarvesters = new HashMap<String, Class>();
}

//=============================================================================


