/**
 * @author 		Michael Archbold (https://michaelarchbold.com)
 * @created		8/9/2021
 */
package com.apm.client.commands.airsdk.processes
{
	import com.apm.client.APM;
	import com.apm.client.logging.Log;
	import com.apm.client.processes.ProcessBase;
	
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.IOErrorEvent;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	
	
	public class InstallAIRSDKFinaliseProcess extends ProcessBase
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "UpgradeClientFinaliseProcess";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _process:NativeProcess;
		
		private var _airSDKDir:File;
		
		private var _failMessage:String = "Could not set permissions: try running: 'xattr -r -d com.apple.quarantine air_sdk_folder'";
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function InstallAIRSDKFinaliseProcess( airSDKDir:File )
		{
			_airSDKDir = airSDKDir;
		}
		
		
		override public function start( completeCallback:Function = null, failureCallback:Function = null ):void
		{
			super.start( completeCallback, failureCallback );
			
			if (APM.config.isMacOS)
			{
				// Need to ensure script permissions are set correctly
				if (NativeProcess.isSupported)
				{
					var processArgs:Vector.<String> = new Vector.<String>();
					processArgs.push( "-r" );
					processArgs.push( "-d" );
					processArgs.push( "com.apple.quarantine" );
					processArgs.push(  _airSDKDir.nativePath );
					
					var processStartupInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
					processStartupInfo.executable = new File( "/usr/bin/xattr" );
					processStartupInfo.arguments = processArgs;
					
					_process = new NativeProcess();
					_process.addEventListener( NativeProcessExitEvent.EXIT, onExit );
					_process.addEventListener( ProgressEvent.STANDARD_OUTPUT_DATA, onOutputData );
					_process.addEventListener( ProgressEvent.STANDARD_ERROR_DATA, onErrorData );
					_process.addEventListener( IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, onIOError );
					_process.addEventListener( IOErrorEvent.STANDARD_ERROR_IO_ERROR, onIOError );
					
					APM.io.showSpinner( "Setting permissions" );
					_process.start( processStartupInfo );
				}
				else
				{
					failure( _failMessage );
				}
			}
			else if (APM.config.isWindows)
			{
				complete();
			}
			else
			{
				complete();
			}
		}
		
		
		private function onOutputData( event:ProgressEvent ):void
		{
			Log.d( TAG, _process.standardOutput.readUTFBytes( _process.standardOutput.bytesAvailable ) );
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
				APM.io.stopSpinner( true, "complete" );
				complete();
			}
			else
			{
				APM.io.stopSpinner( false, _failMessage );
				failure( _failMessage );
			}
		}
		
		
		private function onIOError( event:IOErrorEvent ):void
		{
//			Log.d( TAG, "IOError: " + event.toString() );
		}
		
		
	}
	
}
