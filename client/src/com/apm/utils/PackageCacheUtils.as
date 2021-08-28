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
 * @created		28/8/21
 */
package com.apm.utils
{
	import com.apm.SemVer;
	import com.apm.client.APM;
	import com.apm.client.logging.Log;
	import com.apm.data.packages.PackageDefinitionFile;
	import com.apm.data.packages.PackageDependency;
	import com.apm.data.packages.PackageIdentifier;
	import com.apm.data.project.ProjectDefinition;
	
	import flash.filesystem.File;
	
	
	public class PackageCacheUtils
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "PackageCacheUtils";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function PackageCacheUtils()
		{
		}
		
		
		public static function isPackageInstalled( packageIdentifier:String, version:SemVer=null ):Boolean
		{
			var uninstallingPackageDir:File = PackageFileUtils.cacheDirForPackage( APM.config.packagesDir, packageIdentifier );
			var f:File = uninstallingPackageDir.resolvePath( PackageDefinitionFile.DEFAULT_FILENAME );
			if (!f.exists)
			{
				return false;
			}
			else if (version != null)
			{
				// Check version matches
				var packageDefinition:PackageDefinitionFile = new PackageDefinitionFile().load( f );
				if (!packageDefinition.version.version.equals( version ))
				{
					return false;
				}
			}
			return true;
		}
		
		
		public static function isPackageRequiredDependency( uninstallingPackageIdentifier:String, packageIdentifier:String ):Boolean
		{
			Log.d( TAG, "isPackageRequiredDependency( " + uninstallingPackageIdentifier + ", " + packageIdentifier + " )" );
			if (!PackageIdentifier.isEquivalent( packageIdentifier, uninstallingPackageIdentifier ))
			{
				for each (var packageDefinition:PackageDefinitionFile in getCachedPackages())
				{
					Log.d( TAG, "isPackageRequiredDependency() : Checking : " + packageDefinition.packageDef.identifier );

					// Ignore the package being uninstalled and the current package
					if (PackageIdentifier.isEquivalent( packageDefinition.packageDef.identifier, uninstallingPackageIdentifier )
							|| PackageIdentifier.isEquivalent( packageDefinition.packageDef.identifier, packageIdentifier ))
						continue;
					
					for each (var dep:PackageDependency in packageDefinition.dependencies)
					{
						Log.d( TAG, "isPackageRequiredDependency() : Checking dependency [" + packageDefinition.packageDef.identifier + "] : " + dep.identifier );
						if (PackageIdentifier.isEquivalent( dep.identifier, packageIdentifier ))
							return true;
					}
				}
			}
			return false;
		}
		
		
		public static function getCachedPackages():Vector.<PackageDefinitionFile>
		{
			var cachedPackages:Vector.<PackageDefinitionFile> = new Vector.<PackageDefinitionFile>();
			var packagesDir:File = new File( APM.config.packagesDir );
			for each (var packageDir:File in packagesDir.getDirectoryListing())
			{
				if (packageDir.isDirectory)
				{
					var projectDefinitionFile:File = packageDir.resolvePath( PackageFileUtils.cacheDirName() + "/" + PackageDefinitionFile.DEFAULT_FILENAME );
					if (projectDefinitionFile.exists)
					{
						var packageDefinition:PackageDefinitionFile = new PackageDefinitionFile().load( projectDefinitionFile );
						cachedPackages.push( packageDefinition );
					}
				}
			}
			return cachedPackages;
		}
		
		
	}
	
}
