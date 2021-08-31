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
