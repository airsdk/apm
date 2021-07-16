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
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	
	import org.as3commons.zip.IZipFile;
	import org.as3commons.zip.Zip;
	
	
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
		
		
		override public function start():void
		{
			if (_core.config.isMacOS) processQueue.addProcess( new ExtractZipMacOSProcess( _core, _zipFile, _outputDir ));
			else processQueue.addProcess( new ExtractZipAS3Process( _core, _zipFile, _outputDir ));
			complete();
		}
		
	}
	
}
