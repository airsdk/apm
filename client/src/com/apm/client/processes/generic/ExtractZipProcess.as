/**
 * @author 		Michael Archbold (https://michaelarchbold.com)
 * @created		28/5/2021
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
		protected var _showOutputs:Boolean;
		protected var _deleteDirectory:Boolean;

		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//

		public function ExtractZipProcess( zipFile:File, outputDir:File, showOutputs:Boolean = true, deleteDirectory:Boolean = true )
		{
			_zipFile = zipFile;
			_outputDir = outputDir;
			_showOutputs = showOutputs;
			_deleteDirectory = deleteDirectory;
		}


		override public function start( completeCallback:Function = null, failureCallback:Function = null ):void
		{
			super.start( completeCallback, failureCallback );
			var subprocess:ProcessBase;
			if (ExtractZipAIRProcess.isAvailable())
			{
				subprocess = new ExtractZipAIRProcess( _zipFile, _outputDir, _showOutputs, _deleteDirectory );
			}
			else if (APM.config.isMacOS)
			{
				subprocess = new ExtractZipMacOSProcess( _zipFile, _outputDir, _showOutputs, _deleteDirectory );
			}
			else if (APM.config.isWindows)
			{
				subprocess = new ExtractZipWindowsProcess( _zipFile, _outputDir, _showOutputs, _deleteDirectory );
			}
			else if (APM.config.isLinux)
			{
				subprocess = new ExtractZipLinuxProcess( _zipFile, _outputDir, _showOutputs, _deleteDirectory );
			}
			else
			{
				subprocess = new ExtractZipAS3Process( _zipFile, _outputDir, _showOutputs, _deleteDirectory );
			}
			subprocess.start( complete, failure );
		}

	}

}
