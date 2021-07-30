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
 * @brief
 * @author 		marchbold
 * @created		30/7/21
 * @copyright	http://distriqt.com/copyright/license.txt
 */
package com.apm.data.packages
{
	
	public class PackageLicense
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "PackageLicense";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		public var type:String = "none";
		public var url:String = "";
		public var isPublic:Boolean = false;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function PackageLicense()
		{
		}
		
		
		public function toObject():Object
		{
			return {
				type:     type,
				url:      url,
				"public": isPublic
			};
		}
		
		
		public function fromObject( data:Object ):PackageLicense
		{
			if (data != null)
			{
				if (data.hasOwnProperty( "type" )) this.type = data[ "type" ];
				if (data.hasOwnProperty( "url" )) this.url = data[ "url" ];
				if (data.hasOwnProperty( "public" )) this.isPublic = data[ "public" ];
			}
			return this;
		}
		
	}
	
}
