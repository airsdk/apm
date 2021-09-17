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
	import com.apm.client.config.processes.LoadMacOSJavaHomeProcess;
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
		
		public static const DEFAULT_REPOSITORY_URL:String = "https://repository.airsdk.dev";
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _loadQueue:ProcessQueue;
		
		
		// The current working directory
		public var workingDir:String = File.workingDirectory.nativePath;
		
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
		public function loadEnvironment( callback:Function, checkNetwork:Boolean = false ):void
		{
			Log.d( TAG, "loadEnvironment()" );
			
			_loadQueue = new ProcessQueue();
			
			// Platform specific
			if (isMacOS)
			{
				_loadQueue.addProcess( new LoadMacOSEnvironmentVariablesProcess( this ) );
				_loadQueue.addProcess( new LoadMacOSJavaHomeProcess( this ) );
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

		
		/**
		 * Attempts to find a java executable in the system.
		 *
		 * @return  A <code>File</code> reference to java executable
		 */
		public function getJava():File
		{
			var javaHome:String = env[ "JAVA_HOME" ];
			var javaBinPath:String;
			try
			{
				if (isWindows)
				{
					javaBinPath = "bin\\java.exe";
					if (javaHome == null)
					{
						// Try to locate a java install
						// Normally have a directory "Java/jdkx.x.x_x"
						//  - so iterate over subdirectories checking for the java exe
						
						var javaDirectoryCandidates:Array = [
							new File( "C:\\Program Files\\Java" ),
							new File( "C:\\Program Files (x86)\\Java" )
						];
						
						for each (var candidate:File in javaDirectoryCandidates)
						{
							if (candidate.exists && candidate.getDirectoryListing().length > 0)
							{
								for each (var javaCandidate:File in candidate.getDirectoryListing())
								{
									if (javaCandidate.resolvePath( javaBinPath ).exists)
									{
										javaHome = javaCandidate.nativePath;
										break;
									}
								}
							}
						}
					}
				}
				else if (isMacOS)
				{
					javaBinPath = "bin/java";
//					if (javaHome == null)
//					{
//						// Try default java install - this will likely fail
//						javaHome = "/usr";
//					}
				}
				else
				{
					javaBinPath = "bin/java";
					// TODO: Linux
				}
				
				var java:File = new File( javaHome ).resolvePath( javaBinPath );
				if (java.exists)
				{
					return java;
				}
			}
			catch (e:Error)
			{
				Log.l( TAG, "ERROR: Failed to find " + javaBinPath );
				Log.e( TAG, e );
			}
			
			throw new Error( "Failed to find '" + javaBinPath + "' in JAVA_HOME=" + javaHome
									 + ". Point JAVA_HOME to your java installation." );
		}
		
		
		public function getDefaultRemoteRepositoryEndpoint():String
		{
			if (env["APM_REPOSITORY"])
			{
				Log.d( TAG, "Using custom apm repository: " + env["APM_REPOSITORY"] );
				return env["APM_REPOSITORY"];
			}
			return DEFAULT_REPOSITORY_URL;
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
			// TODO:: Linux
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
