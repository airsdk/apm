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
	import com.apm.client.APM;
	import com.apm.client.commands.Command;
	import com.apm.client.commands.packages.processes.InstallDataValidationProcess;
	import com.apm.client.commands.packages.processes.InstallLocalPackageProcess;
	import com.apm.client.commands.packages.processes.InstallQueryPackageProcess;
	import com.apm.client.commands.packages.processes.UninstallPackageProcess;
	import com.apm.client.commands.packages.utils.ProjectDefinitionValidator;
	import com.apm.client.events.CommandEvent;
	import com.apm.client.processes.ProcessQueue;
	import com.apm.data.install.InstallData;
	import com.apm.data.install.InstallPackageData;
	import com.apm.data.install.InstallRequest;
	import com.apm.data.packages.PackageDependency;
	import com.apm.data.project.ProjectDefinition;
	import com.apm.data.project.ProjectLock;
	import com.apm.utils.FileUtils;
	import com.apm.utils.PackageFileUtils;
	
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	
	
	public class InstallCommand extends EventDispatcher implements Command
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
			return false;
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
					"apm install                          install all the dependencies in your project\n" +
					"apm install <foo>                    install the <foo> dependency to your project\n" +
					"apm install <foo> <version>          install a specific <version> of the <foo> dependency to your project\n" +
					"apm install <path/local.airpackage>  install a local airpackage at the specified path\n" +
					"\n" +
					"options: \n" +
					"  --include-prerelease               includes pre-release package versions in the search"
					;
		}
		
		
		public function execute():void
		{
			var project:ProjectDefinition = APM.config.projectDefinition;
			if (project == null)
			{
				dispatchEvent( new CommandEvent( CommandEvent.COMPLETE, APM.CODE_ERROR ) );
				return;
			}
			var lockFile:ProjectLock = APM.config.projectLock;
			
			_installData = new InstallData();
			_queue = new ProcessQueue();
			
			var packageIdentifierOrPath:String = null;
			if (_parameters != null && _parameters.length > 0)
			{
				packageIdentifierOrPath = _parameters[ 0 ];
				
				var version:String = (_parameters.length > 1) ? _parameters[ 1 ] : "latest";
				
				// Check if ends in "airpackage"
				if (packageIdentifierOrPath.indexOf( PackageFileUtils.AIRPACKAGEEXTENSION ) ==
						packageIdentifierOrPath.length - PackageFileUtils.AIRPACKAGEEXTENSION.length)
				{
					// Install from a local air package file
					var localPackageFile:File = FileUtils.getSourceForPath( packageIdentifierOrPath );
					if (localPackageFile.exists)
					{
						_queue.addProcess(
								new InstallLocalPackageProcess(
										localPackageFile,
										_installData
								)
						);
					}
					else
					{
						APM.io.writeLine( "Could not locate local package : " + packageIdentifierOrPath );
						dispatchEvent( new CommandEvent( CommandEvent.COMPLETE, APM.CODE_ERROR ) );
						return;
					}
				}
				else
				{
					//	Install from repository
					var request:InstallRequest = new InstallRequest(
							packageIdentifierOrPath,
							version,
							null,
							null,
							true
					);
					
					if (request.semVer == null && request.version != "latest")
					{
						// Invalid version passed
						APM.io.writeLine( "Invalid version code : " + request.version );
						dispatchEvent( new CommandEvent( CommandEvent.COMPLETE, APM.CODE_ERROR ) );
						return;
					}
					
					switch (ProjectDefinitionValidator.checkPackageAlreadyInstalled( project, request ))
					{
						case ProjectDefinitionValidator.NOT_INSTALLED:
							// not installed
							break;
						
						case ProjectDefinitionValidator.ALREADY_INSTALLED:
							APM.io.writeLine( "Already installed: " + request.packageIdentifier + " >= " + request.version.toString() );
							dispatchEvent( new CommandEvent( CommandEvent.COMPLETE, APM.CODE_OK ) );
							return;
						
						case ProjectDefinitionValidator.UNKNOWN_LATEST_REQUESTED:
							// exists but requesting latest
							break;
						
						case ProjectDefinitionValidator.HIGHER_VERSION_REQUESTED:
							// To upgrade we first uninstall then continue with the install
							_queue.addProcessToStart( new UninstallPackageProcess( packageIdentifierOrPath, packageIdentifierOrPath, null ) );
							break;
					}
					
					// Install
					_queue.addProcess(
							new InstallQueryPackageProcess(
									_installData,
									request
							)
					);
				}
				
			}
			
			// Add definitions stored in the current lock file
			if (lockFile != null)
			{
				for each (var pd:InstallPackageData in lockFile.dependencies)
				{
					_installData.addPackage(
							pd.packageVersion,
							pd.request
					);
				}
			}
			
			// Add any project dependencies that haven't been processed previously
			// (may have been manually added or not installed yet)
			if (project.dependencies.length > 0)
			{
				// Install from list in project file
				for each (var dep:PackageDependency in project.dependencies)
				{
					if (!_installData.containsPackage( dep.identifier ))
					{
						_queue.addProcess(
								new InstallQueryPackageProcess(
										_installData,
										new InstallRequest(
												dep.identifier,
												dep.version.toString(),
												dep.source
										)
								)
						);
					}
				}
			}
			
			_queue.start(
					function ():void
					{
						_queue.addProcess( new InstallDataValidationProcess( _installData ) );
						_queue.start(
								function ():void
								{
									dispatchEvent( new CommandEvent( CommandEvent.COMPLETE, APM.CODE_OK ) );
								},
								function ( error:String ):void
								{
									APM.io.writeError( name, error );
									dispatchEvent( new CommandEvent( CommandEvent.COMPLETE, APM.CODE_ERROR ) );
								}
						);
					},
					function ( error:String ):void
					{
						dispatchEvent( new CommandEvent( CommandEvent.COMPLETE, APM.CODE_ERROR ) );
					}
			);
		}
		
	}
	
}
