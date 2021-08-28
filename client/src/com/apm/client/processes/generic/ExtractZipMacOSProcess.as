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
package com.apm.client.processes.generic
{
	import com.apm.client.APM;
	import com.apm.client.logging.Log;
	import com.apm.client.processes.ProcessBase;
	import com.apm.client.processes.generic.ExtractZipAS3Process;
	
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.IOErrorEvent;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	
	
	public class ExtractZipMacOSProcess extends ExtractZipAS3Process
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "ExtractZipMacOSProcess";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _process:NativeProcess;
		
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function ExtractZipMacOSProcess( zipFile:File, outputDir:File )
		{
			super( zipFile, outputDir );
		}
		
		
		override public function start( completeCallback:Function=null, failureCallback:Function=null ):void
		{
			_completeCallback = completeCallback;
			_failureCallback = failureCallback;
			
			var message:String = "extracting " + _zipFile.nativePath;
			
			if (NativeProcess.isSupported)
			{
				var processArgs:Vector.<String> = new Vector.<String>();
				processArgs.push( "-o" );
				processArgs.push( "-d" );
				processArgs.push( _outputDir.nativePath );
				processArgs.push( _zipFile.nativePath );
				
				var processStartupInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
				processStartupInfo.executable = new File( "/usr/bin/unzip" );
				processStartupInfo.arguments = processArgs;
				
				if (!processStartupInfo.executable.exists)
				{
					// Fall back to as3 implementation
					return super.start( complete, failure );
				}
				
				APM.io.showSpinner( message );
				
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
			var data:String = _process.standardOutput.readUTFBytes( _process.standardOutput.bytesAvailable )
					.replace( /\n/g, "" )
					.replace( /\r/g, "" )
					.replace( /\t/g, "" );
			
			APM.io.updateSpinner( "extracting : " + data );
		}
		
		
		private function onErrorData( event:ProgressEvent ):void
		{
			Log.d( TAG, "ERROR: " + _process.standardError.readUTFBytes( _process.standardError.bytesAvailable ) );
		}
		
		
		private function onExit( event:NativeProcessExitEvent ):void
		{
			Log.d( TAG, "Process exited with: " + event.exitCode );
			APM.io.stopSpinner( event.exitCode == 0, "extracted" );
			complete();
		}
		
		
		private function onIOError( event:IOErrorEvent ):void
		{
			Log.d( TAG, "IOError: " + event.toString() );
		}
		
		
	}
	
}
