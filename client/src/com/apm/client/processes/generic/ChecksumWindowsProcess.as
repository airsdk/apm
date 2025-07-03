/**
 * @author 		Michael Archbold (https://michaelarchbold.com)
 * @created		13/8/2021
 */
package com.apm.client.processes.generic
{
	import com.apm.client.APM;
	import com.apm.client.logging.Log;
	
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.IOErrorEvent;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	
	
	public class ChecksumWindowsProcess extends ChecksumAS3Process
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "ChecksumWindowsProcess";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _process:NativeProcess;
		
		private var _data:String;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function ChecksumWindowsProcess( core:APM, file:File )
		{
			super( core, file );
		}
		
		
		override public function start( completeCallback:Function = null, failureCallback:Function = null ):void
		{
			_completeCallback = completeCallback;
			_failureCallback = failureCallback;
			_data = "";
			
			Log.d( TAG, "start: " + _file.name );
			Log.d( TAG, "start: " + _file.name );
			var message:String = "calculating checksum " + _file.nativePath;
			
			if (NativeProcess.isSupported)
			{
				var processArgs:Vector.<String> = new Vector.<String>();
				processArgs.push( "-hashfile" );
				processArgs.push( _file.nativePath );
				processArgs.push( "SHA256" );
				
				var processStartupInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
				processStartupInfo.executable = new File( "C:\\Windows\\System32\\certutil.exe" );
				processStartupInfo.arguments = processArgs;
				
				if (!processStartupInfo.executable.exists)
				{
					// Fall back to as3 implementation
					return super.start( complete, failure );
				}
				
//				APM.io.showSpinner( message );
				
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
				super.start( complete, failure );
			}
		}
		
		
		private function onOutputData( event:ProgressEvent ):void
		{
			var output:String = _process.standardOutput.readUTFBytes( _process.standardOutput.bytesAvailable );
			_data += output;
		}
		
		
		private function onErrorData( event:ProgressEvent ):void
		{
			Log.d( TAG, "ERROR: " + _process.standardError.readUTFBytes( _process.standardError.bytesAvailable ) );
		}
		
		
		private function onExit( event:NativeProcessExitEvent ):void
		{
			Log.d( TAG, "Process exited with: " + event.exitCode + " cs '" + _data + "'");
//			APM.io.stopSpinner( event.exitCode == 0, " checksum calculated" );
			if (event.exitCode == 0)
			{
				var hashRegExp:RegExp = /^[A-Fa-f0-9]{64}$/m;
				var checksum:String = hashRegExp.exec(_data);
				complete( checksum );
			}
			else
			{
				failure( _data );
			}
		}
		
		
		private function onIOError( event:IOErrorEvent ):void
		{
			Log.d( TAG, "IOError: " + event.toString() );
		}
		
		
	}
	
}
