/**
 * @author 		Michael Archbold (https://michaelarchbold.com)
 * @created		28/8/2021
 */
package com.apm.utils
{
	import com.apm.SemVer;
	import com.apm.client.APM;
	import com.apm.client.logging.Log;
	import com.apm.data.packages.PackageDefinitionFile;
	import com.apm.data.packages.PackageDependency;
	import com.apm.data.packages.PackageIdentifier;

	import flash.filesystem.File;

	/**
	 * Utilities for checking package contents that have been
	 * extracted for use in the project
	 */
	public class ProjectPackageCache
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//

		private static const TAG:String = "ProjectPackageCache";


		public static const PACKAGE_CACHE_DIR:String = "apm_packages";


		////////////////////////////////////////////////////////
		//  VARIABLES
		//


		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//

		public function ProjectPackageCache()
		{
		}


		/**
		 * Checks if the specified package is installed. Optionally specify the version if you need to
		 * check for a specific version.
		 *
		 * @param packageIdentifier	The identifier of the package to check for
		 * @param version			Specific version to check. If <code>null</code> this will return true for any installed version of the package.
		 * @return <code>true</code> if the package is installed and <code>false</code> if not.
		 */
		public static function isPackageInstalled( packageIdentifier:String, version:SemVer = null ):Boolean
		{
			var uninstallingPackageDir:File = PackageFileUtils.contentsDirForPackage( APM.config.packagesDirectory, packageIdentifier );
			var f:File = uninstallingPackageDir.resolvePath( PackageDefinitionFile.DEFAULT_FILENAME );
			if (!f.exists)
			{
				return false;
			}
			else if (version != null)
			{
				// Check version matches
				var packageDefinition:PackageDefinitionFile = new PackageDefinitionFile().load( f );
				// TODO:: handle version ranges in project definition file
				if (!packageDefinition.version.version.equals( version ))
				{
					return false;
				}
			}
			return true;
		}


		/**
		 * Iterates over the locally installed packages and checks the listed dependencies for the specified package identifier
		 *
		 * @param uninstallingPackageIdentifier	Ignores any dependencies from this package, eg if this package is being uninstalled we don't want to consider it's dependencies as required any longer.
		 * @param packageIdentifier				The package identifier of the dependency to search for
		 * @return	<code>true</code> if the packageIdentifier is required by another package and <code>false</code> if not.
		 */
		public static function isPackageRequiredDependency( uninstallingPackageIdentifier:String, packageIdentifier:String ):Boolean
		{
			Log.d( TAG, "isPackageRequiredDependency( " + uninstallingPackageIdentifier + ", " + packageIdentifier + " )" );
			if (PackageIdentifier.isEquivalent( packageIdentifier, uninstallingPackageIdentifier ))
			{
				return false;
			}

			for each (var packageDefinition:PackageDefinitionFile in getPackages())
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
			return false;
		}


		/**
		 * Returns an array of packages that are extracted in the project.
		 *
		 * @return A <code>Vector</code> of <code>PackageDefinitionFile</code> references for each package installed
		 */
		public static function getPackages():Vector.<PackageDefinitionFile>
		{
			var cachedPackages:Vector.<PackageDefinitionFile> = new Vector.<PackageDefinitionFile>();
			var packagesDir:File = new File( APM.config.packagesDirectory );
			if (packagesDir.exists)
			{
				for each (var packageDir:File in packagesDir.getDirectoryListing())
				{
					if (packageDir.isDirectory)
					{
						var projectDefinitionFile:File = packageDir.resolvePath( PackageFileUtils.contentsDirName() + "/" + PackageDefinitionFile.DEFAULT_FILENAME );
						if (projectDefinitionFile.exists)
						{
							var packageDefinition:PackageDefinitionFile = new PackageDefinitionFile().load( projectDefinitionFile );
							cachedPackages.push( packageDefinition );
						}
					}
				}
			}
			return cachedPackages;
		}


		/**
		 * Find the extracted <code>PackageDefinitionFile</code> for the specified identifier
		 *
		 * @param identifier The package identifier to search the extracted contents for
		 *
		 * @return A <code>PackageDefinitionFile</code> representing the extracted package or null if not found
		 */
		public static function getPackage( identifier:String ):PackageDefinitionFile
		{
			var extractedPackages:Vector.<PackageDefinitionFile> = getPackages();
			for each (var cachedPackage:PackageDefinitionFile in extractedPackages)
			{
				if (PackageIdentifier.isEquivalent( cachedPackage.packageDef.identifier, identifier ))
				{
					return cachedPackage;
				}
			}
			return null;
		}


	}

}
