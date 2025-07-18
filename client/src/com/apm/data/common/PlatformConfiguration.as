/**
 * @author Michael Archbold (https://michaelarchbold.com)
 * @created 3/7/2025
 */
package com.apm.data.common
{
	import com.apm.SemVer;

	public class PlatformConfiguration
	{
		////////////////////////////////////////////////////////
		//	CONSTANTS
		//

		private static const TAG:String = "PlatformConfiguration";


		////////////////////////////////////////////////////////
		//	VARIABLES
		//

		public var platform:Platform;


		public var parameters:Vector.<PlatformParameter> = new Vector.<PlatformParameter>();


		////////////////////////////////////////////////////////
		//	FUNCTIONALITY
		//

		public function PlatformConfiguration()
		{
		}


		public function updateParameter( parameter:PlatformParameter ):void
		{
			if (parameter == null) return;
			var existingParameter:PlatformParameter = getParameter( parameter.name );
			if (existingParameter == null)
			{
				parameters.push( parameter );
				return;
			}

			switch (parameter.valueType())
			{
				case PlatformParameter.TYPE_BOOLEAN:
					// If either are true, set to true
					existingParameter.value = (parameter.asBoolean() || existingParameter.asBoolean()) ? "true" : "false";
					break;

				case PlatformParameter.TYPE_VERSION:
					// Use the higher version
					var existingVersion:SemVer = existingParameter.asVersion();
					var newVersion:SemVer = parameter.asVersion();
					if (existingVersion.lessThanOrEqual( newVersion ))
					{
						existingParameter.value = parameter.value;
					}
					break;

				case PlatformParameter.TYPE_STRING_ARRAY:
					// Merge the string arrays, avoiding duplicates
					var stringArray:Array = existingParameter.asStringArray();
					var newItems:Array = parameter.asStringArray();
					for each (var item:String in newItems)
					{
						if (stringArray.indexOf( item ) == -1)
						{
							stringArray.push( item );
						}
					}
					break;

				case PlatformParameter.TYPE_NUMBER:
					// Use the higher number
					var existingNumber:Number = existingParameter.asNumber();
					var newNumber:Number = parameter.asNumber();
					existingParameter.value = Math.max( existingNumber, newNumber ).toString();
					break;

				default:
					// Do nothing, just keep the existing value
			}

		}


		public function setParameter( parameter:PlatformParameter ):void
		{
			var existingParameter:PlatformParameter = getParameter( parameter.name );
			if (existingParameter == null)
			{
				parameters.push( parameter );
			}
			else
			{
				existingParameter.value = parameter.value;
			}
		}


		public function getParameter( name:String ):PlatformParameter
		{
			for each (var parameter:PlatformParameter in parameters)
			{
				if (parameter.name == name)
				{
					return parameter;
				}
			}
			return null;
		}


		public function removeParameter( name:String ):void
		{
			for (var i:int = 0; i < parameters.length; i++)
			{
				if (parameters[i].name == name)
				{
					parameters.splice( i, 1 );
					return;
				}
			}
		}


		public static function fromObject( platform:String, data:Object ):PlatformConfiguration
		{
			if (data == null) return null;

			var platformParameters:PlatformConfiguration = new PlatformConfiguration();
			platformParameters.platform = Platform.fromObject( platform );
			for (var key:String in data)
			{
				platformParameters.parameters.push(
						new PlatformParameter( key, data[key] )
				);
			}
			return platformParameters;
		}


		public function toObject():Object
		{
			var data:Object = {};
			for each (var parameter:PlatformParameter in parameters)
			{
				data[parameter.name] = parameter.value;
			}
			return data;
		}


	}

}
