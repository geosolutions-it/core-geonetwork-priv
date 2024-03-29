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

package org.fao.geonet.kernel.oaipmh.services;

import jeeves.resources.dbms.Dbms;
import jeeves.server.context.ServiceContext;
import jeeves.utils.Xml;
import org.fao.geonet.constants.Geonet;
import org.fao.geonet.kernel.oaipmh.Lib;
import org.fao.geonet.kernel.oaipmh.ResumptionTokenCache;
import org.fao.oaipmh.OaiPmh;
import org.fao.oaipmh.requests.ListRecordsRequest;
import org.fao.oaipmh.requests.TokenListRequest;
import org.fao.oaipmh.responses.Header;
import org.fao.oaipmh.responses.ListRecordsResponse;
import org.fao.oaipmh.responses.Record;
import org.fao.oaipmh.util.ISODate;
import org.fao.oaipmh.util.SearchResult;
import org.jdom.Element;

import java.util.List;

//=============================================================================

public class ListRecords extends AbstractTokenLister
{


	public ListRecords(ResumptionTokenCache cache,int mode) {
	    super(cache,mode);
	}

	public String getVerb() { return ListRecordsRequest.VERB; }

	//---------------------------------------------------------------------------
	//---
	//--- Service
	//---
	//---------------------------------------------------------------------------




	public ListRecordsResponse processRequest(TokenListRequest req, int pos, SearchResult result, ServiceContext context) throws Exception  {
	 
		int num = 0;
		ListRecordsResponse res = new ListRecordsResponse();

		//--- loop to retrieve metadata

		while (num<Lib.MAX_RECORDS && pos < result.ids.size())
		{
			int id = result.ids.get(pos);

			Record r = buildRecord(context, id, result.prefix);

			if (r != null)
			{
				res.addRecord(r);
				num++;
			}

			pos++;
		}

		return res;

	}

	//---------------------------------------------------------------------------
	//---
	//--- Private methods
	//---
	//---------------------------------------------------------------------------

	private Record buildRecord(ServiceContext context, int id, String prefix) throws Exception
	{
		Dbms dbms = (Dbms) context.getResourceManager().open(Geonet.Res.MAIN_DB);

		String query = "SELECT uuid, schemaId, changeDate, data FROM Metadata WHERE id=?";

		List list = dbms.select(query, id).getChildren();

		//--- maybe the metadata has been removed

		if (list.size() == 0)
			return null;

		Element rec = (Element) list.get(0);

		String uuid       = rec.getChildText("uuid");
		String schema     = rec.getChildText("schemaid");
		String changeDate = rec.getChildText("changedate");
		String data       = rec.getChildText("data");

		Element md = Xml.loadString(data, false);

		//--- try to disseminate format

		if (prefix.equals(schema)) {
			String schemaUrl = Lib.getSchemaUrl(context, "xml/schemas/" + schema + "/schema.xsd");
			String schemaLoc = md.getNamespace().getURI() +" "+ schemaUrl;
			md.setAttribute("schemaLocation", schemaLoc, OaiPmh.Namespaces.XSI);
		} else {
			if (Lib.existsConverter(schema, context.getAppPath(), prefix)) {
				md = Lib.transform(schema, md, uuid, changeDate, context.getAppPath(), prefix);
			} else {
				return null;
			}
		}

		//--- build header and set some infos

		Header h = new Header();

		h.setIdentifier(uuid);
		h.setDateStamp(new ISODate(changeDate));

		//--- find and add categories (here called sets)

		query = "SELECT name FROM Categories, MetadataCateg WHERE id=categoryId AND metadataId=?";

		list = dbms.select(query, id).getChildren();

		for (Object o : list)
		{
			rec = (Element) o;

			h.addSet(rec.getChildText("name"));
		}

		//--- build and return record

		Record r = new Record();

		r.setHeader(h);
		r.setMetadata(md);

		return r;
	}
}

//=============================================================================

