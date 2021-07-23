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
	import com.apm.client.commands.packages.processes.UninstallPackageProcess;
	import com.apm.client.processes.ProcessQueue;
	import com.apm.data.project.ProjectDefinition;
	
	
	public class UninstallCommand implements Command
	{
		
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "UninstallCommand";
		
		
		public static const NAME:String = "uninstall";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _parameters:Array;
		private var _queue:ProcessQueue;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function UninstallCommand()
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
			return false;
		}
		
		
		public function get requiresProject():Boolean
		{
			return true;
		}
		
		
		public function get description():String
		{
			return "remove a dependency from your project";
		}
		
		
		public function get usage():String
		{
			return description + "\n" +
					"\n" +
					"apm uninstall <foo>            uninstall the <foo> dependency to your project\n";
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
				_queue.addProcess( new UninstallPackageProcess( core, packageIdentifier, packageIdentifier ) );
			}
			
			
			if (_queue.length == 0)
			{
				core.io.writeLine( "Nothing to uninstall" );
				return core.exit( APMCore.CODE_OK )
			}
			
			_queue.start(
					function ():void {
						core.exit( APMCore.CODE_OK );
					},
					function ( error:String ):void {
						core.exit( APMCore.CODE_ERROR );
					} );
			
		}
		
	}
	
}
