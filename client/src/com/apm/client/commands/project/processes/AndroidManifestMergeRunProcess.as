/**
 * @author 		Michael Archbold (https://michaelarchbold.com)
 * @created		27/8/2021
 */
package com.apm.client.commands.project.processes
{
	import airsdk.lib.ADTConfig;

	import com.apm.client.APM;
	import com.apm.client.logging.Log;
	import com.apm.client.processes.ProcessBase;
	import com.apm.data.project.ApplicationDescriptor;
	import com.apm.data.project.ProjectParameter;
	import com.apm.utils.FileUtils;

	import flash.desktop.NativeProcess;
	import flash.desktop.NativeProcessStartupInfo;
	import flash.events.IOErrorEvent;
	import flash.events.NativeProcessExitEvent;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.utils.ByteArray;

	public class AndroidManifestMergeRunProcess extends ProcessBase
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//

		private static const TAG:String = "AndroidManifestMergeRunProcess";


		[Embed(source="data/AndroidManifestDefault.xml", mimeType="application/octet-stream")]
		private var AndroidManifestDefault:Class;

		private var ANDROID_MANIFEST_DEFAULT:String = (new AndroidManifestDefault() as ByteArray).toString();


		////////////////////////////////////////////////////////
		//  VARIABLES
		//

		private var _appDescriptor:ApplicationDescriptor;

		private var _process:NativeProcess;

		private var _data:String;
		private var _error:String;


		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//

		public function AndroidManifestMergeRunProcess( appDescriptor:ApplicationDescriptor )
		{
			_appDescriptor = appDescriptor;
			_data = "";
			_error = "";
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

			if (!FileUtils.tmpDirectory.exists) FileUtils.tmpDirectory.createDirectory();
			var mainManifest:File = FileUtils.tmpDirectory.resolvePath( "AndroidManifest.xml" );

			var configManifest:File = new File( APM.config.configDirectory ).resolvePath( "android/AndroidManifest.xml" );
			if (configManifest.exists)
			{
				APM.io.writeLine( "Merging with supplied main manifest: " +
										  configManifest.nativePath.substr( APM.config.workingDirectory.length + 1 ) );

				var configManifestContent:String = loadConfigManifest( configManifest );
				FileUtils.writeStringAsFileContent( mainManifest, configManifestContent );
			}
			else
			{
				FileUtils.writeStringAsFileContent( mainManifest, ANDROID_MANIFEST_DEFAULT );
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
				// processArgs.push( "--property" );
				// processArgs.push( "MIN_SDK_VERSION=19" );
				// processArgs.push( "--property" );
				// processArgs.push( "TARGET_SDK_VERSION=31" );
//				processArgs.push( "--remove-tools-declarations" );

				// Parameters
				for each (var param:ProjectParameter in APM.config.projectDefinition.getConfiguration( APM.config.buildType ))
				{
					processArgs.push( "--placeholder" );
					processArgs.push( param.name + "=" + param.value );
				}

				Log.d( TAG, "Retrieving path to java installation..." );
				var java:File = APM.config.getJava();
				if (!java.exists)
				{
					return failure( "Could not locate java installation - Check you have set the JAVA_HOME environment variable correctly" )
				}
				Log.d( TAG, "Java installation located." );

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
					new File( APM.config.packagesDirectory )
			);
			return manifests;
		}


		private function manifestsToCommandLineArg( manifests:Array ):String
		{
			var args:Array = [];
			for each (var manifestFile:File in manifests)
			{
				Log.v( TAG, "Merging: " + manifestFile.nativePath );
				args.push( manifestFile.nativePath );
			}
			return args.join( APM.config.isWindows ? ";" : ":" );
		}


		private function loadConfigManifest( configManifest:File ):String
		{
			// Load the config manifest
			//   If the <activity> node exists for changes to the main activity,
			//   we must insert an android:name attribute to make merge work
			//   This will get removed from the manifest after merge for AIR to merge
			var configManifestContent:String = FileUtils.readFileContentAsString( configManifest );
			var activityRegex:RegExp = /<activity[\s\r\n]*>/g;
			configManifestContent = configManifestContent
					.replace(
							activityRegex,
							"<activity android:name=\".AIRAppEntry\" android:exported=\"true\">"
					);

			return configManifestContent;
		}


		private function processMergedManifest( mergedManifest:String ):String
		{
			var cleanedManifest:String = stripNonXMLContent( mergedManifest );

			// Replace the main activity with a simple <activity> tag for AIR to merge
			var activityRegex:RegExp = /<activity[\s\t\r\n]*android:name=".*AIRAppEntry"[\s\t\r\n]*android:exported="true"/g
			return cleanedManifest.replace(
					activityRegex,
					"<activity"
			);
		}


		private function stripNonXMLContent( content:String ):String
		{
			var lines:Array = content.split( "\n" );
			var xmlLines:Array = [];
			var xmlLinePattern:RegExp = /<[^>]+>/g;

			var currentXmlLine:String = "";
			var insideXmlTag:Boolean = false;

			for each (var line:String in lines)
			{
				if (line.match( xmlLinePattern ))
				{
					if (insideXmlTag)
					{
						currentXmlLine += line;
						if (line.indexOf( ">" ) >= 0)
						{
							xmlLines.push( currentXmlLine );
							currentXmlLine = "";
							insideXmlTag = false;
						}
					}
					else
					{
						if (line.indexOf( ">" ) >= 0)
						{
							xmlLines.push( line );
						}
						else
						{
							currentXmlLine = line;
							insideXmlTag = true;
						}
					}
				}
			}
			return xmlLines.join( "\n" );
		}


		private function onOutputData( event:ProgressEvent ):void
		{
			_data += _process.standardOutput.readUTFBytes( _process.standardOutput.bytesAvailable );
		}


		private function onErrorData( event:ProgressEvent ):void
		{
			_error += _process.standardError.readUTFBytes( _process.standardError.bytesAvailable );
			Log.d( TAG, "ERROR: " + _error );
			Log.d( TAG, "ERROR: data: " + _data );
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
				Log.d( TAG, "MANIFEST OUTPUT: " + _data );
				_appDescriptor.androidManifest = processMergedManifest( _data );
				complete( _appDescriptor.androidManifest );
			}
			else
			{
				failure( _error );
			}
		}


		private function onIOError( event:IOErrorEvent ):void
		{
			Log.d( TAG, "IOError: " + event.toString() );
		}


		private static function packageName():String
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

			var airApplicationId:String = APM.config.projectDefinition.getApplicationId( APM.config.buildType );
			var components:Array = airApplicationId.split( "." );
			for (var i:int = 0; i < components.length; i++)
			{
				var component:String = components[i];
				component = component.replace( /-/g, "_" ); // replace hyphens with underscore
				if (component.match( /^\d/ ))
				{
					component = "A" + component;
				} // prefix numeric component with "A"
				components[i] = component;
			}

			var airPackageName:String = components.join( "." );
			if (noAndroidFlair())
			{
				return airPackageName;
			}
			return "air." + airPackageName;
		}


		private static function noAndroidFlair():Boolean
		{
			var noAndroidFlair:String = APM.config.env["AIR_NOANDROIDFLAIR"];
			if (noAndroidFlair != null && noAndroidFlair == "true")
			{
				Log.d( TAG, "Remove AIR prefix: environment: AIR_NOANDROIDFLAIR = true" );
				return true;
			}

			// Check AIRSDK/adt.cfg as well
			if (APM.config.airDirectory != null)
			{
				var airDir:File = new File( APM.config.airDirectory );
				if (airDir.exists)
				{
					var config:ADTConfig = ADTConfig.load( airDir.resolvePath( "lib/adt.cfg" ) );
					if (config != null)
					{
						if (config.properties.hasOwnProperty( "AddAirToAppID" ))
						{
							if (config.properties["AddAirToAppID"] == "false")
							{
								Log.d( TAG, "Remove AIR prefix: AIRSDK/lib/adt.cfg: AddAirToAppID = false" );
								return true;
							}
						}
					}
				}
			}

			// Check ~/.airsdk/adt.cfg

			return false;
		}


	}

}
