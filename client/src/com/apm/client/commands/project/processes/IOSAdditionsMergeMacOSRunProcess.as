/**
 * @author 		Michael Archbold (https://michaelarchbold.com)
 * @created		27/8/2021
 */
package com.apm.client.commands.project.processes
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

	/**
	 * THIS PROCESS IS STILL IN DEVELOPMENT
	 *
	 * Takes 2 plist files and merges them with the PlistBuddy utility on macOS
	 * <br/>
	 *
	 *
	 * We use PListBuddy here
	 *
	 * /usr/libexec/PlistBuddy -x -c "Merge package/InfoAdditions.plist" out.plist
	 *
	 * - https://marcosantadev.com/manage-plist-files-plistbuddy/
	 * - https://medium.com/@marksiu/what-is-plistbuddy-76cb4f0c262d
	 *
	 */
	public class IOSAdditionsMergeMacOSRunProcess extends ProcessBase
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//

		private static const TAG:String = "IOSAdditionsMergeMacOSRunProcess";


		////////////////////////////////////////////////////////
		//  VARIABLES
		//

		private var _mergePlist:File;
		private var _destPlist:File;

		private var _process:NativeProcess;


		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//

		public function IOSAdditionsMergeMacOSRunProcess( mergePlist:File, destPlist:File )
		{
			_mergePlist = mergePlist;
			_destPlist = destPlist;
		}


		public static function get isSupported():Boolean
		{
			try
			{
				return (NativeProcess.isSupported && APM.config.isMacOS && new File( "/usr/libexec/PlistBuddy" ).exists)
			}
			catch (e:Error)
			{
			}
			return false;
		}


		override public function start( completeCallback:Function = null, failureCallback:Function = null ):void
		{
			super.start( completeCallback, failureCallback );

			if (!isSupported)
			{
				failure( "Plist merging not supported" );
				return;
			}

			if (!_mergePlist.exists || !_destPlist.exists)
			{
				failure( "Plist file doesn't exist" );
				return;
			}


			//
			// DOESN'T WORK
			// Unfortunately this doesn't merge duplicate entries - "Duplicate Entry Was Skipped:"...
			//

			var pListBuddy:File = new File( "/usr/libexec/PlistBuddy" );

			if (NativeProcess.isSupported || !pListBuddy.exists)
			{
				var processArgs:Vector.<String> = new Vector.<String>();
				processArgs.push( "-x" );
				processArgs.push( "-c" );
				processArgs.push( "Merge " + _mergePlist.nativePath + "" );
				processArgs.push( _destPlist.nativePath );

				var processStartupInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
				processStartupInfo.executable = pListBuddy;
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
				Log.d( TAG, "Native process not supported - PlistBuddy tool cannot be run" );
				failure( "Native process not supported - PlistBuddy tool cannot be run" );
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
				complete();
			}
			else
			{
				failure( "error" );
			}
		}


		private function onIOError( event:IOErrorEvent ):void
		{
			Log.d( TAG, "IOError: " + event.toString() );
		}


	}

}
