/**
 * @author 		Michael Archbold (https://michaelarchbold.com)
 * @created		15/6/2021
 */
package com.apm.client.commands.packages.processes
{
	import com.apm.client.APM;
	import com.apm.client.processes.ProcessBase;
	import com.apm.data.packages.PackageDefinitionFile;
	
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	
	/**
	 * Loads a PackageDefinitionFile from a File reference.
	 * <br/>
	 * This process is really just for delaying the load until a point in the queue
	 * (generally when extracting a package from a zip).
	 */
	public class PackageDefinitionLoadProcess extends ProcessBase
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "PackageDefinitionLoadProcess";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _packageDefinition:PackageDefinitionFile;
		private var _file:File;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function PackageDefinitionLoadProcess( packageDefinition:PackageDefinitionFile, file:File )
		{
			_packageDefinition = packageDefinition;
			_file = file;
		}
		
		
		override public function start( completeCallback:Function=null, failureCallback:Function=null ):void
		{
			super.start( completeCallback, failureCallback );
			APM.io.showSpinner( "Loading package definition file: " + _file.nativePath );
			if (!_file.exists)
			{
				APM.io.stopSpinner( false, "Package definition file doesn't exist: " + _file.nativePath );
				return failure();
			}
			
			_packageDefinition.load( _file );
			
			
			// Load README.md if available
			var readmeFile:File = _packageDefinition.sourceFile.parent.resolvePath("README.md");
			if (readmeFile.exists)
			{
				var readmeFileStream:FileStream = new FileStream();
				readmeFileStream.open( readmeFile, FileMode.READ );
				_packageDefinition.readme = readmeFileStream.readUTFBytes( readmeFileStream.bytesAvailable );
				readmeFileStream.close();
			}
			
			
			// Load CHANGELOG.md if available
			var changelogFile:File = _packageDefinition.sourceFile.parent.resolvePath("CHANGELOG.md");
			if (changelogFile.exists)
			{
				var changelogFileStream:FileStream = new FileStream();
				changelogFileStream.open( changelogFile, FileMode.READ );
				_packageDefinition.changelog = changelogFileStream.readUTFBytes( changelogFileStream.bytesAvailable );
				changelogFileStream.close();
			}
			
			APM.io.stopSpinner( true, "Package definition file loaded" );
			complete();
		}
		
	}
	
}
