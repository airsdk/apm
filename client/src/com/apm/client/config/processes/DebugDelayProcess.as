/**
 * @author 		Michael Archbold (https://michaelarchbold.com)
 * @created		4/6/2021
 */
package com.apm.client.config.processes
{
	import com.apm.client.processes.ProcessBase;
	import com.apm.client.processes.events.ProcessEvent;
	
	import flash.utils.setTimeout;
	
	
	public class DebugDelayProcess extends ProcessBase
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "DebugDelayProcess";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _delay:int;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function DebugDelayProcess( delay:int = 2000 )
		{
			_delay = delay;
		}
		
		
		override public function start( completeCallback:Function = null, failureCallback:Function = null ):void
		{
			super.start( completeCallback, failureCallback );
			setTimeout( complete, _delay );
		}
		
		
	}
	
}
