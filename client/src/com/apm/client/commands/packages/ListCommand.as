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
package com.apm.client.commands.packages
{
	import com.apm.client.APMCore;
	import com.apm.client.IO;
	import com.apm.client.commands.Command;
	
	
	public class ListCommand implements Command
	{
		
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "ListCommand";
		
		
		public static const NAME:String = "list";
		
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _parameters:Array;
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function ListCommand()
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
			return "lists dependencies currently added to your project";
		}
		
		
		public function get usage():String
		{
			return  description + "\n" +
					"\n" +
					"apm list          list all the dependencies in your project\n"
		}
		
		
		
		
		public function execute( core:APMCore ):void
		{
			core.io.showSpinner();
//			core.exit( APMCore.CODE_OK );
		}
		
	}
	
}
