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
	import com.apm.client.commands.packages.processes.ViewPackageProcess;
	import com.apm.client.processes.ProcessQueue;
	import com.apm.data.PackageDefinition;
	import com.apm.remote.repository.RepositoryAPI;
	
	
	public class ViewCommand implements Command
	{
		
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "ViewCommand";
		
		
		public static const NAME:String = "view";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _parameters:Array;
		private var _queue:ProcessQueue;
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function ViewCommand()
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
			return "search for a dependency in the repository";
		}
		
		
		public function get usage():String
		{
			return  description + "\n" +
					"\n" +
					"apm search <foo>    search for a dependency called <foo> in the repository\n";
		}
		
		
		public function execute( core:APMCore ):void
		{
			if (_parameters == null && _parameters.length == 0)
			{
				core.io.writeLine( "No search params provided" );
				return core.exit( APMCore.CODE_ERROR );
			}
			
			var identifier:String = _parameters[0];

			_queue.addProcess( new ViewPackageProcess( core, identifier ) );
			_queue.start( function():void {
				core.exit( APMCore.CODE_OK );
			});
		}
		
	}
	
}
