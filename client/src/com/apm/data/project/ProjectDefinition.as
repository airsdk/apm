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
	import com.apm.data.packages.PackageParameter;
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
		private var _configuration:Vector.<ProjectParameter>;
		private var _buildTypes:Vector.<ProjectBuildType>;
		private var _deployOptions:Object;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function ProjectDefinition()
		{
			_data = {};
			
			_repositories = new <RepositoryDefinition>[];
			_dependencies = new <PackageDependency>[];
			_configuration = new <ProjectParameter>[];
			_buildTypes = new <ProjectBuildType>[];
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
				_configuration = new Vector.<ProjectParameter>();
				for (var key:String in _data.configuration)
				{
					_configuration.push(
							ProjectParameter.fromObject( key, _data.configuration[ key ] )
					);
				}
				_configuration.sort( Array.CASEINSENSITIVE );
			}
			
			if (_data.hasOwnProperty( "buildTypes" ))
			{
				_buildTypes = new <ProjectBuildType>[];
				for (var buildType:String in _data.buildTypes)
				{
					var variant:ProjectBuildType = new ProjectBuildType( buildType )
							.fromObject( _data.buildTypes[ buildType ] );
					
					_buildTypes.push( variant );
				}
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
			var keyOrder:Array = ["identifier", "name", "filename", "version", "versionLabel", "dependencies", "configuration", "buildTypes", "repositories"];
			var otherKeys:Array = JSONUtils.getMissingKeys( data, keyOrder );
			otherKeys.sort();
			
			return JSON.stringify( data, keyOrder.concat( otherKeys ), 4 ) + "\n";
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
			
			var configObject:Object = {};
			for each (var param:ProjectParameter in _configuration)
			{
				configObject[ param.name ] = param.toObject();
			}
			data[ "configuration" ] = configObject;
			
			if (_buildTypes.length > 0)
			{
				var buildTypesObject:Object = {};
				for each (var variant:ProjectBuildType in _buildTypes)
				{
					buildTypesObject[ variant.name ] = variant.toObject();
				}
				data[ "buildTypes" ] = buildTypesObject;
			}
			
			data[ "deployOptions" ] = _deployOptions;
			
			_data = data;
			
			return data;
		}
		
		
		//
		//	OPTIONS
		//
		
		public function get applicationId():String { return _data[ "identifier" ]; }
		
		
		public function set applicationId( value:String ):void { _data[ "identifier" ] = value; }
		
		
		public function get applicationName():Object { return _data[ "name" ]; }
		
		
		public function set applicationName( value:Object ):void { _data[ "name" ] = value; }
		
		
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
			{
				_dependencies = new Vector.<PackageDependency>();
			}
			return _dependencies;
		}
		
		
		//
		//	CONFIGURATION PARAMETERS
		//

//		public function get configuration():Vector.<ProjectParameter> { return _configuration; }
		
		/**
		 * Retrieves the configuration parameters for the specified build type
		 *
		 * @param buildType The name of the build type to apply. If null or not found, the default configuration will be used.
		 *
		 * @return
		 */
		public function getConfiguration( buildType:String ):Vector.<ProjectParameter>
		{
			if (buildType != null)
			{
				var projectBuildType:ProjectBuildType = getBuildType( buildType );
				if (projectBuildType != null)
				{
					var buildConfiguration:Vector.<ProjectParameter> = new Vector.<ProjectParameter>();
					for each (var defaultParam:ProjectParameter in _configuration)
					{
						var buildParam:ProjectParameter = projectBuildType.getConfigurationParam( defaultParam.name );
						if (buildParam != null)
						{
							buildConfiguration.push( buildParam );
						}
						else
						{
							buildConfiguration.push( defaultParam );
						}
					}
					return buildConfiguration;
				}
			}
			return _configuration;
		}
		
		
		/**
		 * Retrieves the specified configuration parameter value
		 *
		 * @param paramName	The name of the parameter
		 * @param buildType The build type of interest (default returned if not found in configuration)
		 *
		 * @return	The value for the parameter or null if the parameter name could not be found
		 */
		public function getConfigurationParamValue( paramName:String, buildType:String ):String
		{
			var param:ProjectParameter = getConfigurationParam( paramName, buildType );
			if (param != null)
			{
				return param.value;
			}
			return null;
		}
		
		
		/**
		 * Retrieves the specified configuration parameter
		 *
		 * @param paramName	The name of the parameter
		 * @param buildType The build type of interest (default returned if not found in configuration)
		 *
		 * @return	The parameter instance or null if the parameter name could not be found
		 */
		public function getConfigurationParam( paramName:String, buildType:String ):ProjectParameter
		{
			if (_configuration != null)
			{
				for each (var param:ProjectParameter in getConfiguration( buildType ))
				{
					if (param.name == paramName) return param;
				}
			}
			return null;
		}
		
		
		/**
		 * Sets a value for the configuration parameter
		 *
		 * @param key		The name of the parameter
		 * @param value		The value for the parameter
		 * @param buildType The build type of interest (default returned if not found in configuration)
		 */
		public function setConfigurationParamValue( key:String, value:String, buildType:String ):void
		{
			if (buildType != null && buildType != "null" && buildType.length > 0)
			{
				var projectBuildType:ProjectBuildType = getBuildType( buildType );
				if (projectBuildType == null)
				{
					projectBuildType = new ProjectBuildType( buildType );
					projectBuildType.setConfigurationParamValue( key, value );
					_buildTypes.push( projectBuildType );
				}
				else
				{
					projectBuildType.setConfigurationParamValue( key, value );
				}
			}
			else
			{
				if (_configuration == null) _configuration = new <ProjectParameter>[];
				var param:ProjectParameter = getConfigurationParam( key, null );
				if (param == null)
				{
					param = new ProjectParameter();
					param.name = key;
					param.value = value;
					_configuration.push( param );
					_configuration.sort( Array.CASEINSENSITIVE );
				}
				else
				{
					param.value = value;
				}
			}
		}
		
		
		/**
		 * Adds the package parameter to the default project configuration
		 *
		 * @param packageParam
		 */
		public function addPackageParameter( packageParam:PackageParameter ):void
		{
			var param:ProjectParameter = getConfigurationParam( packageParam.name, null );
			if (param == null)
			{
				// New parameter
				param = new ProjectParameter();
				param.name = packageParam.name;
				param.required = packageParam.required;
				param.value = packageParam.defaultValue;
				
				_configuration.push( param );
				_configuration.sort( Array.CASEINSENSITIVE );
			}
			else
			{
				// Update existing parameter
				param.required = param.required || packageParam.required;
				if (!param.isValid())
				{
					param.value = packageParam.defaultValue;
				}
			}
			
		}
		
		
		//
		//	BUILD TYPES
		//
		
		public function getBuildType( name:String ):ProjectBuildType
		{
			for each (var buildType:ProjectBuildType in _buildTypes)
			{
				if (buildType.name == name)
				{
					return buildType;
				}
			}
			return null;
		}
		
		
		//
		//	DEPLOYMENT OPTIONS
		//
		
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
		 * Adds a package version as a project dependency
		 *
		 * @param packageVersion
		 *
		 * @return <code>ProjectDefinition</code> instance for chaining calls
		 */
		public function addPackageVersionDependency( packageVersion:PackageVersion ):ProjectDefinition
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
		 * Adds a package dependency as a project dependency
		 *
		 * @param dependency
		 *
		 * @return <code>ProjectDefinition</code> instance for chaining calls
		 */
		public function addPackageDependency( dependency:PackageDependency ):ProjectDefinition
		{
			if (hasDependency( dependency.identifier ))
			{
				removePackageDependency( dependency.identifier );
			}
			
			dependencies.push( dependency );
			
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
				{
					return dep;
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
