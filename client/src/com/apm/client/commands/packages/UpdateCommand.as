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
 * @created		16/7/2021
 */
package com.apm.client.commands.packages
{
	import com.apm.client.APMCore;
	import com.apm.client.commands.Command;
	import com.apm.client.commands.packages.data.InstallData;
	import com.apm.client.commands.packages.data.InstallQueryRequest;
	import com.apm.client.commands.packages.processes.InstallDataValidationProcess;
	import com.apm.client.commands.packages.processes.InstallQueryPackageProcess;
	import com.apm.client.processes.ProcessQueue;
	import com.apm.data.project.ProjectDefinition;
	
	
	public class UpdateCommand implements Command
	{
		
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "UpdateCommand";
		
		
		public static const NAME:String = "update";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		
		public function UpdateCommand()
		{
			super();
			_installData = new InstallData();
			_queue = new ProcessQueue();
		}
		
		
		private var _parameters:Array;
		private var _queue:ProcessQueue;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		private var _installData:InstallData;
		
		
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
			return "update the installed packages in your project";
		}
		
		
		public function get usage():String
		{
			return description + "\n" +
					"\n" +
					"apm update               update all dependencies in your project\n" +
					"apm update <foo>         update the <foo> dependency in your project\n";
		}
		
		
		public function setParameters( parameters:Array ):void
		{
			_parameters = parameters;
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
											"latest"
									),
									false
							)
					);
				}
			}
			
			if (_queue.length == 0)
			{
				core.io.writeLine( "Nothing to update" );
				return core.exit( APMCore.CODE_OK )
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
