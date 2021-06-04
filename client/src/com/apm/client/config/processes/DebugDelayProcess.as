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
 * @created		4/6/21
 */
package com.apm.client.config.processes
{
	import com.apm.client.processes.Process;
	import com.apm.client.processes.events.ProcessEvent;
	
	import flash.events.EventDispatcher;
	import flash.utils.setTimeout;
	
	
	public class DebugDelayProcess extends EventDispatcher implements Process
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "DebugDelayProcess";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _delay : int;
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function DebugDelayProcess( delay:int=2000 )
		{
			_delay = delay;
		}
		
		
		public function start():void
		{
			setTimeout( function():void {
				dispatchEvent( new ProcessEvent( ProcessEvent.COMPLETE ));
			}, _delay );
		}
		
	}
	
}
