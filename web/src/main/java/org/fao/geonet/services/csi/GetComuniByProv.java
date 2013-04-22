//=============================================================================
//==============================================================================

package org.fao.geonet.services.csi;


import jeeves.constants.Jeeves;
import jeeves.exceptions.BadParameterEx;
import jeeves.exceptions.MissingParameterEx;
import jeeves.interfaces.Service;
import jeeves.resources.dbms.Dbms;
import jeeves.server.ServiceConfig;
import jeeves.server.context.ServiceContext;
import jeeves.utils.Util;
import org.fao.geonet.constants.Geonet;
import org.jdom.Element;

//=============================================================================

/** 
  */

public class GetComuniByProv implements Service
{
	private ServiceConfig _config;

	//--------------------------------------------------------------------------
	//---
	//--- Init
	//---
	//--------------------------------------------------------------------------

	public void init(String appPath, ServiceConfig config) throws Exception
	{
		_config = config;
	}

	//--------------------------------------------------------------------------
	//---
	//--- Service
	//---
	//--------------------------------------------------------------------------

	public Element exec(Element params, ServiceContext context) throws Exception
	{
//		GeonetContext gc = (GeonetContext) context.getHandlerContext(Geonet.CONTEXT_NAME);

		String ambId      = params.getChildText("ambId");
		String ambCode    = params.getChildText("ambCode");
		String ambName    = params.getChildText("ambName");

        if(ambId == null && ambCode == null && ambName == null)
            throw new MissingParameterEx("ambId or ambCode or ambName", params);

        Dbms dbms = (Dbms) context.getResourceManager().open (Geonet.Res.MAIN_DB);

        Element response;
        if(ambId != null) {
            int id;
            try {
                 id = Integer.parseInt(ambId);
            } catch (NumberFormatException e) {
                throw new BadParameterEx("ambId", ambId);
            }
            response = dbms.select("select c.* from sottoambito c, ambito p where p.id=? and p.code=c.ambCode order by c.label", id);
        } else if (ambCode != null) {
            response = dbms.select("select * from sottoambito where ambCode=? order by label", ambCode);
        } else if (ambName != null) {
            response = dbms.select("select c.* from sottoambito c, ambito p where p.label=? and p.code=c.ambCode order by c.label", ambName);
        } else {
            throw new IllegalStateException();
        }

		response.setName(Jeeves.Elem.RESPONSE);
        return response;
	}
}

//=============================================================================

