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
	import com.apm.remote.airsdk.AIRSDKAPI;
	import com.apm.remote.airsdk.AIRSDKBuild;
	
	import flash.globalization.DateTimeFormatter;
	
	
	public class AIRSDKViewCommand implements Command
	{
		
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "AIRSDKViewCommand";
		
		
		public static const NAME:String = "airsdk/view";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _parameters:Array;
		
		private var _airsdkAPI:AIRSDKAPI;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function AIRSDKViewCommand()
		{
			super();
			
			_airsdkAPI = new AIRSDKAPI();
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
			return "gets information about a specific AIR SDK version";
		}
		
		
		public function get usage():String
		{
			return description + "\n" +
					"\n" +
					"apm airsdk view <version>          gets information about a specific AIR SDK version\n" +
					"apm airsdk view latest             gets information about the latest AIR SDK version\n"
		}
		
		
		public function execute( core:APMCore ):void
		{
			if (_parameters == null || _parameters.length == 0)
			{
				core.io.writeLine( "You need to provide an AIR SDK version" );
				core.exit( APMCore.CODE_ERROR );
			}
			else
			{
				var airsdkVersion:String = _parameters[ 0 ];
				core.io.showSpinner( "Retrieving AIR SDK information : " + airsdkVersion );
				
				_airsdkAPI.getRelease( airsdkVersion, function ( success:Boolean, build:AIRSDKBuild, message:String ):void {
					if (success)
					{
						core.io.stopSpinner( true, "Retrieved AIR SDK information : " + build.version );
						
						var dtf:DateTimeFormatter = new DateTimeFormatter( "en-US" );
						dtf.setDateTimePattern( "yyyy-MM-dd" );
						
						core.io.writeLine( "AIR SDK v" + build.version );
						core.io.writeLine( "  Release Date: " + dtf.format( build.releaseDate ) );
						
						core.io.writeLine( "  Release Notes: " );
						for each (var note:Object in build.releaseNotes)
						{
							core.io.writeLine( "    [" + note.reference +"] : " + note.description );
						}
						
					}
					else
					{
						core.io.stopSpinner( false, "ERROR: Could not get AIR SDK information" );
					}
					core.exit( APMCore.CODE_OK );
				} );
				
			}
			
		}
		
	}
	
}
