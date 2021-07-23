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
	import com.apm.client.APMCore;
	import com.apm.client.commands.Command;
	
	
	public class HelpCommand implements Command
	{
		
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "HelpCommand";
		
		
		public static const NAME:String = "help";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _parameters:Array;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function HelpCommand()
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
		
		
		public function get requiresProject():Boolean
		{
			return false;
		}
		
		
		public function get description():String
		{
			return "print apm usage information";
		}
		
		
		public function get usage():String
		{
			return description + " \n" +
					"\n" +
					"apm help ";
		}
		
		
		public function execute( core:APMCore ):void
		{
			if (_parameters && _parameters.length > 0)
			{
				core.usage( _parameters.join("/") );
			}
			else
			{
				core.usage();
			}
			core.exit( APMCore.CODE_OK );
		}
		
		
	}
	
}
