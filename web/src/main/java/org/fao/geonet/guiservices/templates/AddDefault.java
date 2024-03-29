//=============================================================================
//===	Copyright (C) 2010 Food and Agriculture Organization of the
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

package org.fao.geonet.guiservices.templates;

import jeeves.constants.Jeeves;
import jeeves.interfaces.Service;
import jeeves.resources.dbms.Dbms;
import jeeves.server.ServiceConfig;
import jeeves.server.context.ServiceContext;
import jeeves.utils.Log;
import jeeves.utils.Util;
import jeeves.utils.Xml;
import org.fao.geonet.GeonetContext;
import org.fao.geonet.constants.Geonet;
import org.fao.geonet.constants.Params;
import org.fao.geonet.kernel.DataManager;
import org.jdom.Element;

import java.io.File;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;
import java.util.UUID;

/**
 * A simple service that add all metadata templates available in templates
 * directory.
 * 
 */
public class AddDefault implements Service {
	String templateDirectoryPath;

	public void init(String appPath, ServiceConfig params) throws Exception {
		templateDirectoryPath = appPath + "/WEB-INF/classes/setup/templates";
	}

	/**
	 * 
	 * schemaList is a list of comma separated schemas to load, if null will
	 * load all schema.
	 * 
	 * @return A report on the template import with information about the status
	 *         of the insertion operation (failed|loaded).
	 */
	public Element exec(Element params, ServiceContext context)
			throws Exception {

		String schemaList = Util.getParam(params, Params.SCHEMA, "");
		String serviceStatus = "true";
		
		Element result = new Element(Jeeves.Elem.RESPONSE);
		GeonetContext gc = (GeonetContext) context
				.getHandlerContext(Geonet.CONTEXT_NAME);
		Dbms dbms = (Dbms) context.getResourceManager()
				.open(Geonet.Res.MAIN_DB);

		DataManager dataMan = gc.getDataManager();

		String siteId = gc.getSiteId();
        int owner = context.getUserSession().getUserIdAsInt();

        Log.info(Geonet.DATA_MANAGER, "Loading default templates");
		List<File> schemaDirectoriesList = new ArrayList<File>();
		File templateDirectory = new File(templateDirectoryPath);
		File schemaDirectories[] = templateDirectory.listFiles();

		if (schemaDirectories != null)
            schemaDirectoriesList.addAll(Arrays.asList(schemaDirectories));

		for (File schemaDir : schemaDirectories) {
			String schemaName = schemaDir.getName();

			// --- skip '.svn' folders and other hidden files
			if (!schemaName.startsWith(".")
					&& (schemaList.indexOf(schemaName) != -1 || "".equals(schemaList))
			) {
				Element schema = new Element(schemaName);

				File templateFiles[] = schemaDir.listFiles();
				List<File> templateFilesList = new ArrayList<File>();

				if (templateFiles != null) {
					for (File file : templateFiles)
						if (file.getName().endsWith(".xml"))
							templateFilesList.add(file);
				}

				for (File temp : templateFilesList) {
					String status = "failed";
					String templateName = temp.getName();
					
					Element template = new Element("template");
					template.setAttribute("name", templateName);
					
					
					Log.debug(Geonet.DATA_MANAGER,
							" - Adding template file (for schema " + schemaName
									+ "): " + templateName);

					try {
						Element xml = Xml.loadFile(temp);
						String uuid = UUID.randomUUID().toString();
						String isTemplate = "y";
						String title = null;

						if (templateName.startsWith("sub-")) {
							isTemplate = "s";
							title = templateName.substring(4, templateName
									.length() - 4);
						}
						dataMan.insertMetadata(dbms, schemaName, null, "1",
								xml, context.getSerialFactory(), siteId, uuid,
								isTemplate, title, owner);

						dbms.commit();
						status = "loaded";
					} catch (Exception e) {
						serviceStatus = "false";
						Log.error(Geonet.DATA_MANAGER,
								"Error loading template: " + e.getMessage());
					}
					template.setAttribute("status", status);
					schema.addContent(template);
				}
				result.addContent(schema);
			}
		}
		result.setAttribute("status", serviceStatus);
		return result;
	}
}