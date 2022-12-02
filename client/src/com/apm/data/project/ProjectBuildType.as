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
 * @brief
 * @author 		marchbold
 * @created		24/11/21
 * @copyright	http://distriqt.com/copyright/license.txt
 */
package com.apm.data.project
{
	
	public class ProjectBuildType
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


		public var applicationId:String = null;

		
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
				if (data.hasOwnProperty("identifier"))
				{
					applicationId = data.identifier;
				}

				if (data.hasOwnProperty( "configuration" ))
				{
					_configuration = new Vector.<ProjectParameter>();
					for (var key:String in data.configuration)
					{
						_configuration.push(
								ProjectParameter.fromObject( key, data.configuration[ key ] )
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

			var configObject:Object = {};
			for each (var param:ProjectParameter in _configuration)
			{
				configObject[ param.name ] = param.toObject( true );
			}
			data[ "configuration" ] = configObject;

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
