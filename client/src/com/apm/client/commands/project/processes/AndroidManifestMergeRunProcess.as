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
	import com.apm.client.APM;
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
			
			var mergeUtility:File = FileUtils.toolsDirectory.resolvePath( AndroidManifestMerge.mergeToolFilename );
			if (!mergeUtility.exists)
			{
				failure( "Merge utility not found" );
				return;
			}
			
			var mainManifest:File = new File( APM.config.workingDir ).resolvePath( "config/android/AndroidManifest.xml" );
			if (mainManifest.exists)
			{
				APM.io.writeLine( "Merging with supplied main manifest: config/android/AndroidManifest.xml" );
			}
			else
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
				APM.io.writeLine( "Android package name: " + packageName() );
				
				APM.io.showSpinner( "Android manifest merging" );
				
				var manifests:Array = findPackageManifests();
				
				var processArgs:Vector.<String> = new Vector.<String>();
				processArgs.push( "-jar" );
				processArgs.push( mergeUtility.nativePath );
				processArgs.push( "--main" );
				processArgs.push( mainManifest.nativePath );
				if (manifests.length > 0)
				{
					processArgs.push( "--libs" );
					processArgs.push( manifestsToCommandLineArg( manifests ) );
				}
				
				// App settings
				processArgs.push( "--property" );
				processArgs.push( "PACKAGE=" + packageName() );
//				processArgs.push( "--property" );
//				processArgs.push( "MIN_SDK_VERSION=19" );
//				processArgs.push( "--property" );
//				processArgs.push( "TARGET_SDK_VERSION=30" );
				processArgs.push( "--remove-tools-declarations" );
				
				// Parameters
				for (var paramName:String in APM.config.projectDefinition.configuration)
				{
					var paramValue:String = APM.config.projectDefinition.configuration[ paramName ];
					processArgs.push( "--placeholder" );
					processArgs.push( paramName + "=" + paramValue );
				}
				
				Log.d(TAG, "Retrieving path to java installation...");
				var java:File = APM.config.getJava();
				if (!java.exists)
				{
					return failure( "Could not locate java installation - Check you have set the JAVA_HOME environment variable correctly" )
				}
				Log.d(TAG, "Java installation located.");
				
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
				APM.io.writeError( TAG, "Native process not supported - Manifest merge tool cannot be run" );
				failure( "Native process not supported - Manifest merge tool cannot be run" );
			}
		}
		
		
		private function findPackageManifests():Array
		{
			var manifests:Array = FileUtils.getFilesByName(
					"AndroidManifest.xml",
					new File( APM.config.packagesDir )
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
			return args.join( APM.config.isWindows ? ";" : ":" );
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
			APM.io.stopSpinner( event.exitCode == 0, "Android manifest merge" );
			
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
			/**
			 * On Android, the ID is converted to the Android package name by prefixing “air.” to the AIR ID.
			 * Thus, if your AIR ID is com.example.MyApp, then the Android package name is air.com.example.MyApp.
			 *
			 * In addition, if the ID is not a legal package name on the Android operating system,
			 * it is converted to a legal name. Hyphen characters are changed to underscores and leading
			 * digits in any ID component are preceded by a capital “A”. For example, the ID: 3-goats.1-boat,
			 * is transformed to the package name: air.A3_goats.A1_boat.
			 *
			 * Note: The prefix added to the application ID can be used to identify AIR applications
			 * in the Android Market. If you do not want your application to identified as an AIR
			 * application because of the prefix, you must unpackage the APK file, change the application ID,
			 * and repackage it as described in, Opt-out of AIR application analytics for Android.
			 */
			
			var airApplicationId:String = APM.config.projectDefinition.applicationId;
			var components:Array = airApplicationId.split( "." );
			for (var i:int = 0; i < components.length; i++)
			{
				var component:String = components[ i ];
				component = component.replace( /-/g, "_" ); // replace hyphens with underscore
				if (component.match( /^\d/ ))
					component = "A" + component; // prefix numeric component with "A"
				components[ i ] = component;
			}
			
			var airPackageName:String = components.join( "." );
			if (noAndroidFlair())
			{
				return airPackageName;
			}
			return "air." + airPackageName;
		}
		
		
		private function noAndroidFlair():Boolean
		{
			var noAndroidFlair:String = APM.config.env[ "AIR_NOANDROIDFLAIR" ];
			if (noAndroidFlair != null && noAndroidFlair == "true")
			{
				return true;
			}
			
			// TODO :: Check adt.cfg as well
			
			return false;
		}
		
		
	}
	
}
