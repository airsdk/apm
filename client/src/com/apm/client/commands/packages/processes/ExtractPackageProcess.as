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
	import com.apm.client.APMCore;
	import com.apm.client.Consts;
	import com.apm.client.commands.packages.utils.PackageFileUtils;
	import com.apm.client.processes.ProcessBase;
	import com.apm.data.packages.PackageVersion;
	
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	
	import flash.utils.setTimeout;
	
	import org.as3commons.zip.IZipFile;
	
	import org.as3commons.zip.Zip;
	
	
	public class ExtractPackageProcess extends ProcessBase
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "ExtractPackageProcess";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _core:APMCore;
		private var _package:PackageVersion;
		private var _packageDir:File;
		private var _packageFile:File;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function ExtractPackageProcess( core:APMCore, packageVersion:PackageVersion )
		{
			super();
			_core = core;
			_package = packageVersion;
			
			_packageDir = new File( _core.config.packagesDir + File.separator + _package.packageDef.identifier );
			var filename:String = _package.packageDef.identifier + "_" + _package.version.toString() + "." + PackageFileUtils.AIRPACKAGEEXTENSION;
			_packageFile = _packageDir.resolvePath( filename );
		}
		
		
		override public function start():void
		{
			_core.io.showProgressBar( "Extracting package : " + _package.packageDef.toString() );
			
			try
			{
				var destination:File = _packageDir;
				if (_packageFile.exists)
				{
					var bytesLoaded:uint = 0;
					var sourceBytes:ByteArray = new ByteArray();
					
					var sourceStream:FileStream = new FileStream();
					sourceStream.open( _packageFile, FileMode.READ );
					sourceStream.readBytes( sourceBytes );
					sourceStream.close();
					
					var zip:Zip = new Zip();
					zip.loadBytes( sourceBytes );
					
					for (var i:uint = 0; i < zip.getFileCount(); i++)
					{
						var zipFile:IZipFile = zip.getFileAt( i );
						var extracted:File = destination.resolvePath( zipFile.filename );
						extracted.parent.createDirectory();
						
						if (zipFile.filename.charAt( zipFile.filename.length - 1 ) != "/")
						{
							if (!extracted.isDirectory)
							{
								var fs:FileStream = new FileStream();
								fs.open( extracted, FileMode.WRITE );
								fs.writeBytes( zipFile.content );
								fs.close();
							}
						}
						
						bytesLoaded += zipFile.sizeCompressed;
						
						_core.io.updateProgressBar( bytesLoaded / sourceBytes.length, "Extracting package " + _package.packageDef.toString() );
					}
				}
				else
				{
					_core.io.completeProgressBar( false, "Package zip not found" );
					return failure( "Package zip not found" );
				}
			}
			catch (e:Error)
			{
				_core.io.completeProgressBar( false, e.message );
				return failure( e.message );
			}
			
			_core.io.completeProgressBar( true, "extracted" );
			complete();
		}
		
		
	}
	
}
