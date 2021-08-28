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
	import com.apm.client.APM;
	import com.apm.utils.PackageFileUtils;
	import com.apm.client.logging.Log;
	import com.apm.client.processes.ProcessBase;
	import com.apm.client.processes.ProcessQueue;
	import com.apm.data.packages.PackageDefinitionFile;
	import com.apm.data.packages.PackageDependency;
	import com.apm.data.packages.PackageIdentifier;
	
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
		
		private var _uninstallingPackageIdentifier:String;
		private var _packageIdentifier:String;
		private var _skipChecks:Boolean;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function UninstallPackageProcess( uninstallingPackageIdentifier:String, packageIdentifier:String, skipChecks:Boolean = false )
		{
			super();
			_uninstallingPackageIdentifier = uninstallingPackageIdentifier;
			_packageIdentifier = packageIdentifier;
			_skipChecks = skipChecks;
		}
		
		
		override public function start( completeCallback:Function = null, failureCallback:Function = null ):void
		{
			super.start( completeCallback, failureCallback );
			APM.io.writeLine( "Uninstall package : " + _packageIdentifier );
			
			var uninstallingPackageDir:File = PackageFileUtils.cacheDirForPackage( APM.config.packagesDir, _packageIdentifier );
			var f:File = uninstallingPackageDir.resolvePath( PackageDefinitionFile.DEFAULT_FILENAME );
			if (!f.exists)
			{
				if (_skipChecks)
				{
					return complete();
				}
				else
				{
					APM.io.writeError( _packageIdentifier, "Package not found" );
					APM.config.projectDefinition.removePackageDependency( _packageIdentifier ).save();
					return failure( "Package " + _packageIdentifier + " not found" );
				}
			}
			
			var uninstallingPackageDefinition:PackageDefinitionFile = new PackageDefinitionFile();
			uninstallingPackageDefinition.load( f );
			
			// need to determine if this package is required by another package currently installed
			if (!_skipChecks && isPackageRequiredDependency( _uninstallingPackageIdentifier, _packageIdentifier ))
			{
				APM.io.writeError( _packageIdentifier, "Required by another package - skipping uninstall" );
				return complete();
			}
			
			// Schedule any dependencies to be uninstalled
			for each (var dependency:PackageDependency in uninstallingPackageDefinition.dependencies)
			{
				processQueue.addProcessToStart(
						new UninstallPackageProcess( _uninstallingPackageIdentifier, dependency.identifier )
				);
			}
			
			var queue:ProcessQueue = new ProcessQueue();
			
			queue.addProcess( new UninstallFilesForPackageProcess( uninstallingPackageDefinition ) );
			
			queue.start( function ():void {
							 APM.config.projectDefinition.removePackageDependency( _packageIdentifier ).save();
							 complete();
						 },
						 function ( error:String ):void {
							 APM.io.writeError( _packageIdentifier, error );
							 failure( error );
						 } );
			
		}
		
		
		private function isPackageRequiredDependency( uninstallingPackageIdentifier:String, packageIdentifier:String ):Boolean
		{
			Log.d( TAG, "isPackageRequiredDependency( " + uninstallingPackageIdentifier + ", " + packageIdentifier + " )" );
			if (!PackageIdentifier.isEquivalent( packageIdentifier, uninstallingPackageIdentifier ))
			{
				var packagesDir:File = new File( APM.config.packagesDir );
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
			}
			return false;
		}
		
		
	}
	
}
