//=============================================================================
//===	Copyright (C) 2001-2005 Food and Agriculture Organization of the
//===	United Nations (FAO-UN), United Nations World Food Programme (WFP)
//===	and United Nations Environment Programme (UNEP)
//===
//===	This library is free software; you can redistribute it and/or
//===	modify it under the terms of the GNU Lesser General Public
//===	License as published by the Free Software Foundation; either
//===	version 2.1 of the License, or (at your option) any later version.
//===
//===	This library is distributed in the hope that it will be useful,
//===	but WITHOUT ANY WARRANTY; without even the implied warranty of
//===	MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
//===	Lesser General Public License for more details.
//===
//===	You should have received a copy of the GNU Lesser General Public
//===	License along with this library; if not, write to the Free Software
//===	Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
//===
//===	Contact: Jeroen Ticheler - FAO - Viale delle Terme di Caracalla 2,
//===	Rome - Italy. email: GeoNetwork@fao.org
//==============================================================================

package jeeves.server.context;

import java.util.Hashtable;
import jeeves.interfaces.Logger;
import jeeves.server.resources.ProviderManager;
import jeeves.server.resources.ResourceManager;
import jeeves.server.resources.ResourceProvider;
import jeeves.utils.SerialFactory;

//=============================================================================

/** Contains a minimun context for a job execution (schedule, service etc...)
  */

public class BasicContext
{
	private ResourceManager resMan;
	private ProviderManager provMan;
	private SerialFactory   serialFact;

	protected Logger logger;
	private   String baseUrl;
	private   String appPath;

	private Hashtable htContexts;

	//--------------------------------------------------------------------------
	//---
	//--- Constructor
	//---
	//--------------------------------------------------------------------------

	public BasicContext(ProviderManager pm, SerialFactory sf, Hashtable contexts)
	{
		resMan = new ResourceManager(pm);

		provMan    = pm;
		serialFact = sf;
		htContexts = contexts;
	}

	//--------------------------------------------------------------------------
	//---
	//--- API methods
	//---
	//--------------------------------------------------------------------------

	//--- readonly objects

	public ResourceManager getResourceManager() { return resMan;     }
	public SerialFactory   getSerialFactory()   { return serialFact; }

	//--- read/write objects

	public Logger getLogger()  { return logger;  }
	public String getBaseUrl() { return baseUrl; }
	public String getAppPath() { return appPath; }

	//--------------------------------------------------------------------------

	public void setBaseUrl(String name) { baseUrl = name; }
	public void setAppPath(String path) { appPath = path; }

	//--------------------------------------------------------------------------

	public Object getHandlerContext(String contextName)
	{
		return htContexts.get(contextName);
	}

	//--------------------------------------------------------------------------

	public ProviderManager getProviderManager()
	{
		return provMan;
	}

	//--------------------------------------------------------------------------

	public void debug  (String message) { logger.debug  (message); }
	public void info   (String message) { logger.info   (message); }
	public void warning(String message) { logger.warning(message); }
	public void error  (String message) { logger.error  (message); }
}

//=============================================================================

