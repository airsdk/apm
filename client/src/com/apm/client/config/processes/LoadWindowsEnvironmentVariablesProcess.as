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
	
	
	public class LoadWindowsEnvironmentVariablesProcess extends ProcessBase
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "LoadWindowsEnvironmentVariablesProcess";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _process:NativeProcess;
		
		private var _environmentVariables:Object;
		private var _config:RunConfig;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function LoadWindowsEnvironmentVariablesProcess( config:RunConfig )
		{
			_environmentVariables = {};
			_config = config;
		}
		
		
		override public function start( completeCallback:Function = null, failureCallback:Function = null ):void
		{
			super.start( completeCallback, failureCallback );
			Log.d( TAG, "start()" );
			if (NativeProcess.isSupported)
			{
				var processStartupInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
				processStartupInfo.executable = new File( "C:\\Windows\\System32\\cmd.exe" );

				var processArgs:Vector.<String> = new Vector.<String>();
				processArgs.push( "/c" );
				processArgs.push( "set" );

				processStartupInfo.arguments = processArgs;
				
				if (!processStartupInfo.executable.exists)
				{
					// TODO:: Error?
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
				Log.d( TAG, "ERROR: Native process not supported - cannot get environment" );
				complete();
			}
		}
		
		
		private function onOutputData( event:ProgressEvent ):void
		{
			var data:String = _process.standardOutput.readUTFBytes( _process.standardOutput.bytesAvailable );
			processEnvironmentVariables( data );
		}
		
		
		private function onErrorData( event:ProgressEvent ):void
		{
			Log.d( TAG, "ERROR: " + _process.standardError.readUTFBytes( _process.standardError.bytesAvailable ) );
		}
		
		
		private function onExit( event:NativeProcessExitEvent ):void
		{
			Log.d( TAG, "Process exited with: " + event.exitCode );
			
			for (var key:String in _environmentVariables)
			{
				_config.env[ key ] = _environmentVariables[ key ];
			}
			
			complete();
		}
		
		
		private function onIOError( event:IOErrorEvent ):void
		{
			Log.d( TAG, "IOError: " + event.toString() );
		}
		
		
		//
		//
		//
		
		private function processEnvironmentVariables( data:String ):void
		{
			var lines:Array = data.replace( "\r", "" ).split( "\n" );
			for each (var line:String in lines)
			{
				var envVar:Array = line.split( "=" );
				if (envVar.length == 2)
				{
					_environmentVariables[ envVar[ 0 ] ] = envVar[ 1 ];
				}
			}
		}
		
	}
	
}
