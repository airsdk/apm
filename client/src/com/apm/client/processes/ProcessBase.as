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
 * @created		15/6/21
 */
package com.apm.client.processes
{
	import com.apm.client.processes.events.ProcessEvent;
	
	import flash.events.EventDispatcher;
	
	
	public class ProcessBase extends EventDispatcher implements Process
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "ProcessBase";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		protected var _queue:ProcessQueue;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function ProcessBase()
		{
		}
		
		
		public function start():void
		{
			throw new Error( "Not implemented" );
		}
		
		
		public function set queue( value:ProcessQueue ):void
		{
			_queue = value;
		}
		
		
		protected function complete():void
		{
			dispatchEvent( new ProcessEvent( ProcessEvent.COMPLETE ) );
		}
		
		
		protected function failure( error:String = "" ):void
		{
			dispatchEvent( new ProcessEvent( ProcessEvent.FAILED, error ) );
		}
		
	}
	
}
