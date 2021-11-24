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
 * @created		22/10/21
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
		
		
		public function toObject():Object
		{
			var data:Object = {};
			data["name"] = name;
			data["required"] = required ? "true" : "false";
			data["value"] = value;
			return data;
		}
		
		
		public static function fromObject( key:String, data:Object ):ProjectParameter
		{
			var param:ProjectParameter = new ProjectParameter();
			param.name = key;
			
			if (data is String)
			{
				// Handle legacy "name":"value" entries
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
