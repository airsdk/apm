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
	
	
	public class Dependency
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "Dependency";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		public var id:String;
		public var version:SemVer;
		
		private var _singleLineOutput:Boolean = false;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function Dependency()
		{
		}
		
		
		public function toString():String
		{
			return id + "@" + version.toString()
		}
		
		
		public function toObject():Object
		{
			if (_singleLineOutput)
			{
				return id + ":" + version.toString();
			}
			else
			{
				return {
					id:      id,
					version: version.toString()
				};
			}
		}
		
		
		public static function fromObject( data:Object ):Dependency
		{
			var dep:Dependency = new Dependency();
			if (data != null)
			{
				if (data instanceof String)
				{
					// single line format com.package.example:1.0.0
					dep._singleLineOutput = true;
					dep.id = data.substring( 0, String( data ).indexOf( ":" ) );
					dep.version = SemVer.fromString( String( data ).substring( data.indexOf( ":" ) + 1 ) );
				}
				else
				{
					if (data.hasOwnProperty( "id" )) dep.id = data[ "id" ];
					if (data.hasOwnProperty( "version" )) dep.version = SemVer.fromString( data[ "version" ] );
				}
			}
			return dep;
		}
		
	}
	
}
