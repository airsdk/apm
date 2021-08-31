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
package com.apm.client.processes.generic
{
	import com.apm.client.APM;
	import com.apm.client.processes.ProcessBase;
	
	import flash.filesystem.File;
	
	
	public class ExtractZipProcess extends ProcessBase
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "ExtractZipProcess";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		protected var _zipFile:File;
		protected var _outputDir:File;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function ExtractZipProcess( zipFile:File, outputDir:File )
		{
			_zipFile = zipFile;
			_outputDir = outputDir;
		}
		
		
		override public function start( completeCallback:Function=null, failureCallback:Function=null ):void
		{
			super.start( completeCallback, failureCallback );
			var subprocess:ProcessBase;
			if (APM.config.isMacOS)
			{
				subprocess = new ExtractZipMacOSProcess( _zipFile, _outputDir );
			}
			else if (APM.config.isWindows)
			{
				subprocess = new ExtractZipWindowsProcess( _zipFile, _outputDir );
			}
			else
			{
				subprocess = new ExtractZipAS3Process( _zipFile, _outputDir );
			}
			subprocess.start( complete, failure );
		}
		
	}
	
}
