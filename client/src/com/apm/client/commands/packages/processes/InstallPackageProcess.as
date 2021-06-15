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
	import com.apm.client.commands.airsdk.processes.DownloadAIRSDKProcess;
	import com.apm.client.logging.Log;
	import com.apm.client.processes.Process;
	import com.apm.client.processes.ProcessBase;
	import com.apm.client.processes.events.ProcessEvent;
	import com.apm.data.PackageDefinition;
	import com.apm.data.ProjectDependency;
	import com.apm.remote.repository.RepositoryAPI;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	
	public class InstallPackageProcess extends ProcessBase
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "InstallPackageProcess";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _core:APMCore;
		private var _packageIdentifier:String;
		private var _version:SemVer;
		
		private var _repositoryAPI:RepositoryAPI;
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function InstallPackageProcess( core:APMCore, packageIdentifier:String, version:String )
		{
			super();
			_core = core;
			_packageIdentifier = packageIdentifier;
			_version = SemVer.fromString(version);
			
			_repositoryAPI = new RepositoryAPI();
		}
		
		
		override public function start():void
		{
			var installDescription:String = _packageIdentifier + "@" + (_version == null ? "latest" : _version.toString());
			_core.io.showSpinner( "Finding package : " + installDescription );
			_repositoryAPI.getPackageVersion(
					_packageIdentifier,
					_version,
					function( success:Boolean, packageDefinition:PackageDefinition ):void {
				var foundVersion:Boolean = success && packageDefinition.versions.length > 0;
				_core.io.stopSpinner( foundVersion,
									  "No package found matching : " + installDescription,
									  foundVersion );
				try
				{
					if (foundVersion)
					{
						_core.io.writeLine( packageDefinition.toString() );
						
						// Add it to the project definition
						_core.config.projectDefinition.addPackageDependency( packageDefinition );
						_core.config.projectDefinition.save();
						
						_queue.addProcess( new DownloadPackageProcess( _core, packageDefinition ));
						_queue.addProcess( new ExtractPackageProcess( _core, packageDefinition ));
						
					}
					else if (success)
					{
						// View the package to show available versions
						_queue.addProcess( new ViewPackageProcess( _core, _packageIdentifier ));
					}
				}
				catch (e:Error)
				{
					Log.e( TAG, e );
				}
				complete();
			});
			
		}
		
		
	}
	
}
