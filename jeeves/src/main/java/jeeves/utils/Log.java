//=============================================================================
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

package jeeves.utils;

import org.apache.log4j.Logger;

//=============================================================================

public class Log
{
	//---------------------------------------------------------------------------
	//--- Logging constants
	//---------------------------------------------------------------------------

	public static final String JEEVES  = "jeeves";

	public static final String ENGINE    = JEEVES+ ".engine";
	public static final String APPHAND   = JEEVES+ ".apphand";
	public static final String WEBAPP    = JEEVES+ ".webapp";
	public static final String REQUEST   = JEEVES+ ".request";
	public static final String SERVICE   = JEEVES+ ".service";
	public static final String SCHEDULER = JEEVES+ ".scheduler";
	public static final String RESOURCES = JEEVES+ ".resources";
	public static final String DBMS      = JEEVES+ ".dbms";
	public static final String DBMSPOOL	 = JEEVES+ ".dbmspool";
	public static final String XLINK_PROCESSOR = JEEVES+ ".xlinkprocessor";

	public class Dbms
	{
		public static final String SELECT = DBMS  + ".select";
		public static final String EXECUTE= DBMS  + ".execute";
	}

	//---------------------------------------------------------------------------
	//---
	//--- API methods
	//---
	//---------------------------------------------------------------------------

	public static void debug(String module, Object message)
	{
		Logger.getLogger(module).debug(message);
	}

	//---------------------------------------------------------------------------

	public static void info(String module, Object message)
	{
		Logger.getLogger(module).info(message);
	}

	//---------------------------------------------------------------------------

	public static void warning(String module, Object message)
	{
		Logger.getLogger(module).warn(message);
	}

	//---------------------------------------------------------------------------

	public static void error(String module, Object message)
	{
		Logger.getLogger(module).error(message);
	}

	//---------------------------------------------------------------------------

	public static void fatal(String module, Object message)
	{
		Logger.getLogger(module).fatal(message);
	}

	//--------------------------------------------------------------------------
	/** Returns a simple logger object */

	public static jeeves.interfaces.Logger createLogger(final String module)
	{
		return new jeeves.interfaces.Logger()
		{
			public void debug  (String message) { Log.debug  (module, message); }
			public void info   (String message) { Log.info   (module, message); }
			public void warning(String message) { Log.warning(module, message); }
			public void error  (String message) { Log.error  (module, message); }
			public void fatal  (String message) { Log.fatal  (module, message); }
		};
	}
}

//=============================================================================

