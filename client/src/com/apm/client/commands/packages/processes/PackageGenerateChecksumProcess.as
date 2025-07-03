/**
 * @author 		Michael Archbold (https://michaelarchbold.com)
 * @created		15/6/2021
 */
package com.apm.client.commands.packages.processes
{
	import by.blooddy.crypto.SHA256;
	import by.blooddy.crypto.events.ProcessEvent;
	
	import com.apm.client.APM;
	import com.apm.client.processes.ProcessBase;
	import com.apm.client.processes.generic.ChecksumProcess;
	import com.apm.data.packages.PackageDefinitionFile;
	
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	import flash.utils.ByteArray;
	
	
	/**
	 * Loads a PackageDefinitionFile from a File reference.
	 * <br/>
	 * This process is really just for delaying the load until a point in the queue
	 * (generally when extracting a package from a zip).
	 */
	public class PackageGenerateChecksumProcess extends ProcessBase
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "PackageGenerateChecksumProcess";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _packageDefinition:PackageDefinitionFile;
		private var _file:File;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function PackageGenerateChecksumProcess( packageDefinition:PackageDefinitionFile, file:File )
		{
			_packageDefinition = packageDefinition;
			_file = file;
		}
		
		
		override public function start( completeCallback:Function = null, failureCallback:Function = null ):void
		{
			super.start( completeCallback, failureCallback );
			APM.io.showSpinner( "Generating package checksum: " + _file.nativePath );
			if (!_file.exists)
			{
				APM.io.stopSpinner( false, "Package doesn't exist: " + _file.nativePath );
				return failure();
			}
			
			
			var subprocess:ChecksumProcess = new ChecksumProcess( _file );
			
			subprocess.start(
					function( data:Object ):void
					{
						var result:String = String(data);
						_packageDefinition.version.checksum = result;
						APM.io.stopSpinner( true, "Generated checksum: " + result );
						complete();
					},
					function( error:String ):void
					{
						APM.io.stopSpinner( false, "ERROR: " + error );
						failure();
					});
			
		}
		
	}
	
}
