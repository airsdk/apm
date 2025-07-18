/**
 * @author 		Michael Archbold (https://michaelarchbold.com)
 * @created		22/10/2021
 */
package com.apm.data.project
{
	import com.apm.data.common.Platform;

	import org.as3commons.lang.IEquals;
	import org.as3commons.lang.VectorUtils;

	/**
	 *
	 */
	public class ProjectParameter
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//

		private static const TAG:String = "ProjectParameter";


		////////////////////////////////////////////////////////
		//  VARIABLES
		//

		public var name:String;
		public var required:Boolean = false;
		public var value:String = "";
		public var platforms:Vector.<Platform> = new Vector.<Platform>();


		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//

		public function ProjectParameter()
		{
		}


		public function toObject( singleLine:Boolean = false ):Object
		{
			if (singleLine)
			{
				return value;
			}
			else
			{
				var data:Object = {};
				data["name"] = name;
				data["required"] = required ? "true" : "false";
				data["value"] = value;
				if (platforms && platforms.length > 0)
				{
					data["platforms"] = [];
					for each (var platform:Platform in platforms)
					{
						data["platforms"].push( platform.toObject() );
					}
				}
				return data;
			}
		}


		public static function fromObject( key:String, data:Object ):ProjectParameter
		{
			var param:ProjectParameter = new ProjectParameter();
			param.name = key;

			if (data is String)
			{
				// Handle single line "name":"value" entries
				param.value = data as String;
			}
			else
			{
				if (data.hasOwnProperty( "name" )) param.name = data.name;
				if (data.hasOwnProperty( "value" )) param.value = data.value;
				if (data.hasOwnProperty( "required" )) param.required = data.required == "true";
				if (data.hasOwnProperty( "platforms" ))
				{
					for each (var platformObject:Object in data.platforms)
					{
						var p:Platform = Platform.fromObject( platformObject );
						if (p != null) param.platforms.push( p );
					}
				}
			}

			return param;
		}

		public function toString():String
		{
			return name + "=" + value;
		}


		public function toDescriptiveString():String
		{
			var s:String = name + "\n" +
					"\t value=" + value + "\n";
			return s;
		}


		//
		//	VALIDATION
		//

		public function isValid( projectPlatforms:Vector.<Platform> ):Boolean
		{
			if (required)
			{
				if (
						platforms.length == 0 ||
						projectPlatforms.length == 0 ||
						(VectorUtils.intersection(
								Vector.<IEquals>( projectPlatforms ),
								Vector.<IEquals>( platforms ) ).length > 0)
				)
				{
					return isValueValid();
				}
			}
			return true;
		}


		private function isValueValid():Boolean
		{
			return value != null && value.length > 0;
		}


		public function getValidationIssue():String
		{
			// TODO
			return "";
		}


	}

}
