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
 * @created		15/6/2021
 */
package com.apm.client.commands.packages.processes
{
	import com.apm.SemVerRange;
	import com.apm.client.APM;
	import com.apm.data.install.InstallData;
	import com.apm.data.install.InstallRequest;
	import com.apm.client.logging.Log;
	import com.apm.client.processes.ProcessBase;
	import com.apm.client.repositories.PackageResolver;
	import com.apm.data.packages.PackageDefinition;
	import com.apm.data.packages.PackageDependency;
	import com.apm.data.packages.PackageVersion;
	
	
	/**
	 * This process is to request the package and assemble the listed dependencies
	 */
	public class QueryPackageProcess extends ProcessBase
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
		private var _shouldQueryDependencies:Boolean;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function QueryPackageProcess(
				data:InstallData,
				request:InstallRequest,
				shouldQueryDependencies:Boolean = true )
		{
			super();
			_installData = data;
			_request = request;
			_shouldQueryDependencies = shouldQueryDependencies;
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
				// Handle file source - nothing to do
				complete();
			}
			else
			{
				APM.io.showSpinner( "Finding package : " + _request.description() );
				PackageResolver.instance.getPackageVersion(
						_request.packageIdentifier,
						SemVerRange.fromString( _request.version ),
						_request.source,
						null,
						function ( success:Boolean, packageDefinition:PackageDefinition ):void
						{
							Log.d( TAG, "getPackageVersion(): success=" + success + " package:" + packageDefinition.toString() );
							var foundVersion:Boolean = success && packageDefinition.versions.length > 0;
							var message:String = foundVersion ? "Found package: " + packageDefinition.toString() :
									"No package found matching : " + _request.description();
							APM.io.stopSpinner( foundVersion, message, foundVersion );
							try
							{
								if (foundVersion)
								{
									var packageVersionForInstall:PackageVersion = packageDefinition.versions[ 0 ];
//									APM.io.writeLine( packageDefinition.toString() );
									
									// Update the request (in case this was a latest version request)
									if (_request.version == "latest")
									{
										_request.version = packageVersionForInstall.version.toString();
									}
									
									_installData.addPackage( packageVersionForInstall, _request );
									
									if (_shouldQueryDependencies)
									{
										// Queue dependencies for install
										for each (var dep:PackageDependency in packageVersionForInstall.dependencies)
										{
											_queue.addProcess(
													new QueryPackageProcess(
															_installData,
															new InstallRequest(
																	dep.identifier,
																	dep.version.toString(),
																	dep.source,
																	packageVersionForInstall
															)
													) );
										}
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
						}
				);
			}
			
		}
		
		
	}
	
}
