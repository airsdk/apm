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
	/**
	 *
	 */
	public class InstallPackageDataGroup
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "InstallPackageDataGroup";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		public var versions:Vector.<InstallPackageData>;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function InstallPackageDataGroup()
		{
			versions = new Vector.<InstallPackageData>();
		}
		
		
		public function get packageIdentifier():String
		{
			if (length > 0)
				return versions[0].packageVersion.packageDef.identifier;
			return "";
		}
		
		
		public function get length():int
		{
			return versions.length;
		}
		
		
		public function addIfNotExists( data:InstallPackageData ):void
		{
			var exists:Boolean = false;
			for each (var p:InstallPackageData in versions)
			{
				exists ||= data.equals(p);
			}
			if (!exists)
			{
				versions.push( data );
			}
		}
		
		
		public function sortByVersion():void
		{
			sort( sortInstallPackageData );
		}
		
		
		public function sort( compare:Function ):void
		{
			versions.sort( compare );
		}
		
		
		private function sortInstallPackageData( a:InstallPackageData, b:InstallPackageData ):int
		{
			if (a.equals( b )) return 0;
			if (a.packageVersion.version.greaterThan( b.packageVersion.version ))
				return -1;
			return 1;
		}
		
	}
}
