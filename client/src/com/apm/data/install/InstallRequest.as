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
 * @created		18/6/2021
 */
package com.apm.data.install
{
	import com.apm.SemVerRange;
	import com.apm.data.packages.PackageVersion;
	
	import flash.filesystem.File;
	
	
	/**
	 * This represents the data for an installation request of a package.
	 *
	 */
	public class InstallRequest
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "InstallRequest";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		/**
		 * Requested package identifier
		 */
		public var packageIdentifier:String;
		
		
		/**
		 * Requested package version
		 * <br/>
		 * If this is null then it is assumed the request is for the most recent release.
		 */
		public var version:String;
		
		
		/**
		 *	The <code>version</code> string as a SemVerRange
		 */
		public function get semVer():SemVerRange
		{ return SemVerRange.fromString( version ); }
		
		
		/**
		 * Source name
		 * <br/>
		 *
		 * Potential values are:
		 * <ul>
		 * 	<li>file</li>
		 * 	<li>repository name</li>
		 * 	<li>default: <code>null</code> resolves to repository.airsdk.dev</li>
		 * </ul>
		 *
		 */
		public var source:String = null;
		
		
		/**
		 * If this is a local file request then this is a reference to the requested
		 * package file (.airpackage) to install.
		 * <br/>
		 * This will be null for any repository requests
		 */
		public var packageFile:File = null;
		
		
		/**
		 * The package that required this request , i.e. the package that has this package/version as a dependency
		 * <br/>
		 * If this is a top level request then this will be null
		 */
		public var requiringPackage:PackageVersion = null;
		
		
		/**
		 * Whether this was already in the project or is a new package addition.
		 * <br/>
		 * There should only ever be one new request being the one that was specified on the command line.
		 */
		public var isNew:Boolean;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function InstallRequest(
				packageIdentifier:String,
				version:String,
				source:String,
				requiringPackage:PackageVersion = null,
				isNew:Boolean                   = false,
				packageFile:File                = null
		)
		{
			this.packageIdentifier = packageIdentifier;
			this.version = version;
			this.source = source;
			this.requiringPackage = requiringPackage;
			this.isNew = isNew;
			this.packageFile = packageFile;
		}
		
		
		public function description():String
		{
			return packageIdentifier + "@" + (version == null ? "latest" : version) + (source == null ? "" : " source:" + source);
		}
		
		
		public function fromObject( data:Object ):InstallRequest
		{
			if (data != null)
			{
				if (data.hasOwnProperty( "packageIdentifier" )) this.packageIdentifier = data.packageIdentifier;
				if (data.hasOwnProperty( "version" )) this.version = data.version;
				if (data.hasOwnProperty( "source" )) this.source = data.source;
				if (data.hasOwnProperty( "requiringPackage" )) this.requiringPackage = new PackageVersion().fromObject( data.requiringPackage );
			}
			return this;
		}
		
		
		public function toObject():Object
		{
			var data:Object = {
				packageIdentifier: packageIdentifier,
				version:           version,
				source:            source
			};
			if (requiringPackage != null)
			{
				data.requiringPackage = requiringPackage.toObject( false, true );
			}
			return data;
		}
		
		
	}
	
}
