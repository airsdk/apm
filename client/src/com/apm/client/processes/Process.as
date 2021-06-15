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
 * @created		28/5/21
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
		function set queue( value:ProcessQueue ):void;
		
		
		/**
		 * Will be called when the process should start running.
		 * The process must dispatch a ProcessEvent.COMPLETE function when complete.
		 */
		function start():void;
		
		
	}
	
}
