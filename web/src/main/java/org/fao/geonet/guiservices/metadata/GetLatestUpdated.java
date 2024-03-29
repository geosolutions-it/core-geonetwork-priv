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

package org.fao.geonet.guiservices.metadata;

import java.util.List;

import jeeves.constants.Jeeves;
import jeeves.interfaces.Service;
import jeeves.resources.dbms.Dbms;
import jeeves.server.ServiceConfig;
import jeeves.server.context.ServiceContext;
import jeeves.utils.Log;
import jeeves.utils.Xml;

import org.fao.geonet.GeonetContext;
import org.fao.geonet.constants.Geonet;
import org.fao.geonet.kernel.DataManager;
import org.fao.geonet.kernel.search.LuceneSearcher;
import org.fao.geonet.kernel.search.MetaSearcher;
import org.fao.geonet.kernel.search.SearchManager;

import org.jdom.Element;

//=============================================================================

/** Service used to return most recently updated records using Lucene
  */

public class GetLatestUpdated implements Service
{
	private int      			 _maxItems;
	private long    			 _timeBetweenUpdates;

	private Element        _response;
	private long    			 _lastUpdateTime;

	private ServiceConfig  _config;

	//--------------------------------------------------------------------------
	//---
	//--- Init
	//---
	//--------------------------------------------------------------------------

	public void init(String appPath, ServiceConfig config) throws Exception
	{
		String sMaxItems           = config.getValue("maxItems",           "10");
		String sTimeBetweenUpdates = config.getValue("timeBetweenUpdates", "60");
		_timeBetweenUpdates = Integer.parseInt(sTimeBetweenUpdates) * 1000;
		_maxItems           = Integer.parseInt(sMaxItems);
		_config             = config;
	}

	//--------------------------------------------------------------------------
	//---
	//--- Service
	//---
	//--------------------------------------------------------------------------

	public Element exec(Element params, ServiceContext context) throws Exception
	{

		 Element _request = new Element(Jeeves.Elem.REQUEST);
		_request.addContent(new Element("query").setText(""));
		_request.addContent(new Element("sortBy").setText("changeDate"));
		_request.addContent(new Element("from").setText("1"));
		_request.addContent(new Element("to")  .setText(""));

		if (System.currentTimeMillis() > _lastUpdateTime + _timeBetweenUpdates)
		{
			GeonetContext gc = (GeonetContext) context.getHandlerContext(Geonet.CONTEXT_NAME);
			SearchManager searchMan = gc.getSearchmanager();
			DataManager dataMan = gc.getDataManager();
			Dbms dbms = (Dbms) context.getResourceManager().open(Geonet.Res.MAIN_DB);

			_request.getChild("to").setText(""+_maxItems);

			_response = new Element(Jeeves.Elem.RESPONSE);

			// perform the search and return the results read from the index
			MetaSearcher searcher = searchMan.newSearcher(SearchManager.LUCENE, Geonet.File.SEARCH_LUCENE);
			searcher.search(context, _request, _config);
			List<String> uuids = ((LuceneSearcher)searcher).getAllUuids(_maxItems);
			for (String uuid : uuids) {
				try {
					String id = dataMan.getMetadataId(dbms, uuid);
					boolean forEditing = false;
					boolean withValidationErrors = false;
					boolean keepXlinkAttributes = false;
					Element md = dataMan.getMetadata(context, id, forEditing, withValidationErrors);
					_response.addContent(md);
				} catch (Exception e) {
					Log.error(Geonet.SEARCH_ENGINE, "Exception in latest update searcher "+e.getMessage());
					e.printStackTrace();
				}
			}

			_lastUpdateTime = System.currentTimeMillis();
		}

		return (Element)_response.clone();
	}
}

//=============================================================================

