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
 * @created		18/5/21
 */
package com.apm.data.project
{
	import com.apm.SemVerRange;
	import com.apm.data.install.InstallPackageData;
	import com.apm.data.packages.PackageDependency;
	import com.apm.data.packages.PackageIdentifier;
	import com.apm.data.packages.PackageParameter;
	import com.apm.data.packages.PackageVersion;
	import com.apm.data.packages.RepositoryDefinition;
	import com.apm.utils.JSONUtils;
	
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	
	/**
	 * Handles loading and saving a project lock file
	 */
	public class ProjectLock
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "ProjectLock";
		
		
		public static const DEFAULT_FILENAME:String = "project-lock.apm";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _data:Object;
		
		private var _sourceFile:File;
		
		private var _dependencies:Vector.<InstallPackageData>;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function ProjectLock()
		{
			_data = {};
			
			_dependencies = new <InstallPackageData>[];
		}
		
		
		public function parse( content:String ):void
		{
			_data = JSON.parse( content );
			
			if (_data.hasOwnProperty( "dependencies" ))
			{
				_dependencies = new Vector.<InstallPackageData>();
				for each (var dep:Object in _data.dependencies)
				{
					_dependencies.push( new InstallPackageData().fromObject( dep ) );
				}
			}
			
		}
		
		
		public function stringify():String
		{
			var data:Object = toObject();
			return JSON.stringify( data, null, 4 ) + "\n";
		}
		
		
		public function toObject():Object
		{
			var data:Object = {};
			
			var deps:Array = [];
			for each (var dep:InstallPackageData in _dependencies)
			{
				deps.push( dep.toObject() );
			}
			data[ "dependencies" ] = deps;
			
			_data = data;
			
			return data;
		}
		
		
		//
		//	OPTIONS
		//
		
		
		public function get dependencies():Vector.<InstallPackageData>
		{
			if (_dependencies == null)
			{
				_dependencies = new Vector.<InstallPackageData>();
			}
			return _dependencies;
		}
		
		
		/**
		 * Removes all current dependencies in the project definition
		 *
		 * @return <code>ProjectDefinition</code> instance for chaining calls
		 */
		public function clearPackageDependencies():ProjectLock
		{
			_dependencies = new Vector.<InstallPackageData>();
			return this;
		}
		
		
		/**
		 * Adds a package as a project dependency
		 *
		 * @param packageVersion
		 *
		 * @return <code>ProjectDefinition</code> instance for chaining calls
		 */
		public function addPackageDependency( packageData:InstallPackageData ):ProjectLock
		{
			if (hasDependency( packageData.packageVersion.packageDef.identifier ))
			{
				removePackageDependency( packageData.packageVersion.packageDef.identifier );
			}
			dependencies.push( packageData );
			return this;
		}
		
		
		/**
		 * Returns true if the project already contains a dependency on the specified package
		 *
		 * @param identifier
		 *
		 * @return
		 */
		public function hasDependency( identifier:String ):Boolean
		{
			return getPackageDependency( identifier ) != null;
		}
		
		
		/**
		 * Finds a package install data matching the specified identifier
		 *
		 * @param identifier
		 *
		 * @return The <code>InstallPackageData</code> or <code>null</code> if not found.
		 */
		public function getPackageDependency( identifier:String ):InstallPackageData
		{
			for each (var data:InstallPackageData in _dependencies)
			{
				if (PackageIdentifier.isEquivalent( data.packageVersion.packageDef.identifier, identifier ))
				{
					return data;
				}
			}
			return null;
		}
		
		
		/**
		 * Removes a package dependency matching the specified identifier
		 *
		 * @param identifier
		 *
		 * @return <code>ProjectDefinition</code> instance for chaining calls
		 */
		public function removePackageDependency( identifier:String ):ProjectLock
		{
			for (var i:int = _dependencies.length - 1; i >= 0; --i)
			{
				if (PackageIdentifier.isEquivalent( _dependencies[ i ].packageVersion.packageDef.identifier, identifier ))
				{
					_dependencies.splice( i, 1 );
				}
			}
			return this;
		}
		
		
		//
		//	IO
		//
		
		/**
		 * Saves this project definition into the specified file.
		 *
		 * @param f
		 */
		public function save( f:File = null ):void
		{
			if (f == null)
			{
				f = _sourceFile;
			}
			
			if (f == null)
			{
				throw new Error( "No output file specified" );
			}
			
			var content:String = stringify();
			
			var fs:FileStream = new FileStream();
			fs.open( f, FileMode.WRITE );
			fs.writeUTFBytes( content );
			fs.close();
		}
		
		
		/**
		 * Loads the specified file as a project definition file
		 *
		 * @param f
		 *
		 * @return
		 */
		public function load( f:File ):ProjectLock
		{
			if (!f.exists)
			{
				throw new Error( "File doesn't exist" );
			}
			
			_sourceFile = f;
			
			var fs:FileStream = new FileStream();
			fs.open( f, FileMode.READ );
			var content:String = fs.readUTFBytes( fs.bytesAvailable );
			fs.close();
			
			parse( content );
			
			return this;
		}
		
		
	}
	
}
