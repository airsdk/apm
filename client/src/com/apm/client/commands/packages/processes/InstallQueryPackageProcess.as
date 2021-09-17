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
	import com.apm.client.commands.packages.data.InstallData;
	import com.apm.client.commands.packages.data.InstallRequest;
	import com.apm.client.commands.packages.utils.ProjectDefinitionValidator;
	import com.apm.client.logging.Log;
	import com.apm.client.repositories.PackageResolver;
	import com.apm.client.processes.ProcessBase;
	import com.apm.data.packages.PackageDefinition;
	import com.apm.data.packages.PackageDependency;
	import com.apm.data.packages.PackageVersion;
	import com.apm.remote.repository.RepositoryAPI;
	import com.apm.utils.PackageFileUtils;
	
	import flash.filesystem.File;
	
	
	/**
	 * This process is to request the package and assemble the listed dependencies
	 */
	public class InstallQueryPackageProcess extends ProcessBase
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "InstallQueryPackageProcess";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _installData:InstallData;
		private var _request:InstallRequest;
		private var _failIfInstalled:Boolean;
		
		private var _packageResolver:PackageResolver;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function InstallQueryPackageProcess(
				data:InstallData,
				request:InstallRequest,
				failIfInstalled:Boolean=true )
		{
			super();
			_installData = data;
			_request = request;
			_failIfInstalled = failIfInstalled;
			
			_packageResolver = new PackageResolver();
		}
		
		
		override public function start( completeCallback:Function = null, failureCallback:Function = null ):void
		{
			super.start( completeCallback, failureCallback );
			// Check if already queried for this package
			if (_installData.contains( _request ))
			{
				return complete();
			}
			
			Log.d( TAG, "start(): " + _request.description() );

			if (_request.source == "file")
			{
				// Handle file source
				
				// Here we are assuming there is a package installed already matching the identifier / version
				// This should only be reached from an "apm install" or "apm update"
				var packageFile:File = PackageFileUtils.fileForPackageFromIdentifierVersion(
						APM.config.packagesDir,
						_request.packageIdentifier,
						_request.semVer );
				
				if (packageFile.exists)
				{
					_queue.addProcess( new InstallLocalPackageProcess( packageFile, _installData, false ) );
					complete();
				}
				else
				{
					APM.io.writeError( "package", "Could not find installed package: " + packageFile.name );
					failure( "Could not find installed package: " + packageFile.name );
				}
			}
			else
			{
				APM.io.showSpinner( "Finding package : " + _request.description() );
				_packageResolver.getPackageVersion(
						_request.packageIdentifier,
						SemVer.fromString( _request.version ),
						_request.source,
						function ( success:Boolean, packageDefinition:PackageDefinition ):void {
							var foundVersion:Boolean = success && packageDefinition.versions.length > 0;
							APM.io.stopSpinner( foundVersion,
												"No package found matching : " + _request.description(),
												foundVersion );
							try
							{
								if (foundVersion)
								{
									var packageVersionForInstall:PackageVersion = packageDefinition.versions[ 0 ];
									APM.io.writeLine( packageDefinition.toString() );
									
									// Update the request (in case this was a latest version request)
									if (_request.version == "latest")
									{
										_request.version = packageVersionForInstall.version.toString();
										
										// Perform a delayed "already installed" check
										switch (ProjectDefinitionValidator.checkPackageAlreadyInstalled( APM.config.projectDefinition, _request ))
										{
											case ProjectDefinitionValidator.ALREADY_INSTALLED:
												if (_failIfInstalled)
												{
													var existingDependency:PackageDependency = ProjectDefinitionValidator.getInstalledPackageDependency( APM.config.projectDefinition, _request );
													
													APM.io.writeLine( "Already installed: " + existingDependency.toString() + " >= " + _request.version );
													failure();
												}
												break;
											
											case ProjectDefinitionValidator.HIGHER_VERSION_REQUESTED:
												processQueue.addProcessToStart( new UninstallPackageProcess( packageDefinition.identifier, packageDefinition.identifier ) );
												break;
											
											case ProjectDefinitionValidator.UNKNOWN_LATEST_REQUESTED:
											case ProjectDefinitionValidator.NOT_INSTALLED:
												break;
										}
									}
									
									_installData.addPackage( packageVersionForInstall, _request );
									
									// Queue dependencies for install
									for each (var dep:PackageVersion in packageVersionForInstall.dependencies)
									{
										_queue.addProcess(
												new InstallQueryPackageProcess(
														_installData,
														new InstallRequest(
																dep.packageDef.identifier,
																dep.version.toString(),
																dep.source,
																packageVersionForInstall )
												) );
									}
									
								}
								else if (success)
								{
									// View the package to show available versions
									_queue.clear();
									_queue.addProcess( new ViewPackageProcess( _request.packageIdentifier ) );
								}
							}
							catch (e:Error)
							{
								Log.e( TAG, e );
							}
							complete();
						} );
			}
			
		}
		
		
	}
	
}
