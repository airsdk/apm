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
 * @created		9/6/21
 */
package com.apm.data.packages
{
	import com.apm.SemVer;
	
	
	public class PackageVersion
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "PackageDefinition";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		public var packageDef:PackageDefinition;
		public var publishedAt:String = "";
		public var sourceUrl:String = "";
		public var version:SemVer = null;
		public var dependencies:Vector.<PackageVersion> = new Vector.<PackageVersion>();
		public var parameters:Vector.<PackageParameter> = new Vector.<PackageParameter>();
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function PackageVersion()
		{
		}
		
		
		public function equals( p:PackageVersion ):Boolean
		{
			return version.equals( p.version );
		}
		
		
		public function toString():String
		{
			return version.toString();
		}
		
		
		public function toDescriptiveString():String
		{
			return version.toString() + " : " + publishedAt;
		}
		
		
		public function fromObject( data:Object ):PackageVersion
		{
			if (data != null)
			{
				if (data.hasOwnProperty( "version" )) this.version = SemVer.fromString( data[ "version" ] );
				if (data.hasOwnProperty( "sourceUrl" )) this.sourceUrl = data[ "sourceUrl" ];
				if (data.hasOwnProperty( "publishedAt" )) this.publishedAt = data[ "publishedAt" ];
				if (data.hasOwnProperty( "dependencies" ))
				{
					for each (var depObject:Object in data.dependencies)
					{
						dependencies.push( new PackageVersion().fromObject( depObject ) );
					}
				}
				if (data.hasOwnProperty( "parameters" ))
				{
					for each (var paramObject:Object in data.parameters)
					{
						parameters.push( new PackageParameter().fromObject( paramObject ) );
					}
				}
				if (data.hasOwnProperty( "package" ))
				{
					this.packageDef = new PackageDefinition().fromObject( data[ "package" ] );
				}
			}
			return this;
		}
		
	}
	
}
