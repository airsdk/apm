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
 * @created		15/9/21
 */
package com.apm.remote.repository
{
	import com.apm.SemVer;
	import com.apm.client.logging.Log;
	import com.apm.data.packages.PackageDefinitionFile;
	
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	
	
	/**
	 * A local file based repository
	 */
	public class LocalRepository extends EventDispatcher implements Repository
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "LocalRepository";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _name:String;
		/**
		 * The name (source name) of this repository
		 */
		public function get name():String  { return _name; }
		public function set name( value:String ):void { _name = value; }
		
		
		private var _path:String;
		
		// Array of objects { id: identifier, versions: array of packages }
		private var _packageGroups:Array;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		/**
		 * Create a local repository reference
		 *
		 * @param path The native path to the directory of the local repository
		 */
		public function LocalRepository( path:String )
		{
			_path = path;
		}
		
		
		public function setName( name:String ):Repository
		{
			_name = name;
			return this;
		}
		
		
		//
		//	TODO:: Currently this class is an experimental addition
		//
		
		
		
		public function search( query:String, callback:Function = null ):void
		{
			callback( false, null );
		}
		
		
		public function getPackage( identifier:String, callback:Function = null ):void
		{
			callback( false, null );
		}
		
		
		public function getPackageVersion( identifier:String, version:SemVer, callback:Function = null ):void
		{
			Log.d( TAG, "local search for: " + identifier + " [" + (version == null ? "latest" : version.toString()) + "]" );
//			try
//			{
//				var repoDir:File = new File( _path );
//				if (repoDir.exists)
//				{
//					loadPackages( repoDir );
//				}
//				else
//				{
//					Log.d( TAG, "repository location doesn't exist: " + _path );
//					callback( false, null );
//				}
//			}
//			catch (e:Error)
//			{
//				Log.e( TAG, e );
//				callback( false, null );
//			}
			
			callback( false, null );
		}
		
		
		public function logEvent( event:String, identifier:String, version:String, callback:Function = null ):void
		{
			callback( false, null );
		}
		
		
		public function setToken( token:String ):Repository
		{
			return this;
		}
		
		
		public function publish( packageDef:PackageDefinitionFile, callback:Function = null ):void
		{
			callback( false, null );
		}
		
		
		////////////////////////////////////////////////////////
		//	IMPLEMENTATION
		//
		
		
		private function loadPackages( repoDir:File ):void
		{
//			for each (var file:File in repoDir.getDirectoryListing())
//			{
//				Log.d( TAG, file.nativePath );
//				if (file.extension == "airpackage")
//				{
//					// Compressed airpackage
//				}
//				else if (file.isDirectory)
//				{
//					//
//					var packDefFile:File = file.resolvePath( PackageDefinitionFile.DEFAULT_FILENAME );
//					if (packDefFile.exists)
//					{
//						var packDef:PackageDefinitionFile = new PackageDefinitionFile().load( packDefFile );
//						if (identifier == packDef.packageDef.identifier)
//						{
//						}
//					}
//				}
//			}
		}
	}
	
}
