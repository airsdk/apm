/**
 * @author 		Michael Archbold (https://michaelarchbold.com)
 * @created		22/10/2021
 */
package com.apm.data.project
{
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
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function ProjectParameter()
		{
		}
		
		
		public function toObject( singleLine:Boolean=false ):Object
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
				if (data.hasOwnProperty("name")) param.name = data.name;
				if (data.hasOwnProperty("value")) param.value = data.value;
				if (data.hasOwnProperty("required")) param.required = data.required == "true";
			}
			
			return param;
		}
		
		public function toString():String
		{
			return name + "=" + value;
		}
		
		public function toDescriptiveString():String
		{
			var s:String =  name + "\n" +
							"\t value=" + value + "\n";
			return s;
		}
		
		
		
		
		
		//
		//	VALIDATION
		//
		
		public function isValid():Boolean
		{
			if (required)
			{
				return value != null && value.length > 0;
			}
			return true;
		}
		
		
		public function getValidationIssue():String
		{
			// TODO
			return "";
		}
		
		
	}
	
}
