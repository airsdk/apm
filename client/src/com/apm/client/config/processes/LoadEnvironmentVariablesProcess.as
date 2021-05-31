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
package com.apm.client.config.processes
{
	import com.apm.client.logging.Log;
	import com.apm.client.processes.Process;
	import com.apm.client.processes.events.ProcessEvent;
	
	import flash.events.EventDispatcher;
	import flash.utils.setTimeout;
	
	
	public class LoadEnvironmentVariablesProcess extends EventDispatcher implements Process
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "LoadEnvironmentVariablesProcess";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function LoadEnvironmentVariablesProcess()
		{
		}
		
		
		public function start():void
		{
			Log.d( TAG, "start()" );
			
			dispatchEvent( new ProcessEvent( ProcessEvent.COMPLETE ))
		}
		
		
	}
	
}
