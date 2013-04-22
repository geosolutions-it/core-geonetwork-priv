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

public class GetProvincia implements Service
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

		String sid      = params.getChildText("id");
		String code    = params.getChildText("code");

        if(sid == null && code ==null)
            throw new MissingParameterEx("either id or code", params);

        Dbms dbms = (Dbms) context.getResourceManager().open (Geonet.Res.MAIN_DB);

        Element response;
        if(sid != null) {
            int id;
            try {
                 id = Integer.parseInt(sid);
            } catch (NumberFormatException e) {
                throw new BadParameterEx("id", sid);
            }
            response = dbms.select("select * from ambito where id=?", id);
        } else if (code != null) {
            response = dbms.select("select * from ambito where code=?", code);
        } else {
            throw new IllegalStateException();
        }

		response.setName(Jeeves.Elem.RESPONSE);
        return response;
	}
}

//=============================================================================

