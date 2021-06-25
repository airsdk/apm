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
package com.apm.data.packages
{
	import com.apm.SemVer;
	
	
	/**
	 * Represents a simple dependency reference either in a package definition file
	 * or the project definition file.
	 * <br/>
	 *
	 * Note: Dependencies from the repository server do not use this format,
	 * they supply PackageVersion with populated PackageDefinition for a more complete specification
	 *
	 */
	public class PackageDependency
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "PackageDependency";
		
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		public var identifier:String;
		public var version:SemVer;
		
		private var _singleLineOutput:Boolean = false;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function PackageDependency()
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
		
		
		public function fromObject( data:Object ):PackageDependency
		{
			if (data != null)
			{
				if (data is String)
				{
					// single line format com.package.example:1.0.0
					this._singleLineOutput = true;
					this.identifier = data.substring( 0, String( data ).indexOf( ":" ) );
					this.version = SemVer.fromString( String( data ).substring( data.indexOf( ":" ) + 1 ) );
				}
				else
				{
					if (data.hasOwnProperty( "id" )) this.identifier = data[ "id" ];
					if (data.hasOwnProperty( "version" )) this.version = SemVer.fromString( data[ "version" ] );
				}
			}
			return this;
		}
		
	}
	
}
