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
	import com.apm.SemVer;
	import com.apm.client.APM;
	import com.apm.client.io.IOColour;
	import com.apm.client.processes.ProcessBase;
	import com.apm.client.processes.ProcessQueue;
	import com.apm.data.packages.PackageDefinitionFile;
	import com.apm.data.packages.PackageDependency;
	import com.apm.utils.PackageCacheUtils;
	import com.apm.utils.PackageFileUtils;

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
		private var _appDescriptorPath:String;
		private var _version:SemVer;
		private var _failIfNotInstalled:Boolean;
		private var _checkIfRequiredDependency:Boolean;


		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//

		/**
		 *
		 * @param uninstallingPackageIdentifier
		 * @param packageIdentifier
		 * @param version
		 * @param failIfNotInstalled
		 * @param checkIfRequiredDependency
		 */
		public function UninstallPackageProcess(
				uninstallingPackageIdentifier:String,
				packageIdentifier:String,
				appDescriptorPath:String,
				version:SemVer                    = null,
				failIfNotInstalled:Boolean        = true,
				checkIfRequiredDependency:Boolean = true
		)
		{
			super();
			_uninstallingPackageIdentifier = uninstallingPackageIdentifier;
			_packageIdentifier             = packageIdentifier;
			_appDescriptorPath             = appDescriptorPath;
			_version                       = version;
			_failIfNotInstalled            = failIfNotInstalled;
			_checkIfRequiredDependency     = checkIfRequiredDependency;
		}


		override public function start( completeCallback:Function = null, failureCallback:Function = null ):void
		{
			super.start( completeCallback, failureCallback );

			// Check the specified package is installed
			if (!PackageCacheUtils.isPackageInstalled( _packageIdentifier, _version ))
			{
				if (_failIfNotInstalled)
				{
					APM.io.writeError( _packageIdentifier, "Package not found" );
					if (APM.config.projectDefinition.hasDependency( _packageIdentifier ))
					{
						APM.config.projectDefinition
						   .removePackageDependency( _packageIdentifier )
						   .save();
					}
					return failure( "Package " + _packageIdentifier + " not found" );
				}
				else
				{
					return complete();
				}
			}

			// Start uninstallation
			APM.io.writeLine( "Uninstall package : " + _packageIdentifier );

			var uninstallingPackageDir:File = PackageFileUtils.cacheDirForPackage( APM.config.packagesDirectory,
																				   _packageIdentifier );

			var f:File = uninstallingPackageDir.resolvePath( PackageDefinitionFile.DEFAULT_FILENAME );

			var uninstallingPackageDefinition:PackageDefinitionFile = new PackageDefinitionFile().load( f );

			// need to determine if this package is required by another package currently installed
			if (_checkIfRequiredDependency && PackageCacheUtils.isPackageRequiredDependency(
					_uninstallingPackageIdentifier,
					_packageIdentifier ))
			{
				APM.io.writeLine( _packageIdentifier + " required by another package - skipping uninstall",
								  IOColour.LIGHT_GRAY );
				return complete();
			}

			// Schedule any dependencies to be uninstalled
			for each (var dependency:PackageDependency in uninstallingPackageDefinition.dependencies)
			{
				processQueue.addProcessToStart(
						new UninstallPackageProcess(
								_uninstallingPackageIdentifier,
								dependency.identifier,
								_appDescriptorPath,
								null,
								false,
								_checkIfRequiredDependency )
				);
			}

			var queue:ProcessQueue = new ProcessQueue();

			queue.addProcess( new UninstallFilesForPackageProcess( uninstallingPackageDefinition ) );
			if (_appDescriptorPath != null)
			{
				queue.addProcess( new UninstallPackageFromAppDescriptorProcess( uninstallingPackageDefinition,
																				_appDescriptorPath ) );
			}

			queue.start(
					function ():void
					{
						APM.config.projectDefinition
						   .removePackageDependency( _packageIdentifier )
//								.save();

						if (APM.config.projectLock != null)
						{
							APM.config.projectLock
							   .removePackageDependency( _packageIdentifier )
//									.save();
						}

						complete();
					},
					function ( error:String ):void
					{
						APM.io.writeError( _packageIdentifier, error );
						failure( error );
					}
			);

		}


	}

}
