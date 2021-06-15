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
	import com.apm.SemVer;
	import com.apm.SemVer;
	
	
	public class PackageVersionDefinition
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "PackageDefinition";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		public var publishedAt:String = "";
		public var sourceUrl:String = "";
		public var version:SemVer = null;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function PackageVersionDefinition()
		{
		}
		
		
		public function toString():String
		{
			return version.toString();
		}
		
		
		public function toDescriptiveString():String
		{
			return version.toString() + " : " + publishedAt;
		}
		
		
		public function fromObject( data:Object ):PackageVersionDefinition
		{
			if (data != null)
			{
				if (data.hasOwnProperty("version")) this.version = SemVer.fromString( data["version"] );
				if (data.hasOwnProperty("sourceUrl")) this.sourceUrl = data["sourceUrl"];
				if (data.hasOwnProperty("publishedAt")) this.publishedAt = data["publishedAt"];
			}
			return this;
		}
		
	}
	
}
