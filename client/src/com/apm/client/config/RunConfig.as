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
	import com.apm.client.config.processes.CheckNetworkProcess;
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
		
		// The application directory containing apm etc
		public var appDir:String = File.applicationDirectory.nativePath;
		
		// The directory for package storage (apm_packages)
		public function get packagesDir():String { return workingDir + File.separator + "apm_packages"; }
		
		
		// The current project definition file
		public var projectDefinition:ProjectDefinition = null;
		
		// Loaded environment variables
		public var env:Object = {};
		
		// Settings loaded from the users' home directory
		public var user:UserSettings;
		
		// Whether there is an active internet connection
		public var hasNetwork:Boolean = false;
		
		
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
		 * @param checkNetwork If true a check will be performed for an active network connection
		 */
		public function loadEnvironment( callback:Function, checkNetwork:Boolean=false ):void
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
			if (checkNetwork) _loadQueue.addProcess( new CheckNetworkProcess( this ) );
			
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
		
		
		public function getJava():File
		{
			var defaultJavaHome:String = isWindows ? "" : "/usr/";
			var javaHome:String = env[ "JAVA_HOME" ] || defaultJavaHome;
			Log.v(TAG, "using JAVA_HOME=" + javaHome);
			var binJavaPath:String = isWindows ? "bin\\java.exe" : "bin/java";
			try
			{
				return new File( javaHome ).resolvePath( binJavaPath );
			}
			catch ( e:Error ) {
				Log.l( TAG, "ERROR: Failed to find " + binJavaPath);
				Log.e( TAG, e );
				throw new Error( "Failed to find " + binJavaPath + " in JAVA_HOME=" + javaHome
					+ ". Point JAVA_HOME to your java installation." );
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
