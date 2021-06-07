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
package com.apm.client.commands.airsdk.processes
{
	import com.apm.client.APMCore;
	import com.apm.client.config.RunConfig;
	import com.apm.client.logging.Log;
	import com.apm.client.processes.Process;
	import com.apm.client.processes.events.ProcessEvent;
	import com.apm.remote.airsdk.AIRSDKBuild;
	
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.EventDispatcher;
	import flash.events.IOErrorEvent;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	
	
	public class ExtractAIRSDKMacOSProcess extends EventDispatcher implements Process
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "ExtractAIRSDKMacOSProcess";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _process:NativeProcess;
		
		private var _core:APMCore;
		private var _build:AIRSDKBuild;
		private var _source:File;
		private var _installPath:String;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function ExtractAIRSDKMacOSProcess( core:APMCore, build:AIRSDKBuild, source:File, installPath:String )
		{
			_core = core;
			_build = build;
			_source = source;
			_installPath = installPath;
		}
		
		
		public function start():void
		{
			Log.d( TAG, "start()" );
			if (NativeProcess.isSupported)
			{
				var processArgs:Vector.<String> = new Vector.<String>();
				processArgs.push( "-o" );
				processArgs.push( "-d" );
				processArgs.push( _installPath );
				processArgs.push( _source.nativePath );

				var processStartupInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
				processStartupInfo.executable = new File( "/usr/bin/unzip" );
				processStartupInfo.arguments = processArgs;

				if (!processStartupInfo.executable.exists)
				{
					// Error?
					dispatchEvent( new ProcessEvent( ProcessEvent.COMPLETE ) );
				}
				
				_core.io.showSpinner( "Extracting AIR SDK" );
				
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
				dispatchEvent( new ProcessEvent( ProcessEvent.COMPLETE ) );
			}
		}
		
		
		private function onOutputData( event:ProgressEvent ):void
		{
			var data:String = _process.standardOutput.readUTFBytes( _process.standardOutput.bytesAvailable )
					.replace("\n", "" )
					.replace("\r", "" )
					.replace("\t", "" );

			_core.io.updateSpinner( "Extracting AIR SDK : " + data );
		}
		
		
		private function onErrorData( event:ProgressEvent ):void
		{
			Log.d( TAG, "ERROR: " + _process.standardError.readUTFBytes( _process.standardError.bytesAvailable ) );
		}
		
		
		private function onExit( event:NativeProcessExitEvent ):void
		{
			Log.d( TAG, "Process exited with: " + event.exitCode );
			_core.io.stopSpinner( event.exitCode == 0, "Extracted AIR SDK" );
			dispatchEvent( new ProcessEvent( ProcessEvent.COMPLETE ) );
		}
		
		
		private function onIOError( event:IOErrorEvent ):void
		{
			Log.d( TAG, "IOError: " + event.toString() );
		}
		
		
		
		
	}
	
}
