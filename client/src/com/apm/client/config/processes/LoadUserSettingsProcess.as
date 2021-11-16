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
package com.apm.client.config.processes
{
	import com.apm.client.config.RunConfig;
	import com.apm.client.logging.Log;
	import com.apm.client.processes.ProcessBase;
	import com.apm.data.user.UserSettings;
	
	import flash.filesystem.File;
	
	
	/**
	 * Process to load the user settings file (.apm_config) from the user home directory
	 */
	public class LoadUserSettingsProcess extends ProcessBase
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "LoadUserSettingsProcess";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _config:RunConfig;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function LoadUserSettingsProcess( config:RunConfig )
		{
			_config = config;
		}
		
		
		override public function start( completeCallback:Function = null, failureCallback:Function = null ):void
		{
			super.start( completeCallback, failureCallback );
			Log.d( TAG, "start()" );
			try
			{
				var f:File = new File( _config.homeDirectory + File.separator + UserSettings.DEFAULT_FILENAME );
				if (f != null && f.exists)
				{
					_config.user.load( f );
				}
				else
				{
					Log.d( TAG, "User settings file doesn't exist" );
				}
			}
			catch (e:Error)
			{
				Log.e( TAG, e );
			}
			
			complete();
		}
		
		
	}
	
}
