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
 * @created		31/5/2021
 */
package com.apm.data.packages
{
	
	public class RepositoryDefinition
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "RepositoryDefinition";
		
		public static const TYPE_REMOTE:String = "remote";
		public static const TYPE_LOCAL:String = "local";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		public var type:String = TYPE_REMOTE;
		public var name:String = "";
		public var location:String = "";
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function RepositoryDefinition()
		{
		}
		
		
		public function toObject():Object
		{
			return {
				type: type,
				name: name,
				location: location
			};
		}
		
		
		public static function fromObject( data:Object ):RepositoryDefinition
		{
			var rep:RepositoryDefinition = new RepositoryDefinition();
			
			if (data.hasOwnProperty("type")) rep.type = data.type;
			if (data.hasOwnProperty("name")) rep.name = data.name;
			if (data.hasOwnProperty("location")) rep.location = data.location;
			if (data.hasOwnProperty("url")) rep.location = data.location;
			
			// TODO::
			
			return rep;
		}
		
		
	}
	
}
