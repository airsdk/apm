/**
 * @author 		Michael Archbold (https://michaelarchbold.com)
 * @created		30/7/2021
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
		
		
		public function toDescriptiveString():String
		{
			return "[" + (isPublic ? "public" : "private") + "] " + type + " :: " + url;
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
