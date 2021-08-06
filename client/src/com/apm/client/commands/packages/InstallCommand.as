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
 * @created		18/5/21
 */
package com.apm.client.commands.packages
{
	import com.apm.SemVer;
	import com.apm.client.APMCore;
	import com.apm.client.commands.Command;
	import com.apm.client.commands.packages.data.InstallData;
	import com.apm.client.commands.packages.data.InstallQueryRequest;
	import com.apm.client.commands.packages.processes.InstallDataValidationProcess;
	import com.apm.client.commands.packages.processes.InstallQueryPackageProcess;
	import com.apm.client.commands.packages.processes.UninstallPackageProcess;
	import com.apm.client.commands.packages.utils.ProjectDefinitionValidator;
	import com.apm.client.processes.ProcessQueue;
	import com.apm.data.project.ProjectDefinition;
	
	
	public class InstallCommand implements Command
	{
		
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "InstallCommand";
		
		
		public static const NAME:String = "install";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _parameters:Array;
		private var _queue:ProcessQueue;
		
		private var _installData:InstallData;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function InstallCommand()
		{
			super();
			_installData = new InstallData();
			_queue = new ProcessQueue();
		}
		
		
		public function setParameters( parameters:Array ):void
		{
			_parameters = parameters;
		}
		
		
		public function get name():String
		{
			return NAME;
		}
		
		
		public function get category():String
		{
			return "";
		}
		
		
		public function get requiresNetwork():Boolean
		{
			return true;
		}
		
		
		public function get requiresProject():Boolean
		{
			return true;
		}
		
		
		public function get description():String
		{
			return "add and install a dependency to your project";
		}
		
		
		public function get usage():String
		{
			return description + "\n" +
					"\n" +
					"apm install                   install all the dependencies in your project\n" +
					"apm install <foo>             install the <foo> dependency to your project\n" +
					"apm install <foo> <version>   install a specific <version> of the <foo> dependency to your project\n";
		}
		
		
		public function execute( core:APMCore ):void
		{
			var project:ProjectDefinition = core.config.projectDefinition;
			if (project == null)
			{
				return core.exit( APMCore.CODE_ERROR );
			}
			
			var packageIdentifier:String = null;
			if (_parameters != null && _parameters.length > 0)
			{
				packageIdentifier = _parameters[ 0 ];
				var version:String = (_parameters.length > 1) ? _parameters[ 1 ] : "latest";
				
				var request:InstallQueryRequest = new InstallQueryRequest(
						packageIdentifier,
						version,
						null,
						true
				);
				
				if (SemVer.fromString( request.version ) == null && version != "latest")
				{
					// Invalid version passed
					core.io.writeLine( "Invalid version code : " + version );
					return core.exit( APMCore.CODE_ERROR );
				}
				
				switch (ProjectDefinitionValidator.checkPackageAlreadyInstalled( project, request ))
				{
					case ProjectDefinitionValidator.NOT_INSTALLED:
						// not installed
						break;
					
					case ProjectDefinitionValidator.ALREADY_INSTALLED:
						core.io.writeLine( "Already installed: " + project.dependencies[ i ].toString() + " >= " + request.version.toString() );
						return core.exit( APMCore.CODE_OK );
					
					case ProjectDefinitionValidator.UNKNOWN_LATEST_REQUESTED:
						// exists but requesting latest
						break;
					
					case ProjectDefinitionValidator.HIGHER_VERSION_REQUESTED:
						// To upgrade we first uninstall then continue with the install
						_queue.addProcessToStart( new UninstallPackageProcess( core, packageIdentifier, packageIdentifier ) );
						break;
				}
				
				// Install
				_queue.addProcess(
						new InstallQueryPackageProcess(
								core,
								_installData,
								request
						)
				);
			}
			
			
			if (project.dependencies.length > 0)
			{
				// Install from list in project file
				for (var i:int = 0; i < project.dependencies.length; i++)
				{
					_queue.addProcess(
							new InstallQueryPackageProcess(
									core,
									_installData,
									new InstallQueryRequest(
											project.dependencies[ i ].identifier,
											project.dependencies[ i ].version.toString()
									)
							)
					);
				}
			}
			
			_queue.start(
					function ():void {
						_queue.addProcess( new InstallDataValidationProcess( core, _installData ) );
						_queue.start(
								function ():void {
									core.exit( APMCore.CODE_OK );
								},
								function ( error:String ):void {
									core.exit( APMCore.CODE_ERROR );
								} );
					},
					function ( error:String ):void {
						core.exit( APMCore.CODE_ERROR );
					} );
		}
		
	}
	
}
