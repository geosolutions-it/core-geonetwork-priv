//===	Copyright (C) 2001-2005 Food and Agriculture Organization of the
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
//===	Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
//===
//===	Contact: Jeroen Ticheler - FAO - Viale delle Terme di Caracalla 2,
//===	Rome - Italy. email: GeoNetwork@fao.org
//==============================================================================

package org.fao.geonet.services.thesaurus;

import jeeves.constants.Jeeves;
import jeeves.interfaces.Service;
import jeeves.server.ServiceConfig;
import jeeves.server.UserSession;
import jeeves.server.context.ServiceContext;
import jeeves.utils.Util;
import org.fao.geonet.constants.Geonet;
import org.fao.geonet.kernel.search.KeywordsSearcher;
import org.jdom.Element;

/**
 * Sort the list of keywords stored in session and
 * Returns a list of keywords 
 */

public class SortKeywords implements Service {
	public void init(String appPath, ServiceConfig params) throws Exception {
	}

	// --------------------------------------------------------------------------
	// ---
	// --- Service
	// ---
	// --------------------------------------------------------------------------

	public Element exec(Element params, ServiceContext context)
			throws Exception {

		Element response = new Element(Jeeves.Elem.RESPONSE);
		UserSession session = context.getUserSession();
		KeywordsSearcher searcher = (KeywordsSearcher)session.getProperty(Geonet.Session.SEARCH_KEYWORDS_RESULT);

		searcher.sortResults(Util.getParam(params, "pSort"));
		
		// get the results
		response.addContent(searcher.getResults());

		
		// If editing or consult thesaurus 
		if (params.getChild("pMode") != null) {
			String mode = Util.getParam(params, "pMode");
			if (mode.equals("edit") || mode.equals("consult")) {
				String thesaurus = Util.getParam(params, "pThesauri","");
				response.addContent(new Element("thesaurus")
						.addContent(thesaurus));
				response.addContent((new Element("mode")).addContent(mode));
			}
		}		
		
		return response;
	}
}

// =============================================================================

