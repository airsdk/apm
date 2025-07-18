/**
 * @author 		Michael Archbold (https://michaelarchbold.com)
 * @created		24/11/2021
 */
package com.apm.data.project
{

	public class ProjectBuildType implements ProjectApplicationProperties
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//

		private static const TAG:String = "ProjectBuildVariant";


		////////////////////////////////////////////////////////
		//  VARIABLES
		//

		/**
		 * The name of this build type eg debug
		 */
		public var name:String;


		private var _applicationId:String = null;
		public function get applicationId():String { return _applicationId; }

		public function set applicationId( value:String ):void { _applicationId = value; }

		private var _applicationName:Object = null;
		public function get applicationName():Object { return _applicationName; }

		public function set applicationName( value:Object ):void { _applicationName = value; }

		private var _applicationFilename:String = null;
		public function get applicationFilename():String { return _applicationFilename; }

		public function set applicationFilename( value:String ):void { _applicationFilename = value; }

		private var _version:String = null;
		public function get version():String { return _version; }

		public function set version( value:String ):void { _version = value; }

		private var _versionLabel:String = null;
		public function get versionLabel():String { return _versionLabel; }

		public function set versionLabel( value:String ):void { _versionLabel = value; }

		private var _configuration:Vector.<ProjectParameter>;


		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//

		public function ProjectBuildType( name:String )
		{
			this.name = name;
			_configuration = new <ProjectParameter>[];
		}


		public function fromObject( data:Object ):ProjectBuildType
		{
			if (data != null)
			{
				if (data.hasOwnProperty( "identifier" ))
				{
					applicationId = data.identifier;
				}
				if (data.hasOwnProperty( "name" ))
				{
					applicationName = data.name;
				}
				if (data.hasOwnProperty( "filename" ))
				{
					applicationFilename = data.filename;
				}
				if (data.hasOwnProperty( "version" ))
				{
					version = data.version;
				}
				if (data.hasOwnProperty( "versionLabel" ))
				{
					versionLabel = data.versionLabel;
				}

				if (data.hasOwnProperty( "configuration" ))
				{
					_configuration = new Vector.<ProjectParameter>();
					for (var key:String in data.configuration)
					{
						_configuration.push(
								ProjectParameter.fromObject( key, data.configuration[key] )
						);
					}
					_configuration.sort( Array.CASEINSENSITIVE );
				}
			}
			return this;
		}


		public function toObject():Object
		{
			var data:Object = {};

			if (applicationId != null)
			{
				data["identifier"] = applicationId;
			}
			if (applicationName != null)
			{
				data["name"] = applicationName;
			}
			if (applicationFilename != null)
			{
				data["filename"] = applicationFilename;
			}
			if (version != null)
			{
				data["version"] = version;
			}
			if (versionLabel != null)
			{
				data["versionLabel"] = versionLabel;
			}

			var configObject:Object = {};
			for each (var param:ProjectParameter in _configuration)
			{
				configObject[param.name] = param.toObject( true );
			}
			data["configuration"] = configObject;

			return data;
		}


		/**
		 * Retrieves the specified configuration parameter
		 *
		 * @param paramName	The name of the parameter
		 *
		 * @return	The parameter instance or null if the parameter name could not be found
		 */
		public function getConfigurationParam( paramName:String ):ProjectParameter
		{
			if (_configuration != null)
			{
				for each (var param:ProjectParameter in _configuration)
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
		 */
		public function setConfigurationParamValue( key:String, value:String ):void
		{
			if (key == "applicationId")
			{
				applicationId = value;
				return;
			}
			if (key == "version")
			{
				version = value;
				return;
			}
			if (key == "versionLabel")
			{
				versionLabel = value;
				return;
			}

			if (_configuration == null) _configuration = new <ProjectParameter>[];
			var param:ProjectParameter = getConfigurationParam( key );
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

}
