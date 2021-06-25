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
	import flash.filesystem.File;
	
	
	public class PackageDefinition
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "PackageDefinition";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		public var identifier:String = "";
		public var name:String = "";
		public var description:String = "";
		public var url:String = "";
		public var docUrl:String = "";
		public var type:String = "ane";
		public var publishedAt:String = "";
		
		public var versions:Vector.<PackageVersion>;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function PackageDefinition()
		{
			versions = new Vector.<PackageVersion>();
		}
		
		
		public function equals( p:PackageDefinition ):Boolean
		{
			if (identifier == p.identifier && type == p.type)
				return true;
			return false;
		}
		
		
		public function toString():String
		{
			return identifier +
					"@" + (versions.length > 0 ? versions[ 0 ].toString() : "x.x.x");
		}
		
		
		public function toDescriptiveString():String
		{
			return identifier +
					"@" + (versions.length > 0 ? versions[ 0 ].toString() : "x.x.x") +
					"   " + description;
		}
		
		
		public function fromObject( data:Object ):PackageDefinition
		{
			if (data != null)
			{
				if (data.hasOwnProperty( "identifier" )) this.identifier = data[ "identifier" ];
				if (data.hasOwnProperty( "name" )) this.name = data[ "name" ];
				if (data.hasOwnProperty( "description" )) this.description = data[ "description" ];
				if (data.hasOwnProperty( "url" )) this.url = data[ "url" ];
				if (data.hasOwnProperty( "docUrl" )) this.docUrl = data[ "docUrl" ];
				if (data.hasOwnProperty( "type" )) this.type = data[ "type" ];
				if (data.hasOwnProperty( "publishedAt" )) this.publishedAt = data[ "publishedAt" ];
				if (data.hasOwnProperty( "versions" ))
				{
					for each (var versionObject:Object in data.versions)
					{
						var version:PackageVersion = new PackageVersion().fromObject( versionObject );
						if (version.packageDef == null)
							version.packageDef = this;
						versions.push( version );
					}
				}
			}
			return this;
		}
		
		
		
		
		
	}
	
}
