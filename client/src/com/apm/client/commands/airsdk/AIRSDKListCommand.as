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
	
	
	public class AIRSDKListCommand implements Command
	{
		
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "AIRSDKListCommand";
		
		
		public static const NAME:String = "airsdk/list";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _parameters:Array;
		
		private var _airsdkAPI:AIRSDKAPI;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function AIRSDKListCommand()
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
		
		
		public function get description():String
		{
			return "lists available AIR SDK versions";
		}
		
		
		public function get usage():String
		{
			return description + "\n" +
					"\n" +
					"apm airsdk list          lists available AIR SDK versions\n"
		}
		
		
		public function execute( core:APMCore ):void
		{
			core.io.showSpinner( "Retrieving AIR SDK list" );
			
			_airsdkAPI.getReleases( function ( success:Boolean, builds:Array, message:String ):void {
				if (success)
				{
					core.io.stopSpinner( true, "Downloaded AIR SDK list" );
					
					var dtf:DateTimeFormatter = new DateTimeFormatter( "en-US" );
					dtf.setDateTimePattern( "yyyy-MM-dd" );
					for each (var build:AIRSDKBuild in builds)
					{
						core.io.writeLine( " - " + build.version + "[" + dtf.format( build.releaseDate ) + "]" );
					}
				}
				else
				{
					core.io.stopSpinner( false, "ERROR: Could not get list" );
				}
				core.exit( APMCore.CODE_OK );
			} );
			
		}
		
	}
	
}
