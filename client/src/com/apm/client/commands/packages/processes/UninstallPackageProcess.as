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
 * @created		15/6/21
 */
package com.apm.client.commands.packages.processes
{
	import com.apm.client.APMCore;
	import com.apm.client.commands.packages.data.InstallPackageData;
	import com.apm.client.commands.packages.data.InstallQueryRequest;
	import com.apm.client.commands.packages.utils.PackageFileUtils;
	import com.apm.client.logging.Log;
	import com.apm.client.processes.ProcessBase;
	import com.apm.client.processes.ProcessQueue;
	import com.apm.data.packages.PackageDefinitionFile;
	import com.apm.data.packages.PackageDependency;
	
	import flash.filesystem.File;
	
	
	/**
	 * This process uninstalls an AIR package
	 */
	public class UninstallPackageProcess extends ProcessBase
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "UninstallPackageProcess";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _core:APMCore;
		private var _uninstallingPackageIdentifier:String;
		private var _packageIdentifier:String;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function UninstallPackageProcess( core:APMCore, uninstallingPackageIdentifier:String, packageIdentifier:String )
		{
			super();
			_core = core;
			_uninstallingPackageIdentifier = uninstallingPackageIdentifier;
			_packageIdentifier = packageIdentifier;
		}
		
		
		override public function start():void
		{
			_core.io.writeLine( "Uninstall package : " + _packageIdentifier );
			
			var uninstallingPackageDir:File = PackageFileUtils.cacheDirForPackage( _core, _packageIdentifier );
			var f:File = uninstallingPackageDir.resolvePath( PackageDefinitionFile.DEFAULT_FILENAME );
			if (!f.exists)
			{
				_core.io.writeError( _packageIdentifier, "Package not found" );
				_core.config.projectDefinition.removePackageDependency( _packageIdentifier ).save();
				return failure( "Package " + _packageIdentifier + " not found" );
			}
			
			var uninstallingPackageDefinition:PackageDefinitionFile = new PackageDefinitionFile();
			uninstallingPackageDefinition.load( f );
			
			// need to determine if this package is required by another package currently installed
			if (isPackageRequiredDependency( _uninstallingPackageIdentifier, _packageIdentifier ))
			{
				_core.io.writeError( _packageIdentifier, "Required by another package - skipping uninstall" );
				return complete();
			}
			
			// Schedule any dependencies to be uninstalled
			for each (var dependency:PackageDependency in uninstallingPackageDefinition.dependencies)
			{
				processQueue.addProcessToStart(
						new UninstallPackageProcess( _core, _uninstallingPackageIdentifier, dependency.identifier )
				);
			}
			
			var queue:ProcessQueue = new ProcessQueue();
			
			queue.addProcess( new UninstallFilesForPackageProcess( _core, uninstallingPackageDefinition ) );
			
			queue.start( function ():void {
							 _core.config.projectDefinition.removePackageDependency( _packageIdentifier ).save();
							 complete();
						 },
						 function ( error:String ):void {
							 _core.io.writeError( _packageIdentifier, error );
							 failure( error );
						 } );
			
		}
		
		
		private function isPackageRequiredDependency( uninstallingPackageIdentifier:String, packageIdentifier:String ):Boolean
		{
			Log.d( TAG, "isPackageRequiredDependency( " + uninstallingPackageIdentifier + ", " + packageIdentifier + " )" );
			if (packageIdentifier != uninstallingPackageIdentifier)
			{
				var packagesDir:File = new File( _core.config.packagesDir );
				for each (var packageDir:File in packagesDir.getDirectoryListing())
				{
					Log.d( TAG, "isPackageRequiredDependency() : Directory : " + packageDir.name );
					if (packageDir.isDirectory && packageDir.resolvePath( PackageDefinitionFile.DEFAULT_FILENAME ).exists)
					{
						// This is a package - load the package file and check listed dependencies
						var f:File = packageDir.resolvePath( PackageDefinitionFile.DEFAULT_FILENAME );
						var packageDefinition:PackageDefinitionFile = new PackageDefinitionFile().load( f );
						
						Log.d( TAG, "isPackageRequiredDependency() : Checking : " + packageDefinition.packageDef.identifier );

						// Ignore the package being uninstalled and the current package
						if (packageDefinition.packageDef.identifier == uninstallingPackageIdentifier
						|| packageDefinition.packageDef.identifier == packageIdentifier)
							continue;
						
						for each (var dep:PackageDependency in packageDefinition.dependencies)
						{
							Log.d( TAG, "isPackageRequiredDependency() : Checking dependency [" + packageDefinition.packageDef.identifier +"] : " + dep.identifier );
							if (dep.identifier == packageIdentifier)
								return true;
						}
						
					}
				}
			}
			return false;
		}
		
		
	}
	
}
