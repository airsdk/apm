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
	import com.apm.data.packages.PackageDefinition;
	import com.apm.data.packages.PackageDependency;
	import com.apm.data.packages.PackageVersion;
	import com.apm.data.packages.Repository;
	
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	
	/**
	 * Handles loading and saving a project definition file
	 */
	public class ProjectDefinition
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "ProjectDefinition";
		
		
		public static const DEFAULT_FILENAME:String = "project.apm";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _data:Object;
		
		private var _sourceFile:File;
		
		private var _repositories:Vector.<Repository>;
		private var _dependencies:Vector.<PackageDependency>;
		private var _configuration:Object;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function ProjectDefinition()
		{
			_data = {};
			
			_repositories = new Vector.<Repository>();
			_dependencies = new Vector.<PackageDependency>();
			_configuration = {};
		}
		
		
		public function parse( content:String ):void
		{
			_data = JSON.parse( content );
			
			if (_data.hasOwnProperty( "repositories" ))
			{
				_repositories = new Vector.<Repository>();
				for each (var rep:Object in _data.repositories)
				{
					_repositories.push( Repository.fromObject( rep ) );
				}
			}
			
			if (_data.hasOwnProperty( "dependencies" ))
			{
				_dependencies = new Vector.<PackageDependency>();
				for each (var dep:Object in _data.dependencies)
				{
					_dependencies.push( new PackageDependency().fromObject( dep ) );
				}
			}
			
			if (_data.hasOwnProperty( "configuration" ))
			{
				_configuration = _data.configuration;
			}
		}
		
		
		public function stringify():String
		{
			return JSON.stringify( toObject(), null, 4 ) + "\n";
		}
		
		
		public function toObject():Object
		{
			var data:Object = {};
			
			data[ "identifier" ] = applicationId;
			data[ "name" ] = applicationName;
			data[ "version" ] = version;
			
			var repos:Array = [];
			for each (var repo:Repository in _repositories)
			{
				repos.push( repo.toObject() );
			}
			data[ "repositories" ] = repos;
			
			var deps:Array = [];
			for each (var dep:PackageDependency in _dependencies)
			{
				deps.push( dep.toObject() );
			}
			data[ "dependencies" ] = deps;
			
			data.configuration = _configuration;
			
			_data = data;
			
			return data;
		}
		
		
		//
		//	OPTIONS
		//
		
		public function get applicationId():String { return _data[ "identifier" ]; }
		
		
		public function set applicationId( value:String ):void { _data[ "identifier" ] = value; }
		
		
		public function get applicationName():String { return _data[ "name" ]; }
		
		
		public function set applicationName( value:String ):void { _data[ "name" ] = value; }
		
		
		public function get version():String { return _data[ "version" ]; }
		
		
		public function set version( value:String ):void { _data[ "version" ] = value; }
		
		
		public function get repositories():Vector.<Repository> { return _repositories; }
		
		
		public function get dependencies():Vector.<PackageDependency>
		{
			if (_dependencies == null)
				_dependencies = new Vector.<PackageDependency>();
			return _dependencies;
		}
		
		
		public function get configuration():Object { return _configuration; }
		
		
		/**
		 * Retrieves the specified configuration parameter
		 * @param key	The name of the parameter
		 * @return	The value for the parameter or null if the parameter name could not be found
		 */
		public function getConfigurationParam( key:String ):String
		{
			if (_configuration.hasOwnProperty( key ))
			{
				return _configuration[ key ];
			}
			return null;
		}
		
		
		/**
		 * Sets a value for the configuration parameter
		 *
		 * @param key		The name of the parameter
		 * @param value		The value for the parameter
		 */
		public function setConfigurationParam( key:String, value:String ):void
		{
			if (_configuration == null) _configuration = {};
			_configuration[ key ] = value;
		}
		
		
		
		public function clearPackageDependencies():void
		{
			_dependencies = new Vector.<PackageDependency>();
		}
		
		
		/**
		 * Adds a package as a project dependency
		 *
		 * @param packageVersion
		 */
		public function addPackageDependency( packageVersion:PackageVersion ):void
		{
			if (!hasDependency( packageVersion.packageDef.identifier ))
			{
				var dep:PackageDependency = new PackageDependency();
				dep.identifier = packageVersion.packageDef.identifier;
				dep.version =packageVersion.version;
				
				dependencies.push( dep );
			}
			else
			{
				// TODO:: Handle duplicates / version clash
			}
		}
		
		
		/**
		 * Returns true if the project already contains a dependency on the specified package
		 * @param identifier
		 * @return
		 */
		public function hasDependency( identifier:String ):Boolean
		{
			for each (var dep:PackageDependency in _dependencies)
			{
				if (dep.identifier == identifier)
					return true;
			}
			return false;
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
		public function load( f:File ):ProjectDefinition
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
