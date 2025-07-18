/**
 * @author 		Michael Archbold (https://michaelarchbold.com)
 * @created		7/6/2021
 */
package com.apm.remote.airsdk
{
	import com.adobe.utils.DateUtil;
	
	
	/**
	 * Data class representing a version of the AIR SDK retrieved from the API
	 */
	public class AIRSDKBuild
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "AIRSDKBuild";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		public var version:String;
		
		public var releaseDate:Date;
		
		public var urls:Object = {};
		
		public var releaseNotes:Array = [];
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function AIRSDKBuild()
		{
		}
		
		
		public static function fromObject( data:Object ):AIRSDKBuild
		{
			var b:AIRSDKBuild = new AIRSDKBuild();
			if (data.hasOwnProperty("name")) b.version = data["name"];
			if (data.hasOwnProperty("released_date")) b.releaseDate = DateUtil.parseW3CDTF( data["released_date"] );
			return b;
		}
		
		
	}
}
