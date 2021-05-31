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
package com.apm.client.commands.search
{
	import com.apm.client.APMCore;
	import com.apm.client.commands.Command;
	
	
	public class SearchCommand implements Command
	{
		
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "SearchCommand";
		
		
		public static const NAME:String = "search";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function SearchCommand()
		{
			super();
		}
		
		
		public function setParameters( parameters:Array ):void
		{
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
			return true;
		}
		
		
		public function get description():String
		{
			return "search for a dependency in the repository";
		}
		
		
		public function get usage():String
		{
			return  description + "\n" +
					"\n" +
					"apm search <foo>    search for a dependency called <foo> in the repository\n";
		}
		
		
		
		
		
		
		public function execute( core:APMCore ):void
		{
		}
		
	}
	
}
