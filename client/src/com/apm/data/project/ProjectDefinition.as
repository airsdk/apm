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
	import com.apm.data.packages.PackageDependency;
	import com.apm.data.packages.PackageIdentifier;
	import com.apm.data.packages.PackageVersion;
	import com.apm.data.packages.RepositoryDefinition;
	import com.apm.utils.JSONUtils;
	
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
		
		private var _repositories:Vector.<RepositoryDefinition>;
		private var _dependencies:Vector.<PackageDependency>;
		private var _configuration:Object;
		private var _deployOptions:Object;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function ProjectDefinition()
		{
			_data = {};
			
			_repositories = new Vector.<RepositoryDefinition>();
			_dependencies = new Vector.<PackageDependency>();
			_configuration = {};
			_deployOptions = {};
		}
		
		
		public function parse( content:String ):void
		{
			_data = JSON.parse( content );
			
			if (_data.hasOwnProperty( "repositories" ))
			{
				_repositories = new Vector.<RepositoryDefinition>();
				for each (var rep:Object in _data.repositories)
				{
					_repositories.push( RepositoryDefinition.fromObject( rep ) );
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
			
			if (_data.hasOwnProperty( "deployOptions" ))
			{
				_deployOptions = _data.deployOptions;
			}
		}
		
		
		public function stringify():String
		{
			var data:Object = toObject();
			
			// Ensures the output JSON format is in a familiar order
			var keyOrder:Array = ["identifier", "name", "filename", "version", "versionLabel", "dependencies", "configuration", "repositories"];
			JSONUtils.addMissingKeys( data, keyOrder );
			
			return JSON.stringify( data, keyOrder, 4 ) + "\n";
		}
		
		
		public function toObject():Object
		{
			var data:Object = {};
			
			data[ "identifier" ] = applicationId;
			data[ "name" ] = applicationName;
			data[ "filename" ] = applicationFilename;
			data[ "version" ] = version;
			data[ "versionLabel" ] = versionLabel;
			
			var repos:Array = [];
			for each (var repo:RepositoryDefinition in _repositories)
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
			
			data[ "configuration" ] = _configuration;
			data[ "deployOptions" ] = _deployOptions;
			
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
		
		
		public function get applicationFilename():String { return _data[ "filename" ]; }
		
		
		public function set applicationFilename( value:String ):void { _data[ "filename" ] = value; }
		
		
		public function get version():String { return _data[ "version" ]; }
		
		
		public function set version( value:String ):void { _data[ "version" ] = value; }
		
		
		public function get versionLabel():String { return _data[ "versionLabel" ]; }
		
		
		public function set versionLabel( value:String ):void { _data[ "versionLabel" ] = value; }
		
		
		public function get repositories():Vector.<RepositoryDefinition> { return _repositories; }
		
		
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
		
		
		/**
		 * User configurable deployment options, specifying the location of files
		 * deployed by the apm tool, including ane directory, swc directory etc.
		 */
		public function get deployOptions():Object
		{
			return _deployOptions;
		}
		
		
		/**
		 * Removes all current dependencies in the project definition
		 *
		 * @return <code>ProjectDefinition</code> instance for chaining calls
		 */
		public function clearPackageDependencies():ProjectDefinition
		{
			_dependencies = new Vector.<PackageDependency>();
			return this;
		}
		
		
		/**
		 * Adds a package as a project dependency
		 *
		 * @param packageVersion
		 *
		 * @return <code>ProjectDefinition</code> instance for chaining calls
		 */
		public function addPackageDependency( packageVersion:PackageVersion ):ProjectDefinition
		{
			if (hasDependency( packageVersion.packageDef.identifier ))
			{
				removePackageDependency( packageVersion.packageDef.identifier );
			}
			
			var dep:PackageDependency = new PackageDependency();
			dep.identifier = packageVersion.packageDef.identifier;
			dep.version = SemVerRange.fromString( packageVersion.version.toString() );
			dep.source = packageVersion.source;
			
			dependencies.push( dep );

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
		 * Finds a package dependency matching the specified identifier
		 *
		 * @param identifier
		 *
		 * @return The <code>PackageDependency</code> or <code>null</code> if not found.
		 */
		public function getPackageDependency( identifier:String ):PackageDependency
		{
			for each (var dep:PackageDependency in _dependencies)
			{
				if (PackageIdentifier.isEquivalent( dep.identifier, identifier ))
					return dep;
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
		public function removePackageDependency( identifier:String ):ProjectDefinition
		{
			for (var i:int = _dependencies.length - 1; i >= 0; --i)
			{
				if (PackageIdentifier.isEquivalent( _dependencies[ i ].identifier, identifier ))
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
