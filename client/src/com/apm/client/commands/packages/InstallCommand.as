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
	import com.apm.client.commands.packages.processes.InstallPackageProcess;
	import com.apm.client.commands.packages.processes.InstallQueryPackageProcess;
	import com.apm.client.commands.packages.utils.InstallDataValidator;
	import com.apm.client.commands.packages.utils.ProjectDefintionValidator;
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
			
			
			if (_parameters != null && _parameters.length > 0)
			{
				var packageIdentifier:String = _parameters[ 0 ];
				var version:String = (_parameters.length > 1) ? _parameters[ 1 ] : "latest";
				
				var request:InstallQueryRequest = new InstallQueryRequest(
						packageIdentifier,
						version,
						false,
						true
				);
				
				if (SemVer.fromString(request.version) == null && version != "latest")
				{
					// Invalid version passed
					core.io.writeLine( "Invalid version code : " + version );
					return core.exit( APMCore.CODE_ERROR );
				}
				
				switch (ProjectDefintionValidator.checkPackageAlreadyInstalled( project, request ))
				{
					case -1:
						// not installed
					case 0:
						// latest
						break;
					
					case 1:
						core.io.writeLine( "Already installed: " + project.dependencies[i].toString() + " >= " + request.version.toString() );
						return core.exit( APMCore.CODE_OK );
					
					case 2:
						// TODO: Upgrade?
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
			
			
			
			
			_queue.start( function ():void {

				//
				var resolver:InstallDataValidator = new InstallDataValidator();
				if (resolver.verifyInstall( _installData ))
				{
					// dependencies could be resolved - proceed to installation
					
				}
				
//				if (!_isDependency)
//				{
//					// Add it to the project definition
//					_core.config.projectDefinition.addPackageDependency( packageDefinition );
//					_core.config.projectDefinition.save();
//				}
				
				core.exit( APMCore.CODE_OK );
				
			} );
			
			
		}
		
	}
	
}
