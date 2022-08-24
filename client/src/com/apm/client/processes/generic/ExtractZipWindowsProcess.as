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
	import com.apm.utils.WindowsShellPaths;

	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.IOErrorEvent;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;

	public class ExtractZipWindowsProcess extends ExtractZipAS3Process
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//

		private static const TAG:String = "ExtractZipWindowsProcess";


		////////////////////////////////////////////////////////
		//  VARIABLES
		//

		private var _process:NativeProcess;

		private var _zipFileRef:File;
		private var _deleteAfter:Boolean     = false;
		private var _attemptFallback:Boolean = false;


		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//

		public function ExtractZipWindowsProcess( zipFile:File, outputDir:File, showOutputs:Boolean = true )
		{
			super( zipFile, outputDir, showOutputs );
		}


		override public function start( completeCallback:Function = null, failureCallback:Function = null ):void
		{
			_completeCallback = completeCallback;
			_failureCallback  = failureCallback;

			var message:String = "extracting " + _zipFile.nativePath;

			if (NativeProcess.isSupported)
			{
				var powershell:File = WindowsShellPaths.getPowershell();
				if (powershell == null || !powershell.exists)
				{
					Log.d( TAG, "powershell.exe not available - fall back to as3 implementation" );
					return super.start( completeCallback, failureCallback );
				}

				var powerShellVersion:String = APM.config.env["POWERSHELL_Version"];
				Log.d( TAG, "powershell version: " + powerShellVersion );
				if (powerShellVersion == null || Number( powerShellVersion.charAt( 0 ) ) < 4)
				{
					Log.d( TAG,
						   "powershell version too old [" + powerShellVersion + "] - fall back to as3 implementation" );
					return super.start( completeCallback, failureCallback );
				}

				if (_zipFile.extension != "zip")
				{
					// Powershell script can't handle non-zip extension archives so we copy to a .zip tmp file and delete after
					_zipFileRef = new File( _zipFile.nativePath + ".zip" );
					_zipFile.copyTo( _zipFileRef );
					_deleteAfter = true;
				}
				else
				{
					_zipFileRef = _zipFile;
				}

				var processArgs:Vector.<String> = new Vector.<String>();
				processArgs.push( "-command" );
				processArgs.push( "& \"Expand-Archive\" -Force "
										  + "'" + _zipFileRef.nativePath + "'" + " "
										  + "'" + _outputDir.nativePath + "'" );

				var processStartupInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
				processStartupInfo.executable                   = powershell;
				processStartupInfo.arguments                    = processArgs;

				Log.d( TAG, "Starting extraction" );
				if (_showOutputs) APM.io.showSpinner( message );
				
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
				super.start( completeCallback, failureCallback );
			}
		}


		private function onOutputData( event:ProgressEvent ):void
		{
			var data:String = _process.standardOutput.readUTFBytes( _process.standardOutput.bytesAvailable )
									  .replace( /\n/g, "" )
									  .replace( /\r/g, "" )
									  .replace( /\t/g, "" );

			if (_showOutputs) APM.io.updateSpinner( "extracting : " + data );

			Log.d( TAG, "extracting : " + data );
		}


		private function onErrorData( event:ProgressEvent ):void
		{
			var errorMessage:String = _process.standardError.readUTFBytes( _process.standardError.bytesAvailable );
			Log.d( TAG, "ERROR: " + errorMessage );

			if (errorMessage.indexOf( "CommandNotFoundException" ) >= 0)
			{
				// Indicates the "Expand-Archive" powershell command isn't available
				_attemptFallback = true;
			}
		}


		private function onExit( event:NativeProcessExitEvent ):void
		{
			Log.d( TAG, "Process exited with: " + event.exitCode );
			if (_showOutputs) APM.io.stopSpinner( event.exitCode == 0, "extracted" );

			if (_deleteAfter)
			{
				_zipFileRef.deleteFile();
			}

			if (event.exitCode == 1 && _attemptFallback)
			{
				// Attempt fallback to as3 implementation
				super.start( _completeCallback, _failureCallback );
			}
			else
			{
				complete();
			}
		}


		private function onIOError( event:IOErrorEvent ):void
		{
			Log.d( TAG, "IOError: " + event.toString() );
		}


	}

}
