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
 * @created		15/6/21
 */
package com.apm.client.commands.packages.processes
{
	import by.blooddy.crypto.SHA256;
	import by.blooddy.crypto.events.ProcessEvent;
	
	import com.apm.client.APMCore;
	import com.apm.client.processes.ProcessBase;
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
		
		private var _core:APMCore;
		private var _packageDefinition:PackageDefinitionFile;
		private var _file:File;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function PackageGenerateChecksumProcess( core:APMCore, packageDefinition:PackageDefinitionFile, file:File )
		{
			_core = core;
			_packageDefinition = packageDefinition;
			_file = file;
		}
		
		
		override public function start():void
		{
			_core.io.showSpinner( "Generating package checksum: " + _file.nativePath );
			if (!_file.exists)
			{
				_core.io.stopSpinner( false, "Package doesn't exist: " + _file.nativePath );
				return failure();
			}
			
			var data:ByteArray = new ByteArray();

			var fs:FileStream = new FileStream();
			fs.open( _file, FileMode.READ );
			fs.readBytes( data );
			fs.close();
			
			
			var hashAlgorithm:SHA256 = new SHA256();
			
			hashAlgorithm.addEventListener( ProcessEvent.COMPLETE, function(event:ProcessEvent):void {
				var result:String = event.data;
				_packageDefinition.version.checksum = result;
				_core.io.stopSpinner( true, "Generated checksum: " + result );
				complete();
			} );
			
			hashAlgorithm.addEventListener( ProcessEvent.ERROR, function(event:ProcessEvent):void {
				var error:Error = event.data;
				_core.io.stopSpinner( false, "ERROR: " + error.message );
				failure();
			} );
			hashAlgorithm.hashBytes( data );
			
		}
		
	}
	
}
