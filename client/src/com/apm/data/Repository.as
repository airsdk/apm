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
 * @created		31/5/21
 */
package com.apm.data
{
	
	public class Repository
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "Repository";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		public var url : String;
		
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function Repository()
		{
		}
		
		
		public function toObject():Object
		{
			return {
				url: url,
				credentials: {}
			};
		}
		
		
		public static function fromObject( data:Object ):Repository
		{
			var rep:Repository = new Repository();
			
			rep.url = data.url;
			
			// TODO::
			
			return rep;
		}
		
		
	}
	
}
