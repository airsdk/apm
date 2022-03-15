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
 * @created		24/6/21
 */
package com.apm.utils
{
	import com.apm.client.APM;
	import com.apm.client.logging.Log;
	
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	
	public class FileUtils
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "FileUtils";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		
		private static var _tmpDirName:String;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function FileUtils()
		{
		}
		
		
		/**
		 * Returns a global location for files stored / downloaded / used by the client
		 */
		public static function get appStorageDirectory():File
		{
			return File.applicationStorageDirectory;
		}
		
		
		/**
		 * Returns a global location for utilities used by the client
		 */
		public static function get toolsDirectory():File
		{
			return appStorageDirectory.resolvePath( "tools" );
		}
		
		
		/**
		 * Returns a global location for utilities used by the client
		 */
		public static function get tmpDirectory():File
		{
			if (_tmpDirName == null) _tmpDirName = ".tmp" + String( int( Math.random() * 1000000 ) );
			var tmpDir:File = new File( APM.config.workingDirectory ).resolvePath( _tmpDirName );
//			if (!tmpDir.exists) tmpDir.createDirectory();
			return tmpDir;
		}
		
		
		/**
		 * Finds all files in a directory and subdirectores with the specified name
		 * - lists the files before the directories.
		 *
		 * @param filename	The file name to search for
		 * @param directory	The base directory to search
		 * @return	An Array of File objects
		 */
		public static function getFilesByName( filename:String, directory:File ):Array
		{
			var files:Array = [];
			if (directory != null && directory.exists)
			{
				var subdirectories:Array = [];
				for each (var f:File in directory.getDirectoryListing())
				{
					if (f.isDirectory)
					{
						subdirectories.push( f );
					}
					else if (f.name == filename)
					{
						files.push( f );
					}
				}
				for each (var dir:File in subdirectories)
				{
					files = files.concat(
							getFilesByName( filename, f )
					);
				}
			}
			return files;
		}
		
		
		public static function countFiles( directory:File ):int
		{
			var count:int = 0;
			for each (var f:File in directory.getDirectoryListing())
			{
				if (f.isDirectory)
				{
					count += countFiles( f );
				}
				else
				{
					count++;
				}
			}
			return count;
		}
		
		
		public static function countFilesByType( directory:File, type:String ):int
		{
			var count:int = 0;
			for each (var f:File in directory.getDirectoryListing())
			{
				if (f.isDirectory)
				{
					count += countFilesByType( f, type );
				}
				else if (f.extension == type)
				{
					count++;
				}
			}
			return count;
		}
		
		
		public static function copyDirectoryTo( src:File, dest:File, overwrite:Boolean = false ):void
		{
			if (!dest.exists) dest.createDirectory();
			
			var directory:Array = src.getDirectoryListing();
			for each (var f:File in directory)
			{
				if (f.isDirectory)
					copyDirectoryTo( f, dest.resolvePath( f.name ), overwrite );
				else
					f.copyTo( dest.resolvePath( f.name ), overwrite );
			}
		}
		
		
		public static function removeEmptyDirectories( directory:File, recurse:Boolean = false ):void
		{
			if (directory != null && directory.exists)
			{
				for each (var f:File in directory.getDirectoryListing())
				{
					try
					{
						if (f.isDirectory)
						{
							if (countFiles( f ) == 0)
							{
								f.deleteDirectory( true );
							}
							else if (recurse)
							{
								removeEmptyDirectories( f, recurse );
							}
						}
					}
					catch (e:Error)
					{
						Log.e( TAG, e );
					}
				}
			}
		}
		
		
		public static function readFileContentAsString( file:File ):String
		{
			var fs:FileStream = new FileStream();
			fs.open( file, FileMode.READ );
			var content:String = fs.readUTFBytes( fs.bytesAvailable );
			fs.close();
			return content;
		}
		
		
		public static function writeStringAsFileContent( file:File, content:String ):void
		{
			var fileStream:FileStream = new FileStream();
			fileStream.open( file, FileMode.WRITE );
			fileStream.writeUTFBytes( content );
			fileStream.close();
		}
		
		
		/**
		 * Determines the File reference specified by path by checking it as an
		 * absolute path and then a relative path to the working directory.
		 *
		 * @param path
		 *
		 * @return
		 */
		public static function getSourceForPath( path:String ):File
		{
			try
			{
				var absolute:File = new File( path );
				if (absolute.exists)
				{
					return absolute;
				}
			}
			catch (e:Error)
			{
			}
			return new File( APM.config.workingDirectory + File.separator + path );
		}
		
	}
	
}
