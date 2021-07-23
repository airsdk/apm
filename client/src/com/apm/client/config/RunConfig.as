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
	import com.apm.client.config.processes.LoadMacOSEnvironmentVariablesProcess;
	import com.apm.client.config.processes.LoadProjectDefinitionProcess;
	import com.apm.client.config.processes.LoadUserSettingsProcess;
	import com.apm.client.config.processes.LoadWindowsEnvironmentVariablesProcess;
	import com.apm.client.logging.Log;
	import com.apm.client.processes.ProcessQueue;
	import com.apm.data.project.ProjectDefinition;
	import com.apm.data.user.UserSettings;
	
	import flash.filesystem.File;
	
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
		
		
		// The directory for package storage (apm_packages)
		public function get packagesDir():String { return workingDir + File.separator + "apm_packages"; }
		
		
		// The current project definition file
		public var projectDefinition:ProjectDefinition = null;
		
		// Loaded environment variables
		public var env:Object = {};
		
		// Settings loaded from the users' home directory
		public var user:UserSettings;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function RunConfig()
		{
			user = new UserSettings();
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
			_loadQueue.addProcess( new LoadUserSettingsProcess( this ) );
//			_loadQueue.addProcess( new DebugDelayProcess( 3000 ) );
			
			_loadQueue.start(
					function ():void {
						if (callback != null)
							callback( true );
					},
					function ( error:String ):void {
						if (callback != null)
							callback( false, error );
					} );
		}
		
		
		public function getHomeDirectory():String
		{
			if (isMacOS)
			{
				if (env.hasOwnProperty( "HOME" ))
					return env.HOME;
				else
					return "~";
			}
			else
			{
				return File.userDirectory.nativePath;
			}
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
