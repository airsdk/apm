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
 * @created		18/6/21
 */
package com.apm.data.install
{
	import com.apm.data.packages.PackageVersion;

	public class InstallPackageData
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//

		private static const TAG:String = "InstallPackageData";


		////////////////////////////////////////////////////////
		//  VARIABLES
		//

		public var packageVersion:PackageVersion;
		public var request:InstallRequest;


		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//

		public function InstallPackageData(
				packageVersion:PackageVersion = null,
				request:InstallRequest        = null )
		{
			this.packageVersion = packageVersion;
			this.request        = request;
		}


		public function get packageIdentifier():String
		{
			if (packageVersion && packageVersion.packageDef)
				return packageVersion.packageDef.identifier;
			return "";
		}


		public function equals( b:InstallPackageData ):Boolean
		{
			if (packageVersion.equals( b.packageVersion ))
			{
				return true;
			}
			return false;
		}


		public function fromObject( data:Object ):InstallPackageData
		{
			if (data != null)
			{
				if (data.hasOwnProperty( "packageVersion" )) this.packageVersion = new PackageVersion().fromObject( data.packageVersion );
				if (data.hasOwnProperty( "request" )) this.request = new InstallRequest( null, null, null ).fromObject(
						data.request );
			}
			return this;
		}


		public function toObject():Object
		{
			return {
				packageVersion: packageVersion.toObject( false, true ),
				request       : request.toObject()
			}
		}


		public static const sortFunction:Function = function ( a:InstallPackageData, b:InstallPackageData ):Number
		{
			try
			{
				var packageAIdentifier:String = a.packageVersion.packageDef.identifier.toLowerCase();
				var packageBIdentifier:String = b.packageVersion.packageDef.identifier.toLowerCase();

				if (packageAIdentifier < packageBIdentifier)
					return -1;
				else if (packageAIdentifier > packageBIdentifier)
					return 1;
			}
			catch (e:Error)
			{
				trace( e );
			}
			return 0;
		};


	}

}
