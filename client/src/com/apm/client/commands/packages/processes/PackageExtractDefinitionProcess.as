/**
 * @author 		Michael Archbold (https://michaelarchbold.com)
 * @created		16/9/2021
 */
package com.apm.client.commands.packages.processes
{
	import com.apm.client.logging.Log;
	import com.apm.client.processes.ProcessBase;
	import com.apm.data.packages.PackageDefinitionFile;
	import com.apm.utils.FileUtils;
	
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	
	import org.as3commons.zip.IZipFile;
	import org.as3commons.zip.Zip;
	
	
	/**
	 * Extracts the package definition from an airpackage file.
	 * <br/>
	 *
	 * i.e. unzip the supplied <code>File</cod> and load the <code>package.json</code>
	 * into the supplied <code>PackageDefinitionFile</code> instance.
	 */
	public class PackageExtractDefinitionProcess extends ProcessBase
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "PackageExtractDefinitionProcess";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _packageDefinition:PackageDefinitionFile;
		private var _packageFile:File;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function PackageExtractDefinitionProcess( packageDefinition:PackageDefinitionFile, packageFile:File )
		{
			_packageDefinition = packageDefinition;
			_packageFile = packageFile;
		}
		
		
		override public function start( completeCallback:Function = null, failureCallback:Function = null ):void
		{
			super.start( completeCallback, failureCallback );
			try
			{
				if (!_packageFile.exists)
				{
					failure( "Package file does not exist: " + _packageFile.nativePath );
					return;
				}
				
				if (!FileUtils.tmpDirectory.exists) FileUtils.tmpDirectory.createDirectory();
				var tmpPackageDefFile:File = FileUtils.tmpDirectory.resolvePath( _packageFile.name + ".json" );
				
				var sourceBytes:ByteArray = new ByteArray();
				
				var sourceStream:FileStream = new FileStream();
				sourceStream.open( _packageFile, FileMode.READ );
				sourceStream.readBytes( sourceBytes );
				sourceStream.close();
				
				var zip:Zip = new Zip();
				zip.loadBytes( sourceBytes );
				
				var zipFile:IZipFile = zip.getFileByName( PackageDefinitionFile.DEFAULT_FILENAME );
				if (zipFile == null)
				{
					failure( "Package file invalid format (missing package.json): " + _packageFile.nativePath );
					return;
				}
				
				var fs:FileStream = new FileStream();
				fs.open( tmpPackageDefFile, FileMode.WRITE );
				fs.writeBytes( zipFile.content );
				fs.close();
				
				_packageDefinition.load( tmpPackageDefFile );
				
				tmpPackageDefFile.deleteFile();
				
				complete();
			}
			catch (e:Error)
			{
				Log.e( TAG, e );
				failure( e.message );
			}
		}
		
	}
}
