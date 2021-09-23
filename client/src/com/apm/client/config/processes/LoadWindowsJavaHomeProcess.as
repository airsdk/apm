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
	import com.apm.client.processes.ProcessBase;
	
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.IOErrorEvent;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	
	
	public class LoadWindowsJavaHomeProcess extends ProcessBase
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "LoadWindowsJavaHomeProcess";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _config:RunConfig;
		private var _data:String = "";
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function LoadWindowsJavaHomeProcess( config:RunConfig )
		{
			_config = config;
		}
		
		
		private function isJavaHomeValid():Boolean
		{
			try
			{
				if (_config.env[ "JAVA_HOME" ] == null) return false;
				if (_config.getJava().exists)
					return true;
			}
			catch (e:Error)
			{
			}
			return false;
		}
		
		
		override public function start( completeCallback:Function = null, failureCallback:Function = null ):void
		{
			super.start( completeCallback, failureCallback );
			Log.d( TAG, "start()" );
			
			if (!isJavaHomeValid())
			{
				var javaBinPath:String = "bin\\java.exe";
				var javaHome:String = null;
				
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
				
				if (javaHome != null)
				{
					_config.env[ "JAVA_HOME" ] = javaHome;
				}
				complete();
				
				
			}
			else
			{
				complete();
			}
		}
		
		
	}
	
}
