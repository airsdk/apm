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
	import com.apm.client.APMCore;
	import com.apm.client.commands.packages.data.InstallData;
	import com.apm.client.commands.packages.data.InstallQueryRequest;
	import com.apm.client.commands.packages.utils.ProjectDefintionValidator;
	import com.apm.client.logging.Log;
	import com.apm.client.processes.ProcessBase;
	import com.apm.data.packages.PackageDefinition;
	import com.apm.data.packages.PackageVersion;
	import com.apm.remote.repository.RepositoryAPI;
	
	
	/**
	 * This process is to query the package and assemble the listed dependencies
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
		
		private var _core:APMCore;
		private var _installData:InstallData;
		private var _request:InstallQueryRequest;
		
		private var _repositoryAPI:RepositoryAPI;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function InstallQueryPackageProcess(
				core:APMCore,
				data:InstallData,
				request:InstallQueryRequest )
		{
			super();
			_core = core;
			_installData = data;
			_request = request;
			
			_repositoryAPI = new RepositoryAPI();
		}
		
		
		override public function start():void
		{
			// Check if already queried for this package
			if (_installData.contains( _request ))
			{
				return complete();
			}
			
			_core.io.showSpinner( "Finding package : " + _request.description() );
			_repositoryAPI.getPackageVersion(
					_request.packageIdentifier,
					SemVer.fromString( _request.version ),
					function ( success:Boolean, packageDefinition:PackageDefinition ):void {
						var foundVersion:Boolean = success && packageDefinition.versions.length > 0;
						_core.io.stopSpinner( foundVersion,
											  "No package found matching : " + _request.description(),
											  foundVersion );
						try
						{
							if (foundVersion)
							{
								var installVersion:PackageVersion = packageDefinition.versions[ 0 ];
								_core.io.writeLine( packageDefinition.toString() );
								
								// Update the request (in case this was a latest version request)
								if (_request.version == "latest")
								{
									_request.version = installVersion.version.toString();
									
									// Perform a delayed "already installed" check
									switch (ProjectDefintionValidator.checkPackageAlreadyInstalled( _core.config.projectDefinition, _request ))
									{
										case -1:
											// not installed
										case 0:
											// latest
											break;
										
										case 1:
											_core.io.writeLine( "Already installed: " + packageDefinition.toString() + " >= " + _request.version );
											return _core.exit( APMCore.CODE_OK );
										
										case 2:
											// TODO: Upgrade?
									}
								}
								
								
								_installData.addPackage( packageDefinition, installVersion, _request );
								
								// Queue dependencies for install
								for each (var dep:PackageVersion in installVersion.dependencies)
								{
									_queue.addProcess(
											new InstallQueryPackageProcess(
													_core,
													_installData,
													new InstallQueryRequest(
															dep.packageDef.identifier,
															dep.version.toString(),
															true )
											) );
								}
								
							}
							else if (success)
							{
								// View the package to show available versions
								_queue.clear();
								_queue.addProcess( new ViewPackageProcess( _core, _request.packageIdentifier ) );
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
