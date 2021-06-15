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
 * @created		15/6/21
 */
package com.apm.data.packages
{
	public class PackageParameter
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "PackageParameter";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		public var name:String;
		public var required:Boolean = false;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function PackageParameter()
		{
		}
		
		
		public function toString():String
		{
			return name;
		}
		
		
		public function toObject():Object
		{
			return {
				name:     name,
				required: required
			};
		}
		
		
		public function fromObject( data:Object ):PackageParameter
		{
			if (data != null)
			{
				if (data.hasOwnProperty( "name" )) this.name = data[ "name" ];
				if (data.hasOwnProperty( "required" )) this.required = data[ "required" ];
			}
			return this;
		}
		
	}
	
}
