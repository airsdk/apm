/**
 * @author 		Michael (https://github.com/marchbold)
 * @created		8/9/2021
 */
package com.apm.client.processes.upgrade
{
	import com.apm.client.APM;
	import com.apm.client.processes.ProcessBase;

	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.IOErrorEvent;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;


	public class UpgradeClientFinaliseProcess extends ProcessBase
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//

		private static const TAG:String = "UpgradeClientFinaliseProcess";


		////////////////////////////////////////////////////////
		//  VARIABLES
		//

		private var _process:NativeProcess;


		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//

		public function UpgradeClientFinaliseProcess()
		{
		}


		override public function start( completeCallback:Function = null, failureCallback:Function = null ):void
		{
			super.start( completeCallback, failureCallback );

			// Need to ensure script permissions are set correctly
			if (APM.config.isMacOS)
			{
				macOSSetPermissions();
			}
			else if (APM.config.isLinux)
			{
				linuxSetPermissions();
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


		private function macOSSetPermissions():void
		{
			if (NativeProcess.isSupported)
			{
				var processArgs:Vector.<String> = new Vector.<String>();
				processArgs.push( "+x" );
				processArgs.push( APM.config.appDirectory + "/apm" );

				var processStartupInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
				processStartupInfo.executable = new File( "/bin/chmod" );
				processStartupInfo.arguments = processArgs;

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
				failure( "Could not set permissions: try running 'chmod +x $AIR_TOOLS/apm'" );
			}
		}


		private function linuxSetPermissions():void
		{
			if (NativeProcess.isSupported)
			{
				var processArgs:Vector.<String> = new Vector.<String>();
				processArgs.push( "+x" );
				processArgs.push( APM.config.appDirectory + "/apm" );

				var processStartupInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
				processStartupInfo.executable = new File( "/usr/bin/chmod" );
				processStartupInfo.arguments = processArgs;

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
				failure( "Could not set permissions: try running 'chmod +x $AIR_TOOLS/apm'" );
			}
		}


		private function onOutputData( event:ProgressEvent ):void
		{
		}


		private function onErrorData( event:ProgressEvent ):void
		{
//			Log.d( TAG, "ERROR: " + _process.standardError.readUTFBytes( _process.standardError.bytesAvailable ) );
		}


		private function onExit( event:NativeProcessExitEvent ):void
		{
//			Log.d( TAG, "Process exited with: " + event.exitCode );
			if (_process != null)
			{
				_process.removeEventListener( NativeProcessExitEvent.EXIT, onExit );
				_process.removeEventListener( ProgressEvent.STANDARD_OUTPUT_DATA, onOutputData );
				_process.removeEventListener( ProgressEvent.STANDARD_ERROR_DATA, onErrorData );
				_process.removeEventListener( IOErrorEvent.STANDARD_OUTPUT_IO_ERROR, onIOError );
				_process.removeEventListener( IOErrorEvent.STANDARD_ERROR_IO_ERROR, onIOError );
				_process = null;
			}

			if (event.exitCode == 0)
			{
				complete();
			}
			else
			{
				failure( "Could not set permissions, manually run: 'chmod +x %AIR_TOOLS%/apm'" );
			}
		}


		private function onIOError( event:IOErrorEvent ):void
		{
//			Log.d( TAG, "IOError: " + event.toString() );
		}


	}

}
