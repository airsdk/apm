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
 * @created		31/5/21
 */
package com.apm.data
{
	import com.apm.SemVer;
	
	
	public class ProjectDependency
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "ProjectDependency";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		public var identifier:String;
		public var version:SemVer;
		
		private var _singleLineOutput:Boolean = false;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function ProjectDependency()
		{
		}
		
		
		public function toString():String
		{
			return identifier + "@" + version.toString()
		}
		
		
		public function toObject():Object
		{
			if (_singleLineOutput)
			{
				return identifier + ":" + version.toString();
			}
			else
			{
				return {
					id:      identifier,
					version: version.toString()
				};
			}
		}
		
		
		public static function fromObject( data:Object ):ProjectDependency
		{
			var dep:ProjectDependency = new ProjectDependency();
			if (data != null)
			{
				if (data instanceof String)
				{
					// single line format com.package.example:1.0.0
					dep._singleLineOutput = true;
					dep.identifier = data.substring( 0, String( data ).indexOf( ":" ) );
					dep.version = SemVer.fromString( String( data ).substring( data.indexOf( ":" ) + 1 ) );
				}
				else
				{
					if (data.hasOwnProperty( "id" )) dep.identifier = data[ "id" ];
					if (data.hasOwnProperty( "version" )) dep.version = SemVer.fromString( data[ "version" ] );
				}
			}
			return dep;
		}
		
	}
	
}
