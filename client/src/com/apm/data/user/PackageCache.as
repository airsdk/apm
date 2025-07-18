/**
 * @author 		Michael Archbold (https://michaelarchbold.com)
 * @created		7/12/2022
 */
package com.apm.data.user
{
	import com.apm.data.packages.PackageVersion;
	import com.apm.utils.PackageFileUtils;

	import flash.events.Event;
	import flash.events.IOErrorEvent;

	import flash.filesystem.File;

	/**
	 * Represents the user air package cache.
	 * <br/>
	 * This is a location in the user's directory where we store downloaded airpackages
	 * for easy installation across projects to avoid multiple downloads.
	 */
	public class PackageCache
	{
		////////////////////////////////////////////////////////
		//	CONSTANTS
		//

		private static const TAG:String = "PackageCache";


		public static const PACKAGE_CACHE_DIR:String = "airpackages";


		////////////////////////////////////////////////////////
		//	VARIABLES
		//

		private var _packageCacheDir:File;


		////////////////////////////////////////////////////////
		//	FUNCTIONALITY
		//

		/**
		 * Constructor
		 *
		 * @param airSdkCacheDir This should be the cache directory which contains the "airpackages" directory eg ~/.airsdk/cache
		 */
		public function PackageCache( airSdkCacheDir:File )
		{
			var packageCacheDir:File = airSdkCacheDir.resolvePath( PackageCache.PACKAGE_CACHE_DIR );
			if (!packageCacheDir.exists) packageCacheDir.createDirectory();

			_packageCacheDir = packageCacheDir;
		}


		/**
		 *
		 * @param airpackage
		 * @return
		 */
		public function hasPackage( airpackage:PackageVersion ):Boolean
		{
			return getPackageFile(airpackage).exists;
		}


		/**
		 * Retrieve the File reference for the airpackage in the package cache
		 *
		 * @param airpackage
		 *
		 * @return File reference for the airpackage
		 */
		public function getPackageFile( airpackage:PackageVersion ):File
		{
			return PackageFileUtils.fileForPackage(
					_packageCacheDir.nativePath,
					airpackage );
		}


		/**
		 * Retrieves an airpackage from the cache, copying it to the specified location.
		 *
		 * @param airpackage
		 * @param dest
		 * @param callback
		 */
		public function copyPackageFile( airpackage:PackageVersion, dest:File, callback:Function ):void
		{
			if (hasPackage(airpackage))
			{
				var cachePackage:File = getPackageFile( airpackage );
				copyToAsync( cachePackage, dest, callback );
			}
			else
			{
				callback( false );
			}
		}


		/**
		 * Adds a package to the cache.
		 *
		 * Copies the file to the appropriate location and replaces any existing file in that cache
		 *
		 * @param airpackage
		 * @param file
		 * @param callback
		 */
		public function putPackageFile( airpackage:PackageVersion, file:File, callback:Function ):void
		{
			cacheDirectoryForPackage(airpackage.packageDef.identifier)
					.createDirectory();

			var cacheLocation:File = getPackageFile( airpackage );
			copyToAsync( file, cacheLocation, callback );
		}


		////////////////////////////////////////////////////////
		//	INTERNALS
		//

		private function cacheDirectoryForPackage( identifier:String ):File
		{
			return PackageFileUtils.directoryForPackage(
					_packageCacheDir.nativePath,
					identifier
			);
		}


		private function copyToAsync( source:File, dest:File, callback:Function ):void
		{
			if (source != null && source.exists)
			{
				var completeHandler:Function = function( event:Event ):void
				{
					event.currentTarget.removeEventListener( Event.COMPLETE, completeHandler );
					event.currentTarget.removeEventListener( IOErrorEvent.IO_ERROR, errorHandler );

					callback( true );
				};

				var errorHandler:Function = function( event:Event ):void
				{
					event.currentTarget.removeEventListener( Event.COMPLETE, completeHandler );
					event.currentTarget.removeEventListener( IOErrorEvent.IO_ERROR, errorHandler );

					callback( false );
				};

				source.addEventListener( Event.COMPLETE, completeHandler );
				source.addEventListener( IOErrorEvent.IO_ERROR, errorHandler );
				source.copyToAsync( dest, true );
			}
			else
			{
				callback( false );
			}
		}



		////////////////////////////////////////////////////////
		//	EVENT HANDLERS
		//

	}
}
