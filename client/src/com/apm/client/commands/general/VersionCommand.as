/**
 *        __       __               __
 *   ____/ /_ ____/ /______ _ ___  / /_
 *  / __  / / ___/ __/ ___/ / __ `/ __/
 * / /_/ / (__  ) / / /  / / /_/ / /
 * \__,_/_/____/_/ /_/  /_/\__, /_/
 *                           / /
 *                           \/
 * http://distriqt.com
 *
 * @author 		Michael (https://github.com/marchbold)
 * @created		18/5/21
 */
package com.apm.client.commands.general
{
	import com.apm.SemVer;
	import com.apm.client.APMCore;
	import com.apm.client.Consts;
	import com.apm.client.IO;
	import com.apm.client.commands.Command;
	
	
	public class VersionCommand implements Command
	{
		
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "VersionCommand";
		
		
		public static const NAME:String = "version";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _parameters:Array;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function VersionCommand()
		{
			super();
		}
		
		
		public function setParameters( parameters:Array ):void
		{
			_parameters = parameters;
		}
		
		
		public function get name():String
		{
			return NAME;
		}
		
		
		public function get category():String
		{
			return "";
		}
		
		
		public function get requiresNetwork():Boolean
		{
			return false;
		}
		
		
		public function get description():String
		{
			return "print apm version information";
		}
		
		
		public function get usage():String
		{
			return description + " \n" +
					"\n" +
					"apm -v          print the basic apm version number \n" +
					"apm version     print the version information about apm";
		}
		
		
		public function execute( core:APMCore ):void
		{
			core.io.writeLine( "apm: v" + new SemVer( Consts.VERSION ).toString() );
			core.exit( APMCore.CODE_OK );
		}
		
		
	}
	
}
