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
	import com.apm.client.config.RunConfig;
	import com.apm.client.logging.Log;
	import com.apm.client.processes.Process;
	import com.apm.client.processes.events.ProcessEvent;
	
	import flash.events.EventDispatcher;
	
	
	public class LoadWindowsEnvironmentVariablesProcess extends EventDispatcher implements Process
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "LoadWindowsEnvironmentVariablesProcess";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _config:RunConfig;
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function LoadWindowsEnvironmentVariablesProcess( config:RunConfig )
		{
			_config = config;
		}
		
		
		public function start():void
		{
			Log.d( TAG, "start()" );
			// TODO
			dispatchEvent( new ProcessEvent( ProcessEvent.COMPLETE ) )
		}
		
		
	}
	
}
