/**
 * @author 		Michael Archbold (https://michaelarchbold.com)
 * @created		18/5/2021
 */
package com.apm.client.commands.airsdk
{
	import com.apm.client.APM;
	import com.apm.client.commands.Command;
	import com.apm.client.commands.airsdk.processes.DownloadAIRSDKProcess;
	import com.apm.client.commands.airsdk.processes.InstallAIRSDKFinaliseProcess;
	import com.apm.client.events.CommandEvent;
	import com.apm.client.processes.ProcessQueue;
	import com.apm.client.processes.generic.ExtractZipProcess;
	import com.apm.remote.airsdk.AIRSDKAPI;
	import com.apm.remote.airsdk.AIRSDKBuild;
	
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	
	
	public class AIRSDKInstallCommand extends EventDispatcher implements Command
	{
		
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "AIRSDKInstallCommand";
		
		
		public static const NAME:String = "airsdk/install";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _parameters:Array;
		
		private var _airsdkAPI:AIRSDKAPI;
		
		private var _loadQueue:ProcessQueue;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function AIRSDKInstallCommand()
		{
			super();
			
			_airsdkAPI = new AIRSDKAPI();
			_loadQueue = new ProcessQueue();
		}
		
		
		public function setParameters( parameters:Array ):void
		{
			_parameters = parameters;
		}
		
		
		public function get name():String
		{
			return NAME;
		}
		
		
		public function get category():String
		{
			return "";
		}
		
		
		public function get requiresNetwork():Boolean
		{
			return true;
		}
		
		
		public function get requiresProject():Boolean
		{
			return false;
		}
		
		
		public function get description():String
		{
			return "downloads and installs an AIR SDK version";
		}
		
		
		public function get usage():String
		{
			return description + "\n" +
					"\n" +
					"apm airsdk install <version> <dir_name>    downloads and installs an AIR SDK version\n" +
					"apm airsdk install latest <dir_name>       downloads and installs the latest AIR SDK version\n" +
					"\n" +
					"<dir_name> is an optional directory name for the SDK, it is relative to the current directory, defaults to AIRSDK_[version]"
		}
		
		
		public function execute():void
		{
			if (_parameters == null || _parameters.length == 0)
			{
				APM.io.writeLine( "You need to provide an AIR SDK version" );
				dispatchEvent( new CommandEvent( CommandEvent.COMPLETE, APM.CODE_ERROR ) );
				return;
			}
			else
			{
				var airsdkVersion:String = _parameters[ 0 ];
				var airsdkDirName:String = (_parameters.length > 1 ? _parameters[ 1 ] : null);
				
				APM.io.showSpinner( "Retrieving AIR SDK information : " + airsdkVersion );
				
				_airsdkAPI.getRelease( airsdkVersion, function ( success:Boolean, build:AIRSDKBuild, message:String ):void {
					if (success)
					{
						APM.io.stopSpinner( true, "Retrieved AIR SDK information : " + build.version );
						
						// License Check
						if (!APM.config.user.hasAcceptedLicense)
						{
							APM.io.writeLine( "=======================================" );
							APM.io.writeLine( "By downloading or using the SDK software, you hereby acknowledge that you have read HARMAN's AIR SDK developer license terms and agree to the terms therein." );
							APM.io.writeLine( "https://airsdk.harman.com/assets/pdfs/HARMAN%20AIR%20SDK%20License%20Agreement.pdf" );
							APM.io.writeLine( "=======================================" );
							
							var acceptLicense:String = APM.io.question( "\nDo you accept the terms of the license agreement? Y/n", "n" );
							if (acceptLicense.toLowerCase() != "y")
							{
								APM.io.writeLine( "You must accept the license to download and use the AIR SDK" );
								dispatchEvent( new CommandEvent( CommandEvent.COMPLETE, APM.CODE_ERROR ) );
								return;
							}
							
							APM.config.user.hasAcceptedLicense = true;
						}
						else
						{
							APM.io.writeLine( "Already accepted AIR License" );
						}
						
						APM.io.writeLine( "\nStarting AIR SDK Installation" );
						
						
						var airsdkZipFile:File = new File( APM.config.workingDirectory + File.separator + "AIRSDK_" + build.version + ".zip" );
						
						if (airsdkDirName == null) airsdkDirName = "AIRSDK_" + build.version;
						
						var installDir:File = new File( APM.config.workingDirectory + File.separator + airsdkDirName );
						
						_loadQueue.addProcess( new DownloadAIRSDKProcess( build, airsdkZipFile ) );
						_loadQueue.addProcess( new ExtractZipProcess( airsdkZipFile, installDir ) );
						_loadQueue.addCallback( function():void {
							airsdkZipFile.deleteFile();
						});
						_loadQueue.addProcess( new InstallAIRSDKFinaliseProcess( installDir ) );
						
						_loadQueue.start(
								function ():void {
									dispatchEvent( new CommandEvent( CommandEvent.COMPLETE, APM.CODE_OK ) );
								},
								function ( error:String ):void {
									APM.io.writeResult( false, error );
									dispatchEvent( new CommandEvent( CommandEvent.COMPLETE, APM.CODE_ERROR ) );
								} );
					}
					
					else
					{
						APM.io.stopSpinner( false, "ERROR: Could not get AIR SDK information" );
						dispatchEvent( new CommandEvent( CommandEvent.COMPLETE, APM.CODE_ERROR ) );
					}
				} );
				
			}
			
		}
		
		
	}
	
}
