/**
 * @author 		Michael Archbold (https://michaelarchbold.com)
 * @created		28/5/2021
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
	
	
	public class LoadMacOSJavaHomeProcess extends ProcessBase
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "LoadMacOSJavaHomeProcess";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _process:NativeProcess;
		
		private var _environmentVariables:Object;
		private var _config:RunConfig;
		private var _data:String = "";
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function LoadMacOSJavaHomeProcess( config:RunConfig )
		{
			_environmentVariables = {};
			_config = config;
		}
		
		
		private function isJavaHomeValid():Boolean
		{
			try
			{
				if (_config.env[ "JAVA_HOME" ] == null) return false;
				if (_config.env[ "JAVA_HOME" ] == "/usr") return false;
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
				if (NativeProcess.isSupported)
				{
					var processStartupInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
					processStartupInfo.executable = new File( "/usr/libexec/java_home" );
					
					if (!processStartupInfo.executable.exists)
					{
						complete();
					}
					
					_process = new NativeProcess();
					_process.addEventListener( NativeProcessExitEvent.EXIT, onExit );
					_process.addEventListener( ProgressEvent.STANDARD_OUTPUT_DATA, onOutputData );
					_process.addEventListener( ProgressEvent.STANDARD_ERROR_DATA, onErrorData );
					_process.addEventListener( IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, onIOError );
					_process.addEventListener( IOErrorEvent.STANDARD_ERROR_IO_ERROR, onIOError );
					
					_process.start( processStartupInfo );
				}
				else
				{
					Log.d( TAG, "ERROR: Native process not supported - cannot get java environment" );
					complete();
				}
			}
			else
			{
				complete();
			}
		}
		
		
		private function onOutputData( event:ProgressEvent ):void
		{
			_data += _process.standardOutput.readUTFBytes( _process.standardOutput.bytesAvailable )
					.replace( /\n/g, "" )
					.replace( /\r/g, "" )
					.replace( /\t/g, "" )
					.replace( / /g, "" );
			
			Log.d( TAG, _data );
		}
		
		
		private function onErrorData( event:ProgressEvent ):void
		{
			Log.d( TAG, "ERROR: " + _process.standardError.readUTFBytes( _process.standardError.bytesAvailable ) );
		}
		
		
		private function onExit( event:NativeProcessExitEvent ):void
		{
			Log.d( TAG, "Process exited with: " + event.exitCode );
			if (event.exitCode == 0)
			{
				_config.env[ "JAVA_HOME" ] = _data;
			}
			complete();
		}
		
		
		private function onIOError( event:IOErrorEvent ):void
		{
			Log.d( TAG, "IOError: " + event.toString() );
		}
		
		
	}
	
}
