/**
 * @author 		Michael Archbold (https://michaelarchbold.com)
 * @created		15/6/2021
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
		
		
		public function get processQueue():ProcessQueue { return _queue; }
		
		
		public function set processQueue( value:ProcessQueue ):void { _queue = value; }
		
		
		protected var _completeCallback:Function;
		protected var _failureCallback:Function;
		
		private var _finished:Boolean = false;
		
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function ProcessBase()
		{
		}
		
		
		public function start( completeCallback:Function = null, failureCallback:Function = null ):void
		{
			_completeCallback = completeCallback;
			_failureCallback = failureCallback;
		}
		
		
		protected function complete( data:Object = null ):void
		{
			if (!_finished)
			{
				_finished = true;
				if (_completeCallback) _completeCallback( data );
				dispatchEvent( new ProcessEvent( ProcessEvent.COMPLETE ) );
			}
		}
		
		
		protected function failure( error:String = "" ):void
		{
			if (!_finished)
			{
				_finished = true;
				if (_failureCallback) _failureCallback();
				dispatchEvent( new ProcessEvent( ProcessEvent.FAILED, error ) );
			}
		}
		
	}
	
}
