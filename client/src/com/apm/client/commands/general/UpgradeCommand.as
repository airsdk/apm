/**
 * @author 		Michael Archbold (https://michaelarchbold.com)
 * @created		18/5/2021
 */
package com.apm.client.commands.general
{
	import com.apm.client.APM;
	import com.apm.client.commands.Command;
	import com.apm.client.events.CommandEvent;
	import com.apm.client.processes.ProcessQueue;
	import com.apm.client.processes.upgrade.UpgradeClientProcess;
	
	import flash.events.EventDispatcher;
	
	
	public class UpgradeCommand extends EventDispatcher implements Command
	{
		
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "UpgradeCommand";
		
		
		public static const NAME:String = "upgrade";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _parameters:Array;
		private var _queue:ProcessQueue;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function UpgradeCommand()
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
			return "print apm version information";
		}
		
		
		public function get usage():String
		{
			return description + " \n" +
					"\n" +
					"apm upgrade     checks for the latest version of apm and attempts to install it if available";
		}
		
		
		public function execute():void
		{
			_queue.addProcess( new UpgradeClientProcess() );
			_queue.start( function ():void {
				dispatchEvent( new CommandEvent( CommandEvent.COMPLETE, APM.CODE_OK ) );
			} );
			
		}
		
		
	}
	
}
