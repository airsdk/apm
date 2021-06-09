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
 * @created		9/6/21
 */
package com.apm.data
{
	
	public class PackageDefinition
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "PackageDefinition";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		public var name:String = "";
		public var description:String = "";
		public var identifier:String = "";
		public var version:String = "";
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function PackageDefinition()
		{
		}
		
		
		public function toString():String
		{
			return identifier +"@" + version + "   "+description
		}
		
		public function fromObject( data:Object ):PackageDefinition
		{
			if (data != null)
			{
				if (data.hasOwnProperty("name")) this.name = data["name"];
				if (data.hasOwnProperty("description")) this.description = data["description"];
				if (data.hasOwnProperty("identifier")) this.identifier = data["identifier"];
				if (data.hasOwnProperty("version")) this.version = data["version"];
			}
			return this;
		}
		
	}
	
}
