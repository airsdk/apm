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
 * @created		18/5/21
 */
package com.apm.client.commands.airsdk
{
	import com.apm.client.APMCore;
	import com.apm.client.commands.Command;
	import com.apm.client.commands.airsdk.processes.DownloadAIRSDKProcess;
	import com.apm.client.commands.airsdk.processes.ExtractAIRSDKMacOSProcess;
	import com.apm.client.commands.airsdk.processes.ExtractAIRSDKProcess;
	import com.apm.client.processes.ProcessQueue;
	import com.apm.remote.airsdk.AIRSDKAPI;
	import com.apm.remote.airsdk.AIRSDKBuild;
	
	import flash.filesystem.File;
	
	
	public class AIRSDKInstallCommand implements Command
	{
		
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "AIRSDKListCommand";
		
		
		public static const NAME:String = "airsdk/install";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _parameters:Array;
		
		private var _airsdkAPI:AIRSDKAPI;
		private var _core:APMCore;
		
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
					"apm airsdk install <version>          downloads and installs an AIR SDK version\n" +
					"apm airsdk install latest             downloads and installs the latest AIR SDK version\n"
		}
		
		
		public function execute( core:APMCore ):void
		{
			_core = core;
			if (_parameters == null || _parameters.length == 0)
			{
				core.io.writeLine( "You need to provide an AIR SDK version" );
				return core.exit( APMCore.CODE_ERROR );
			}
			else
			{
				var airsdkVersion:String = _parameters[ 0 ];
				core.io.showSpinner( "Retrieving AIR SDK information : " + airsdkVersion );
				
				_airsdkAPI.getRelease( airsdkVersion, function ( success:Boolean, build:AIRSDKBuild, message:String ):void {
					if (success)
					{
						core.io.stopSpinner( true, "Retrieved AIR SDK information : " + build.version );
						
						
						// License Check
						
						core.io.writeLine( "=======================================" );
						core.io.writeLine( "By downloading or using the SDK software, you hereby acknowledge that you have read HARMAN's AIR SDK developer license terms and agree to the terms therein." );
						core.io.writeLine( "https://airsdk.harman.com/assets/pdfs/HARMAN%20AIR%20SDK%20License%20Agreement.pdf" );
						core.io.writeLine( "=======================================" );

						var acceptLicense:String = core.io.question( "\nDo you accept the terms of the license agreement? Y/n", "n" );
						if (acceptLicense.toLowerCase() != "y")
						{
							core.io.writeLine( "You must accept the license to download and use the AIR SDK" );
							return core.exit( APMCore.CODE_ERROR );
						}
						
						core.io.writeLine( "\nStarting AIR SDK Installation" );
						
						
						var f:File = new File( _core.config.workingDir + File.separator + "AIRSDK_" + build.version + ".zip" );
						
						var installDir:String = _core.config.workingDir + File.separator + "AIRSDK_" + build.version;
						
						_loadQueue.addProcess( new DownloadAIRSDKProcess( _core, build, f ) );
						if (_core.config.isMacOS)
							_loadQueue.addProcess( new ExtractAIRSDKMacOSProcess( _core, build, f, installDir ) );
						else
							_loadQueue.addProcess( new ExtractAIRSDKProcess( _core, build, f, installDir ) );
						
						_loadQueue.start( function ():void {
							core.exit( APMCore.CODE_OK );
						} );
					}
					
					else
					{
						core.io.stopSpinner( false, "ERROR: Could not get AIR SDK information" );
						core.exit( APMCore.CODE_ERROR );
					}
				} );
				
			}
			
		}
		
		
	}
	
}
