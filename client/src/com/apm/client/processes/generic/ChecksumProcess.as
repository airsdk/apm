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
 * @created		13/8/21
 */
package com.apm.client.processes.generic
{
	import com.apm.client.APM;
	import com.apm.client.logging.Log;
	import com.apm.client.processes.ProcessBase;
	
	import flash.filesystem.File;
	
	
	public class ChecksumProcess extends ProcessBase
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "ChecksumProcess";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _file:File;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function ChecksumProcess( file:File )
		{
			_file = file;
		}
		
		
		override public function start( completeCallback:Function = null, failureCallback:Function = null ):void
		{
			super.start( completeCallback, failureCallback );
			Log.d( TAG, "start: " + _file.name );
			var subprocess:ProcessBase;
			if (APM.config.isMacOS)
			{
				subprocess = new ChecksumMacOSProcess( APM.instance, _file );
			}
			else if (APM.config.isWindows)
			{
				subprocess = new ChecksumWindowsProcess( APM.instance, _file );
			}
			else
			{
				subprocess = new ChecksumAS3Process( APM.instance, _file );
			}
			subprocess.start( complete, failure );
		}
		
		
	}
	
}
