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
 * @created		27/8/21
 */
package com.apm.client.commands.project.processes
{
	import com.apm.client.APMCore;
	import com.apm.client.Consts;
	import com.apm.client.logging.Log;
	import com.apm.client.processes.ProcessBase;
	import com.apm.data.project.ApplicationDescriptor;
	import com.apm.utils.FileUtils;
	
	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.IOErrorEvent;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	
	public class AndroidManifestMergeRunProcess extends ProcessBase
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "AndroidManifestMergeDependencyCheckProcess";
		
		
		private static const EMPTY_ANDROID_MANIFEST:String =
									 "<?xml version=\"1.0\" encoding=\"utf-8\"?>\n" +
									 "<manifest xmlns:android=\"http://schemas.android.com/apk/res/android\" >\n" +
									 "    <uses-sdk android:minSdkVersion=\"19\" android:targetSdkVersion=\"30\" />\n" +
									 "</manifest>\n";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _appDescriptor:ApplicationDescriptor;
		
		private var _process:NativeProcess;
		
		private var _data:String;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function AndroidManifestMergeRunProcess( appDescriptor:ApplicationDescriptor )
		{
			_appDescriptor = appDescriptor;
			_data = "";
		}
		
		
		override public function start( completeCallback:Function = null, failureCallback:Function = null ):void
		{
			super.start( completeCallback, failureCallback );
			
			var manifests:Array = findPackageManifests();
			if (manifests.length == 0)
			{
				complete();
			}
			
			var filename:String = Consts.MERGE_TOOL_FILENAME.replace( /@VERSION@/g, Consts.MERGE_TOOL_VERSION );
			var mergeUtility:File = FileUtils.toolsDirectory.resolvePath( filename );
			if (!mergeUtility.exists)
			{
				failure( "Merge utility not found" );
				return;
			}
			
			var mainManifest:File = new File( APMCore.instance.config.workingDir ).resolvePath( "config/android/AndroidManifest.xml" );
			if (!mainManifest.exists)
			{
				if (!FileUtils.tmpDirectory.exists) FileUtils.tmpDirectory.createDirectory();
				mainManifest = FileUtils.tmpDirectory.resolvePath( "AndroidManifest.xml" );
				if (!mainManifest.exists)
				{
					writeEmptyManifest( mainManifest );
				}
			}
			
			
			if (NativeProcess.isSupported)
			{
				var processArgs:Vector.<String> = new Vector.<String>();
				processArgs.push( "-jar" );
				processArgs.push( mergeUtility.nativePath );
				processArgs.push( "--main" );
				processArgs.push( mainManifest.nativePath );
				processArgs.push( "--libs" );
				processArgs.push( manifestsToCommandLineArg( manifests ) );
				
				// App settings
				processArgs.push( "--property" );
				processArgs.push( "PACKAGE=" + packageName() );
//				processArgs.push( "--property" );
//				processArgs.push( "MIN_SDK_VERSION=19" );
//				processArgs.push( "--property" );
//				processArgs.push( "TARGET_SDK_VERSION=30" );
				
				// Parameters
				for (var paramName:String in APMCore.instance.config.projectDefinition.configuration)
				{
					var paramValue:String = APMCore.instance.config.projectDefinition.configuration[ paramName ];
					processArgs.push( "--placeholder");
					processArgs.push( paramName + "=" + paramValue );
				}
				
				var javaHome:String = APMCore.instance.config.env[ "JAVA_HOME" ];
				if (javaHome == null) javaHome = "";
				var java:File = new File( javaHome ).resolvePath( "bin/java" );
				if (!java.exists)
				{
					return failure( "Could not locate java installation - Check you have set the JAVA_HOME environment variable correctly" )
				}
				
				var processStartupInfo:NativeProcessStartupInfo = new NativeProcessStartupInfo();
				processStartupInfo.executable = java;
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
				failure( "Native process not supported - Manifest merge tool cannot be run" );
			}
		}
		
		
		private function findPackageManifests():Array
		{
			var manifests:Array = FileUtils.getFilesByName(
					"AndroidManifest.xml",
					new File( APMCore.instance.config.packagesDir )
			);
			return manifests;
		}
		
		
		private function manifestsToCommandLineArg( manifests:Array ):String
		{
			var args:Array = [];
			for each (var manifestFile:File in manifests)
			{
				args.push( manifestFile.nativePath );
			}
			return args.join( ":" );
		}
		
		
		private function writeEmptyManifest( file:File ):void
		{
			var fs:FileStream = new FileStream();
			fs.open( file, FileMode.WRITE );
			fs.writeUTFBytes( EMPTY_ANDROID_MANIFEST );
			fs.close();
		}
		
		
		private function onOutputData( event:ProgressEvent ):void
		{
			_data += _process.standardOutput.readUTFBytes( _process.standardOutput.bytesAvailable );
		}
		
		
		private function onErrorData( event:ProgressEvent ):void
		{
			_data += _process.standardError.readUTFBytes( _process.standardError.bytesAvailable );
			Log.d( TAG, "ERROR: " + _data );
		}
		
		
		private function onExit( event:NativeProcessExitEvent ):void
		{
			Log.d( TAG, "Process exited with: " + event.exitCode );
//			_core.io.stopSpinner( event.exitCode == 0, " checksum calculated" );
			
			var mainManifest:File = FileUtils.tmpDirectory.resolvePath( "AndroidManifest.xml" );
			if (mainManifest.exists)
			{
				mainManifest.deleteFile();
			}
			
			if (event.exitCode == 0)
			{
				_appDescriptor.androidManifest = _data;
				complete( _data );
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
		
		
		private function packageName():String
		{
			var noAndroidFlair:String = APMCore.instance.config.env[ "AIR_NOANDROIDFLAIR" ];
			if (noAndroidFlair == null || noAndroidFlair == "false")
			{
				return "air." + APMCore.instance.config.projectDefinition.applicationId;
			}
			return APMCore.instance.config.projectDefinition.applicationId;
		}
		
		
	}
	
}
