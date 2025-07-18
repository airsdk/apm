/**
 * @author 		Michael Archbold (https://michaelarchbold.com)
 * @created		16/7/2021
 */
package com.apm.client.commands.packages
{
	import com.apm.client.APM;
	import com.apm.client.commands.Command;
	import com.apm.client.commands.packages.processes.InstallDataValidationProcess;
	import com.apm.client.commands.packages.processes.InstallQueryPackageProcess;
	import com.apm.client.events.CommandEvent;
	import com.apm.client.processes.ProcessQueue;
	import com.apm.client.processes.upgrade.UpgradeClientProcess;
	import com.apm.data.install.InstallData;
	import com.apm.data.install.InstallRequest;
	import com.apm.data.project.ProjectDefinition;

	import flash.events.EventDispatcher;

	public class UpdateCommand extends EventDispatcher implements Command
	{

		////////////////////////////////////////////////////////
		//  CONSTANTS
		//

		private static const TAG:String = "UpdateCommand";


		public static const NAME:String = "update";


		////////////////////////////////////////////////////////
		//  VARIABLES
		//

		private var _parameters:Array;
		private var _queue:ProcessQueue;
		private var _installData:InstallData;


		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//

		public function UpdateCommand()
		{
			super();
			_installData = new InstallData();
			_queue       = new ProcessQueue();
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
			// Technically true, but false to allow updating of apm from anywhere
			return false;
		}


		public function get description():String
		{
			return "update the installed packages in your project";
		}


		public function get usage():String
		{
			return description + "\n" +
					"\n" +
					"apm update apm           check for a new release of the apm client and update if available\n" +
					"apm update               update all dependencies in your project\n" +
					"apm update <foo>         update the <foo> dependency in your project\n";
		}


		public function setParameters( parameters:Array ):void
		{
			_parameters = parameters;
		}


		public function execute():void
		{
			var packageIdentifier:String = null;
			if (_parameters != null && _parameters.length > 0)
			{
				packageIdentifier = _parameters[0];
			}

			if (packageIdentifier == "apm")
			{
				// Unique condition to update client
				_queue.addProcess( new UpgradeClientProcess() );
				_queue.start(
						function ():void
						{
							dispatchEvent( new CommandEvent( CommandEvent.COMPLETE, APM.CODE_OK ) );
						},
						function ( message:String ):void
						{
							dispatchEvent( new CommandEvent( CommandEvent.COMPLETE, APM.CODE_ERROR ) );
						}
				);
			}
			else
			{
				var project:ProjectDefinition = APM.config.projectDefinition;
				if (project == null)
				{
					APM.io.writeError( "project.apm", "No project file found, run 'apm init' first" );
					dispatchEvent( new CommandEvent( CommandEvent.COMPLETE, APM.CODE_ERROR ) );
					return;
				}

				if (project.dependencies.length > 0)
				{
					var updateRequired:Boolean = false;
					// Install from list in project file
					for (var i:int = 0; i < project.dependencies.length; i++)
					{
						if ((packageIdentifier == null || packageIdentifier == project.dependencies[i].identifier)
								&& project.dependencies[i].source != "file")
						{
							updateRequired = true;
							_queue.addProcess(
									new InstallQueryPackageProcess(
											_installData,
											new InstallRequest(
													project.dependencies[i].identifier,
													"latest",
													project.dependencies[i].source
											),
											false
									)
							);
						}
						else
						{
							_queue.addProcess(
									new InstallQueryPackageProcess(
											_installData,
											new InstallRequest(
													project.dependencies[i].identifier,
													project.dependencies[i].version.toString(),
													project.dependencies[i].source
											),
											false
									)
							);
						}
					}
				}

				if (_queue.length == 0 || !updateRequired)
				{
					APM.io.writeLine( "Nothing to update - check the package identifier is correct" );
					dispatchEvent( new CommandEvent( CommandEvent.COMPLETE, APM.CODE_OK ) );
					return;
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
									function ( message:String ):void
									{
										dispatchEvent( new CommandEvent( CommandEvent.COMPLETE, APM.CODE_ERROR ) );
									} );
						},
						function ( error:String ):void
						{
							dispatchEvent( new CommandEvent( CommandEvent.COMPLETE, APM.CODE_ERROR ) );
						} );
			}

		}

	}

}
