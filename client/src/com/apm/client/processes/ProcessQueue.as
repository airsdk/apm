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
	
	
	public class ProcessQueue extends EventDispatcher
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "ProcessQueue";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _queue : Array;
		
		
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
		

		private var _processing : Boolean = false;
		private var _completeCallback : Function = null;
		
		public function start( complete:Function ):void
		{
			if (_processing) return;
			_processing = true;
			_completeCallback = complete;
			
			checkAndStartNextProcess();
		}
		
		
		public function clear():void
		{
			_queue = [];
		}
		
		
		//
		//
		//
		
		private var _currentProcess : Process;
		
		private function checkAndStartNextProcess():void
		{
			Log.d( TAG, "checkAndStartNextProcess()" );
			if (_queue.length == 0)
			{
				// Reached end of queue
				dispatchEvent( new ProcessEvent( ProcessEvent.COMPLETE ));
				if (_completeCallback != null)
				{
					_completeCallback();
					_completeCallback = null;
				}
				return;
			}
			
			// Start next process
			_currentProcess = _queue.shift();
			
			try
			{
				_currentProcess.addEventListener( ProcessEvent.COMPLETE, process_completeHandler );
				_currentProcess.queue = this;
				_currentProcess.start();
			}
			catch (e:Error)
			{
				Log.e( TAG, e );
				process_completeHandler( null );
			}
			
		}
		
		
		private function process_completeHandler( event:ProcessEvent ):void
		{
			Log.d( TAG, "process_completeHandler()" );
			_currentProcess.removeEventListener( ProcessEvent.COMPLETE, process_completeHandler );
			
			checkAndStartNextProcess();
		}
		
		
		
		
		
	}
}
