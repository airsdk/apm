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
	import com.apm.SemVer;
	import com.apm.SemVerRange;
	import com.apm.data.common.Platform;

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

		public var sourceUrl:String   = "";
		public var checksum:String    = "";
		public var version:SemVer     = null;
		public var publishedAt:String = "";
		public var status:String      = "release";

		public var parameters:Vector.<PackageParameter>    = new Vector.<PackageParameter>();
		public var dependencies:Vector.<PackageDependency> = new Vector.<PackageDependency>();
		public var platforms:Vector.<Platform> = new Vector.<Platform>();

		public var source:String = null;


		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//

		public function PackageVersion()
		{
		}


		public function equals( p:PackageVersion ):Boolean
		{
			if (version == null && p.version == null)
			{
				return packageDef.equals( p.packageDef );
			}
			return version.equals( p.version ) && packageDef.equals( p.packageDef );
		}


		public function toString():String
		{
			return (version == null ? "" : version.toString());
		}


		public function toStringWithIdentifier():String
		{
			return (packageDef ? (packageDef.identifier == null ? "none" : packageDef.identifier) + "@" : "") + toString();
		}


		public function toDescriptiveString():String
		{
			return version.toString()
					+ " : " + publishedAt
					+ (isReleaseVersion() ? "" : " [" + status + "]")
					+ (platforms.length == 0 ? "" : " [" + platforms.join(",") + "]")
			;
		}


		public function isReleaseVersion():Boolean
		{
			return (status == "release" || status == "" || status == null);
		}


		public function fromObject( data:Object ):PackageVersion
		{
			if (data != null)
			{
				if (data.hasOwnProperty( "version" )) this.version = SemVerRange.fromString( data["version"] );
				if (data.hasOwnProperty( "source" )) this.source = data["source"];
				if (data.hasOwnProperty( "sourceUrl" )) this.sourceUrl = data["sourceUrl"];
				if (data.hasOwnProperty( "checksum" )) this.checksum = data["checksum"];
				if (data.hasOwnProperty( "publishedAt" )) this.publishedAt = data["publishedAt"];
				if (data.hasOwnProperty( "status" )) this.status = data["status"];
				if (data.hasOwnProperty( "dependencies" ))
				{
					for each (var depObject:Object in data.dependencies)
					{
						dependencies.push( new PackageDependency().fromObject( depObject ) );
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
					this.packageDef = new PackageDefinition().fromObject( data["package"] );
				}
				if (data.hasOwnProperty( "platforms" ))
				{
					for each (var platformObject:Object in data.platforms)
					{
						var p:Platform = Platform.fromObject( platformObject );
						if (p != null)
							platforms.push( p );
					}
				}
			}
			return this;
		}


		public function toObject( forceObjectOutput:Boolean = false, addPackageDefinition:Boolean = false ):Object
		{
			var data:Object = {};
			data.version    = version.toString();
			if (source != null) data.source = source;
			data.sourceUrl   = sourceUrl;
			data.checksum    = checksum;
			data.publishedAt = publishedAt;
			data.status      = status;

			if (addPackageDefinition)
			{
				if (packageDef != null)
				{
					data["package"] = packageDef.toObject( forceObjectOutput, false );
				}
			}

			var dependenciesObject:Array = [];
			for each (var d:PackageDependency in dependencies)
			{
				dependenciesObject.push( d.toObject( forceObjectOutput ) );
			}
			data.dependencies = dependenciesObject;

			var parametersObject:Array = [];
			for each (var p:PackageParameter in parameters)
			{
				parametersObject.push( p.toObject( forceObjectOutput ) );
			}
			data.parameters = parametersObject;

			var platformsObject:Array = [];
			for each (var platform:Platform in platforms)
			{
				platformsObject.push( platformsObject.toObject( forceObjectOutput ) );
			}
			data.platforms = platformsObject;

			return data;
		}


	}

}
