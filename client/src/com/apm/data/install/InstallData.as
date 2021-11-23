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
package com.apm.data.install
{
	import com.apm.data.install.*;
	import com.apm.data.packages.PackageIdentifier;
	import com.apm.data.packages.PackageVersion;
	
	
	public class InstallData
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "InstallData";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		
		private var _packagesAll:Vector.<InstallPackageData>;
		
		/**
		 * A list of all packages to install, already installed including all dependencies.
		 * This may include multiple references to the same package and different versions.
		 */
		public function get packagesAll():Vector.<InstallPackageData>
		{ return _packagesAll; }


//		/**
//		 * Packages that are already installed,
//		 * - should have top level packages with no dependencies
//		 */
//		private var _packagesInstalled:Vector.<InstallPackageData>;
		
		/**
		 * New packages that are to be installed
		 * - should have top level packages with no dependencies
		 */
		private var _packagesToInstall:Vector.<InstallPackageData>;
		
		/**
		 * Packages that are to be removed
		 */
		private var _packagesToRemove:Vector.<InstallPackageData>;
		
		/**
		 * Group of packages that are in conflict
		 */
		private var _packagesConflicting:Vector.<InstallPackageDataGroup>;
		
		
		public function get packagesToInstall():Vector.<InstallPackageData> { return _packagesToInstall; }
		
		
		public function get packagesToRemove():Vector.<InstallPackageData> { return _packagesToRemove; }
		
		
		public function get packagesConflicting():Vector.<InstallPackageDataGroup> { return _packagesConflicting; }
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function InstallData()
		{
			_packagesAll = new Vector.<InstallPackageData>();
//			_packagesInstalled = new Vector.<InstallPackageData>();
			_packagesToInstall = new Vector.<InstallPackageData>();
			_packagesToRemove = new Vector.<InstallPackageData>();
			_packagesConflicting = new Vector.<InstallPackageDataGroup>();
		}
		
		
		public function containsPackage( packageIdentifier:String ):Boolean
		{
			for each (var p:InstallPackageData in _packagesAll)
			{
				if (
						p.request != null
						&& PackageIdentifier.isEquivalent( p.request.packageIdentifier, packageIdentifier )
				)
				{
					return true;
				}
			}
			return false;
		}
		
		
		public function contains( query:InstallRequest ):Boolean
		{
			for each (var p:InstallPackageData in _packagesAll)
			{
				if (
						p.request != null
						&& PackageIdentifier.isEquivalent( p.request.packageIdentifier, query.packageIdentifier )
						&& p.request.semVer.equals( query.semVer )
				)
				{
					return true;
				}
			}
			return false;
		}
		
		
		public function addPackage( packageVersion:PackageVersion, query:InstallRequest ):void
		{
			var installPackageData:InstallPackageData = new InstallPackageData(
					packageVersion,
					query
			);
			
			for each (var p:InstallPackageData in _packagesAll)
			{
				if (p.packageVersion.equals( packageVersion ))
				{
					// Do not add duplicates
					return;
				}
			}
			
			_packagesAll.push( installPackageData );
		}
		
		
	}
	
}
