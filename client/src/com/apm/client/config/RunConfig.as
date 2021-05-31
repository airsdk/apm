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
package com.apm.client.config
{
	import com.apm.client.config.processes.LoadEnvironmentVariablesProcess;
	import com.apm.client.config.processes.LoadProjectDefinitionProcess;
	import com.apm.client.logging.Log;
	import com.apm.client.processes.ProcessQueue;
	import com.apm.data.ProjectDefinition;
	
	
	/**
	 * Runtime configuration, includes environment variables, paths
	 * and any global command line arguments
	 */
	public class RunConfig
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "RunConfig";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _loadEnvironmentQueue:ProcessQueue;
		
		
		// Controls the logging output
		public var logLevel:int = 0;
		
		//
		public var workingDir:String;
		
		//
		public var projectDefinition:ProjectDefinition;
		
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function RunConfig()
		{
		}
		
		
		/**
		 * This function loads any configuration / environment files and settings
		 * and is called before any commands are executed.
		 *
		 * @param callback
		 */
		public function loadEnvironment( callback:Function ):void
		{
			Log.d( TAG, "loadEnvironment()" );
			
			_loadEnvironmentQueue = new ProcessQueue();
			
			_loadEnvironmentQueue.addProcess( new LoadEnvironmentVariablesProcess() )
			_loadEnvironmentQueue.addProcess( new LoadProjectDefinitionProcess( this ) )
			
			_loadEnvironmentQueue.start( function ():void {
				callback();
			} );
		}
		
		
	}
	
}
