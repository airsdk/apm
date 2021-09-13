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
 * @created		31/5/21
 */
package com.apm.client.processes
{
	import com.apm.client.logging.Log;
	import com.apm.client.processes.events.ProcessEvent;
	
	import flash.events.EventDispatcher;
	import flash.utils.getQualifiedClassName;
	
	
	public class ProcessQueue extends EventDispatcher
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "ProcessQueue";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _queue:Array;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function ProcessQueue()
		{
			_queue = [];
		}
		
		
		public function addProcess( process:Process ):ProcessQueue
		{
			_queue.push( process );
			return this;
		}
		
		
		public function addProcessToStart( process:Process ):ProcessQueue
		{
			_queue.unshift( process );
			return this;
		}
		
		
		public function addCallback( callback:Function ):ProcessQueue
		{
			_queue.push( new ProcessCallback( callback ) );
			return this;
		}
		
		
		public function addCallbackToStart( callback:Function ):ProcessQueue
		{
			_queue.unshift( new ProcessCallback( callback ) );
			return this;
		}
		
		
		private var _processing:Boolean = false;
		private var _completeCallback:Function = null;
		private var _failedCallback:Function = null;
		
		
		public function start( complete:Function, failed:Function = null ):void
		{
			if (_processing) return;
			_processing = true;
			_completeCallback = complete;
			_failedCallback = failed;
			
			checkAndStartNextProcess();
		}
		
		
		public function get length():Number
		{
			return _queue.length;
		}
		
		
		public function clear():void
		{
			_queue = [];
		}
		
		
		//
		//
		//
		
		private var _currentProcess:Process;
		
		
		private function checkAndStartNextProcess():void
		{
			Log.d( TAG, "checkAndStartNextProcess(): " + _queue.length );
			if (_queue.length == 0)
			{
				// Reached end of queue
				_processing = false;
				dispatchEvent( new ProcessEvent( ProcessEvent.COMPLETE ) );
				if (_completeCallback != null)
				{
					var callback:Function = _completeCallback;
					_completeCallback = null;
					callback();
				}
				return;
			}
			
			// Start next process
			_currentProcess = _queue.shift();
			
			try
			{
				_currentProcess.addEventListener( ProcessEvent.COMPLETE, process_eventHandler );
				_currentProcess.addEventListener( ProcessEvent.FAILED, process_eventHandler );
				_currentProcess.processQueue = this;
				_currentProcess.start();
			}
			catch (e:Error)
			{
				Log.d( TAG, "UNHANDLED PROCESS ERROR IN " + getQualifiedClassName(_currentProcess) );
				Log.e( TAG, e );
				
				process_eventHandler( new ProcessEvent( ProcessEvent.FAILED, e.message ) );
			}
			
		}
		
		
		private function process_eventHandler( event:ProcessEvent ):void
		{
			Log.d( TAG, "process_eventHandler( " + event.type + " )" );
			_currentProcess.removeEventListener( ProcessEvent.COMPLETE, process_eventHandler );
			_currentProcess.removeEventListener( ProcessEvent.FAILED, process_eventHandler );
			
			switch (event.type)
			{
				case ProcessEvent.COMPLETE:
				{
					checkAndStartNextProcess();
					break;
				}
				
				case ProcessEvent.FAILED:
				{
					// If a process fails, we clear the queue and terminate the processes
					// If there is no specific failed callback just trigger the normal complete
					clear();
					if (_failedCallback != null)
					{
						_failedCallback( event.data );
						_failedCallback = null;
					}
					else
					{
						checkAndStartNextProcess();
					}
					break;
				}
			}
			
		}
		
		
	}
}
