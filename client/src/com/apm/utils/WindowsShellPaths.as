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
 * @brief
 * @author 		marchbold
 * @created		24/11/2021
 * @copyright	http://distriqt.com/copyright/license.txt
 */
package com.apm.utils
{
	import com.apm.client.logging.Log;
	
	import flash.filesystem.File;
	
	
	public class WindowsShellPaths
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "WindowsShellPaths";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function WindowsShellPaths()
		{
		}
		
		
		public static function getCmdInterpreter( env:Object = null ):File
		{
			try
			{
				if (env != null && env.hasOwnProperty( "COMSPEC" ))
				{
					var comspec:File = new File( env[ "COMSPEC" ] );
					if (comspec.exists)
						return comspec;
				}
				
				// Try default location
				var cmd:File = new File( "C:\\WINDOWS\\System32\\cmd.exe" );
				if (cmd.exists)
					return cmd;
			}
			catch (e:Error)
			{
				Log.e( TAG, e );
			}
			return null;
		}
		
		
		public static function getPowershell( env:Object = null ):File
		{
			try
			{
				if (env != null && env.hasOwnProperty( "SYSTEMROOT" ))
				{
					var powershell:File = new File( env[ "SYSTEMROOT" ] + "\\System32\\WindowsPowerShell\\v1.0\\powershell.exe" );
					if (powershell.exists)
						return powershell;
				}
				
				var defaultLocation:File = new File( "C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe" );
				if (defaultLocation.exists)
					return defaultLocation;
			}
			catch (e:Error)
			{
				Log.e( TAG, e );
			}
			return null;
		}
		
	}
}
