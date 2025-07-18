/**
 * @author 		Michael Archbold (https://michaelarchbold.com)
 * @created		28/5/2021
 */
package com.apm.client.config.processes
{
	import com.apm.client.APM;
	import com.apm.client.config.RunConfig;
	import com.apm.client.logging.Log;
	import com.apm.client.processes.ProcessBase;
	import com.apm.utils.WindowsShellPaths;
	
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.Event;
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
		
		private var _data:String;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function LoadWindowsEnvironmentVariablesProcess( config:RunConfig )
		{
			_environmentVariables = {};
			_config = config;
			_data = "";
		}
		
		
		override public function start( completeCallback:Function = null, failureCallback:Function = null ):void
		{
			super.start( completeCallback, failureCallback );
			Log.d( TAG, "start()" );
			if (NativeProcess.isSupported)
			{
				var cmd:File = WindowsShellPaths.getCmdInterpreter( _config ? _config.env : null );
				if (cmd == null || !cmd.exists)
				{
					APM.io.writeError( "cmd.exe", "cmd.exe not available - cannot get environment - proceeding with defaults" );
					return complete();
				}
				
				var processArgs:Vector.<String> = new Vector.<String>();
				processArgs.push( "/c" );
				processArgs.push( "set" );
				
				var processStartupInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
				processStartupInfo.executable = cmd;
				processStartupInfo.workingDirectory = new File( APM.config.workingDirectory );
				processStartupInfo.arguments = processArgs;
				
				_process = new NativeProcess();
				_process.addEventListener( NativeProcessExitEvent.EXIT, onExit );
				
				_process.addEventListener( Event.STANDARD_ERROR_CLOSE, onClose );
				_process.addEventListener( Event.STANDARD_OUTPUT_CLOSE, onClose );
				
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
			try
			{
				_data += _process.standardOutput.readUTFBytes( _process.standardOutput.bytesAvailable );
			}
			catch (e:Error)
			{
				Log.d( TAG, "ERROR: " + e.message );
				Log.e( TAG, e );
			}
		}
		
		
		private function onErrorData( event:ProgressEvent ):void
		{
			Log.d( TAG, "ERROR: " + _process.standardError.readUTFBytes( _process.standardError.bytesAvailable ) );
		}
		
		
		private function onExit( event:NativeProcessExitEvent ):void
		{
			Log.d( TAG, "Process exited with: " + event.exitCode );
			processEnvironmentVariables( _data );
			for (var key:String in _environmentVariables)
			{
				_config.env[ key ] = _environmentVariables[ key ];
			}
			complete();
		}
		
		
		private function onIOError( event:IOErrorEvent ):void
		{
			Log.d( TAG, "IOError: (" + event.type + ")" + event.toString() );
		}
		
		
		private function onClose( event:Event ):void
		{
			Log.d( TAG, "onClose: (" + event.type + ")" + event.toString() );
		}
		
		
		//
		//
		//
		
		private function processEnvironmentVariables( data:String ):void
		{
			Log.v( TAG, "processEnvironmentVariables(): " + data );
			var lines:Array = data.replace( "\r", "" ).split( "\n" );
			for each (var line:String in lines)
			{
				var envVar:Array = line.split( "=" );
				if (envVar.length == 2)
				{
					var name:String = envVar[ 0 ];
					var value:String = envVar[ 1 ].replace( /\r/g, "" ).replace( /\n/g, "" );
					
					Log.v( TAG, name + "=" + value );
					
					_environmentVariables[ name ] = value;
				}
			}
		}
		
	}
	
}
