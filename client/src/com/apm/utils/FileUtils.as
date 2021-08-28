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
	import com.apm.client.APMCore;
	import com.apm.client.logging.Log;
	
	import flash.filesystem.File;
	
	
	public class FileUtils
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "FileUtils";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		
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
			return appStorageDirectory.resolvePath("tools");
		}
		
		
		/**
		 * Returns a global location for utilities used by the client
		 */
		public static function get tmpDirectory():File
		{
			var tmpDir:File = new File( APMCore.instance.config.workingDir ).resolvePath(".tmp" );
//			if (!tmpDir.exists) tmpDir.createDirectory();
			return tmpDir;
		}
		
		
		/**
		 * Finds all files in a directory and subdirectores with the specified name
		 * @param filename	The file name to search for
		 * @param directory	The base directory to search
		 * @return	An Array of File objects
		 */
		public static function getFilesByName( filename:String, directory:File ):Array
		{
			var files:Array = [];
			if (directory != null && directory.exists)
			{
				for each (var f:File in directory.getDirectoryListing())
				{
					if (f.isDirectory)
					{
						files = files.concat(
								getFilesByName( filename, f )
						);
					}
					else if (f.name == filename)
					{
						files.push( f );
					}
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
						Log.d( TAG, e.message );
					}
				}
			}
		}
		
		
	}
	
}
