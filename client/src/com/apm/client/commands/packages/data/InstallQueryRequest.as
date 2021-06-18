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
 * @created		18/6/21
 */
package com.apm.client.commands.packages.data
{
	import com.apm.SemVer;
	import com.apm.SemVer;
	
	
	public class InstallQueryRequest
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "InstallQueryRequest";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		public var packageIdentifier:String;
		public var version:String;
		public var isDependency:Boolean; // Whether this is a dependency request (won't be added to the project file)
		public var isNew:Boolean; // Whether this was already in the project or is a new package addition

		
		public function get semVer():SemVer { return SemVer.fromString(version); }
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function InstallQueryRequest(
				packageIdentifier:String,
				version:String,
				isDependency:Boolean = false,
				isNew:Boolean=false
		)
		{
			this.packageIdentifier = packageIdentifier;
			this.version = version;
			this.isDependency = isDependency;
			this.isNew = isNew;
		}
		
		
		public function description():String
		{
			return packageIdentifier + "@" + (version == null ? "latest" : version);
		}
		
		
		
		
	}
}
