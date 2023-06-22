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
 * @created		9/6/2021
 */
package com.apm.data.packages
{
	public class PackageDefinition
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "PackageDefinition";
		
		public static const TYPE_ANE:String = "ane";
		public static const TYPE_SWC:String = "swc";
		public static const TYPE_SRC:String = "src";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		public var identifier:String = "";
		public var name:String = "";
		public var description:String = "";
		public var url:String = "";
		public var docUrl:String = "";
		public var type:String = TYPE_ANE;
		public var publishedAt:String = "";
		
		public var versions:Vector.<PackageVersion>;
		public var tags:Vector.<String>;
		
		public var purchaseUrl:String = "";
		public var license:PackageLicense;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function PackageDefinition()
		{
			versions = new Vector.<PackageVersion>();
			tags = new Vector.<String>();
		}
		
		
		public function equals( p:PackageDefinition ):Boolean
		{
			return PackageIdentifier.isEquivalent( identifier, p.identifier ) && type == p.type;
		}
		
		
		public function toString():String
		{
			return (identifier == null ? "none" : identifier) + "@" + (versions.length > 0 ? versions[ 0 ].toString() : "x.x.x");
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
						{
							version.packageDef = this;
						}
						versions.push( version );
					}
				}
				if (data.hasOwnProperty( "tags" ))
				{
					for each (var tag:Object in data.tags)
					{
						if (tag is String)
						{
							tags.push( tag );
						}
						else if (tag.hasOwnProperty("name"))
						{
							tags.push( tag.name );
						}
					}
				}
				
				if (data.hasOwnProperty( "purchaseUrl" )) this.purchaseUrl = data[ "purchaseUrl" ];
				if (data.hasOwnProperty( "license" )) this.license = new PackageLicense().fromObject( data[ "license" ] );
				
			}
			return this;
		}
		
		
		public function toObject( forceObjectOutput:Boolean = false, addVersions:Boolean = true ):Object
		{
			var data:Object = {};
			data.identifier = identifier;
			data.name = name;
			data.description = description;
			data.url = url;
			data.docUrl = docUrl;
			data.type = type;
			data.publishedAt = publishedAt;
			
			if (addVersions)
			{
				var versionObjects:Array = [];
				for each (var v:PackageVersion in versions)
				{
					versionObjects.push( v.toObject( forceObjectOutput ) );
				}
				data.versions = versionObjects;
			}
			
			if (tags.length > 0)
			{
				data.tags = [];
				for each (var tag:String in tags)
				{
					data.tags.push( tag );
				}
			}
			
			if (license)
			{
				data.license = license.toObject();
			}
			data.purchaseUrl = purchaseUrl;
			
			return data;
		}
		
		
	}
	
}
