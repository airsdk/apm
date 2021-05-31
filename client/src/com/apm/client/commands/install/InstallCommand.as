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
package com.apm.client.commands.install
{
	import com.apm.client.APMCore;
	import com.apm.client.IO;
	import com.apm.client.commands.Command;
	
	
	public class InstallCommand implements Command
	{
		
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "InstallCommand";
		
		
		public static const NAME:String = "install";
		
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _parameters:Array;
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function InstallCommand()
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
			return "add and install a dependency to your project";
		}
		
		
		public function get usage():String
		{
			return  description + "\n" +
					"\n" +
					"apm install          install all the dependencies in your project\n" +
					"apm install <foo>    install the <foo> dependency to your project\n";
		}
		
		
		
		
		public function execute( core:APMCore ):void
		{
			IO.out( "installing : " + (_parameters.length > 0 ? _parameters[0] : "...") + "\n");
		}
		
	}
	
}
