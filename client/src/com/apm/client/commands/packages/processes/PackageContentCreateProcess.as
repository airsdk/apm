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
	import com.apm.SemVer;
	import com.apm.client.APMCore;
	import com.apm.client.processes.ProcessBase;
	import com.apm.data.packages.PackageDefinitionFile;
	
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	
	import org.as3commons.zip.Zip;
	
	
	/**
	 * Creates a zip for a package structure in the specified path.
	 */
	public class PackageContentCreateProcess extends ProcessBase
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "PackageDefinitionCreateProcess";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _core:APMCore;
		private var _path:String;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function PackageContentCreateProcess( core:APMCore, path:String )
		{
			_core = core;
			_path = path;
		}
		
		
		override public function start():void
		{
			_core.io.showSpinner( "Building package" );
			
			var directory:File = new File( _core.config.workingDir + File.separator + _path );
			if (!directory.exists)
			{
				_core.io.writeError( directory.name, "Specified package directory does not exist" );
				return failure();
			}
			var packageDefinitionFile:File = directory.resolvePath( PackageDefinitionFile.DEFAULT_FILENAME );
			if (!packageDefinitionFile.exists)
			{
				_core.io.writeError( PackageDefinitionFile.DEFAULT_FILENAME, "Package definition file does not exist" );
				return failure();
			}
			var packDefFile:PackageDefinitionFile = new PackageDefinitionFile().load( packageDefinitionFile );
			
			
			var zip:Zip = new Zip();
			
			
			
			var libDir:File = directory.resolvePath( "lib" );
			var aneDir:File = directory.resolvePath( "ane" );
			var srcDir:File = directory.resolvePath( "src" );
			var readmeFile:File = directory.resolvePath( "README.md" );
			var changeLogFile:File = directory.resolvePath( "CHANGELOG.md" );
			var licenseFile:File = directory.resolvePath( "LICENSE.md" );
			var androidFile:File = directory.resolvePath( "android.xml" );
			var iosFile:File = directory.resolvePath( "ios.xml" );
			
			addFileToZip( zip, packageDefinitionFile );
			addFileToZip( zip, readmeFile );
			
			if (changeLogFile.exists) addFileToZip( zip, changeLogFile );
			if (licenseFile.exists) addFileToZip( zip, licenseFile );
			if (androidFile.exists) addFileToZip( zip, androidFile );
			if (iosFile.exists) addFileToZip( zip, iosFile );
			
			
			switch (packDefFile.packageDef.type)
			{
				case "swc":
					addFileToZip( zip, libDir );
					break;
				case "ane":
					addFileToZip( zip, aneDir );
					break;
				case "src":
					addFileToZip( zip, srcDir );
					break;
			}
			
			
			var packageFileName:String = packDefFile.packageDef.identifier + "_" + packDefFile.version.version.toString() + ".zip";
			var packageFilePath:String = _core.config.workingDir + File.separator + packageFileName;
			var packageFile:File = new File( packageFilePath );
			
			var outStream:FileStream = new FileStream();
			outStream.open( packageFile, FileMode.WRITE );
			zip.serialize( outStream );
			outStream.close();
			
			_core.io.stopSpinner(  true,"Package built: " + packageFileName );
			
			complete();
		}
		
		
		private function addFileToZip( zip:Zip, f:File, path:String="" ):void
		{
			_core.io.updateSpinner();
			if (f.isDirectory)
			{
				var files:Array = f.getDirectoryListing();
				for each (var dirFile:File in files)
				{
					addFileToZip( zip, dirFile, path + f.name + "/" );
				}
			}
			else
			{
				var content:ByteArray = new ByteArray();
				
				var fs:FileStream = new FileStream();
				fs.open( f, FileMode.READ );
				fs.readBytes( content );
				fs.close();
				
				var filePath:String = path + f.name;
				
				zip.addFile( filePath, content );
			}
		}
		
		
		
		
		
	}
	
}
