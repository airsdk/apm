/**
 * @author 		Michael Archbold (https://michaelarchbold.com)
 * @created		18/5/2021
 */
package com.apm.client.commands.packages
{
	import com.apm.client.APM;
	import com.apm.client.commands.Command;
	import com.apm.client.commands.packages.processes.ViewPackageProcess;
	import com.apm.client.events.CommandEvent;
	import com.apm.client.processes.ProcessQueue;
	
	import flash.events.EventDispatcher;
	
	
	public class ViewCommand extends EventDispatcher implements Command
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
		
		
		public function get requiresProject():Boolean
		{
			return false;
		}
		
		
		public function get description():String
		{
			return "search for a dependency in the repository";
		}
		
		
		public function get usage():String
		{
			return description + "\n" +
				   "\n" +
				   "apm view <foo>           view information of a package called <foo> in the repository\n" +
				   "\n" +
				   "options: \n" +
				   "  --include-prerelease   includes pre-release package versions in the search"
					;
		}
		
		
		public function execute():void
		{
			if (_parameters == null || _parameters.length == 0)
			{
				APM.io.writeLine( "No search params provided" );
				dispatchEvent( new CommandEvent( CommandEvent.COMPLETE, APM.CODE_ERROR ) );
				return;
			}
			
			var identifier:String = _parameters[ 0 ];
			
			_queue.addProcess( new ViewPackageProcess( identifier ) );
			_queue.start( function ():void
						  {
							  dispatchEvent( new CommandEvent( CommandEvent.COMPLETE, APM.CODE_OK ) );
						  },
						  function ( message:String ):void
						  {
							  dispatchEvent( new CommandEvent( CommandEvent.COMPLETE, APM.CODE_ERROR ) );
						  }
			);
		}
		
	}
	
}
