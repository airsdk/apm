/**
 * @author 		Michael Archbold (https://michaelarchbold.com)
 * @created		28/5/2021
 */
package com.apm.client.processes
{
	import flash.events.IEventDispatcher;
	
	
	public interface Process extends IEventDispatcher
	{
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		/**
		 * Will set the current queue before start so the process can add additional processes if required.
		 *
		 * @param value
		 */
		function set processQueue( value:ProcessQueue ):void;
		
		
		/**
		 * Will be called when the process should start running.
		 * The process must dispatch a ProcessEvent.COMPLETE function when complete.
		 */
		function start( complete:Function=null, failure:Function=null ):void;
		
		
	}
	
}
