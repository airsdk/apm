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
	import com.apm.client.config.processes.DebugDelayProcess;
	import com.apm.client.config.processes.LoadMacOSEnvironmentVariablesProcess;
	import com.apm.client.config.processes.LoadProjectDefinitionProcess;
	import com.apm.client.config.processes.LoadWindowsEnvironmentVariablesProcess;
	import com.apm.client.logging.Log;
	import com.apm.client.processes.ProcessQueue;
	import com.apm.data.ProjectDefinition;
	
	import flash.system.Capabilities;
	
	
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
		
		private var _loadQueue:ProcessQueue;
		
		
		// The current working directory
		public var workingDir:String;
		
		// The current project definition file
		public var projectDefinition:ProjectDefinition = null;
		
		// Loaded environment variables
		public var env:Object = {};
		
		
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
			
			_loadQueue = new ProcessQueue();
			
			// Platform specific
			if (isMacOS)
			{
				_loadQueue.addProcess( new LoadMacOSEnvironmentVariablesProcess( this ) );
			}
			if (isWindows)
			{
				_loadQueue.addProcess( new LoadWindowsEnvironmentVariablesProcess( this ) );
			}
			
			
			// General
			_loadQueue.addProcess( new LoadProjectDefinitionProcess( this ) );
			_loadQueue.addProcess( new DebugDelayProcess( 3000 ) );
			
			_loadQueue.start( function ():void {
				if (callback != null)
					callback( true );
			} );
		}
		
		
		//
		//	UTILITIES
		//
		
		public static function get os():String
		{
			if ((Capabilities.os.indexOf( "Windows" ) >= 0))
			{
				return "windows";
			}
			else if ((Capabilities.os.indexOf( "Mac" ) >= 0))
			{
				return "macos";
			}
			return "";
		}
		
		
		public function get isMacOS():Boolean
		{
			return os == "macos";
		}
		
		
		public function get isWindows():Boolean
		{
			return os == "windows";
		}
		
		
	}
	
}
