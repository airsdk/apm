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
	import com.apm.client.APMCore;
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
		
		protected var _core:APMCore;
		protected var _zipFile:File;
		protected var _outputDir:File;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function ExtractZipProcess( core:APMCore, zipFile:File, outputDir:File )
		{
			_core = core;
			_zipFile = zipFile;
			_outputDir = outputDir;
		}
		
		
		override public function start( completeCallback:Function=null, failureCallback:Function=null ):void
		{
			super.start( completeCallback, failureCallback );
			var subprocess:ProcessBase;
			if (_core.config.isMacOS)
			{
				subprocess = new ExtractZipMacOSProcess( _core, _zipFile, _outputDir );
			}
			else if (_core.config.isWindows)
			{
				subprocess = new ExtractZipWindowsProcess( _core, _zipFile, _outputDir );
			}
			else
			{
				subprocess = new ExtractZipAS3Process( _core, _zipFile, _outputDir );
			}
			subprocess.start( complete, failure );
		}
		
	}
	
}
