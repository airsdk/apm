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
	import com.apm.data.packages.PackageVersion;
	
	
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
		
		/**
		 * The package that required this request , i.e. the package that has this package/version as a dependency
		 */
		public var requiringPackage:PackageVersion;
		
		/**
		 * Whether this was already in the project or is a new package addition
		 */
		public var isNew:Boolean;

		
		public function get semVer():SemVer { return SemVer.fromString(version); }
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function InstallQueryRequest(
				packageIdentifier:String,
				version:String,
				requiringPackage:PackageVersion = null,
				isNew:Boolean=false
		)
		{
			this.packageIdentifier = packageIdentifier;
			this.version = version;
			this.requiringPackage = requiringPackage;
			this.isNew = isNew;
		}
		
		
		public function description():String
		{
			return packageIdentifier + "@" + (version == null ? "latest" : version);
		}
		
		
		
		
	}
}
