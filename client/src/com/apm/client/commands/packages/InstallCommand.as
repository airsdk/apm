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
	import com.apm.client.APMCore;
	import com.apm.client.commands.Command;
	import com.apm.client.commands.packages.processes.InstallPackageProcess;
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
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function InstallCommand()
		{
			super();
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
//			core.io.writeLine( "installing : " +
//									   (_parameters != null && _parameters.length > 0 ? _parameters[0] : "...")
//			);
			
			var project:ProjectDefinition = core.config.projectDefinition;
			if (project == null)
			{
				core.io.writeLine( "ERROR: project definition not found" );
				return core.exit( APMCore.CODE_ERROR );
			}
			
			if (_parameters != null && _parameters.length > 0)
			{
				// Install
				var packageIdentifier:String = _parameters[ 0 ];
				var version:String = (_parameters.length > 1) ? _parameters[ 1 ] : "latest";
				
				_queue.addProcess( new InstallPackageProcess( core, packageIdentifier, version ) );
			}
			else if (project.dependencies.length > 0)
			{
				// Install from list in project file
				for (var i:int = 0; i < project.dependencies.length; i++)
				{
					_queue.addProcess(
							new InstallPackageProcess(
									core,
									project.dependencies[ i ].identifier,
									project.dependencies[ i ].version.toString()
							)
					);
				}
			}
			else
			{
			
			}
			
			_queue.start( function ():void {
				
				core.exit( APMCore.CODE_OK );
				
			} );
			
			
		}
		
	}
	
}
