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
 * @brief
 * @author 		marchbold
 * @created		16/7/21
 * @copyright	http://distriqt.com/copyright/license.txt
 */
package com.apm.client.commands.packages.processes
{
	import com.apm.client.APM;
	import com.apm.client.commands.packages.utils.InstallDataValidator;
	import com.apm.client.processes.ProcessBase;
	import com.apm.data.install.InstallData;
	import com.apm.data.install.InstallPackageData;
	import com.apm.data.install.InstallPackageDataGroup;
	import com.apm.data.install.InstallRequest;
	import com.apm.data.packages.PackageVersion;

	public class InstallDataValidationProcess extends ProcessBase
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//

		private static const TAG:String = "InstallValidationProcess";


		////////////////////////////////////////////////////////
		//  VARIABLES
		//

		private var _installData:InstallData;


		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//

		public function InstallDataValidationProcess( installData:InstallData )
		{
			super();
			_installData = installData;
		}


		override public function start( completeCallback:Function = null, failureCallback:Function = null ):void
		{
			super.start( completeCallback, failureCallback );
			// Once here we should have all the data for the required packages
			// We now verify the install, checking for conflicts and resolving if possible
			var validator:InstallDataValidator = new InstallDataValidator();
			if (validator.verifyInstall( _installData )) // fails if a conflicting package was found
			{
				// dependencies could be resolved - proceed to installation
				_queue.clear();
				for each (var packageToRemove:InstallPackageData in _installData.packagesToRemove)
				{
					var identifier:String = packageToRemove.packageVersion.packageDef.identifier;
					_queue.addProcess(
							new UninstallPackageProcess( identifier,
														 identifier,
														 null,
														 packageToRemove.packageVersion.version,
														 false,
														 packageToRemove.packageVersion.version == null )
					);
				}
				for each (var p:InstallPackageData in _installData.packagesToInstall)
				{
					_queue.addProcess(
							new InstallPackageProcess( p )
					);
				}

				_queue.addProcess( new InstallDeployProcess( _installData ) );
				_queue.addProcess( new InstallFinaliseProcess( _installData ) );

				complete();
			}
			else
			{
				APM.io.writeError( "CONFLICT",
								   "fatal error : found [" + _installData.packagesConflicting.length + "] conflicting packages" );
				for each (var confictGroup:InstallPackageDataGroup in _installData.packagesConflicting)
				{
					APM.io.writeError( "CONFLICT", confictGroup.packageIdentifier );
					for (var i:int = 0; i < confictGroup.versions.length; i++)
					{
						var prefix:String = (i == confictGroup.versions.length - 1 ? "└── " : "├── ");

						var version:String = confictGroup.versions[i].packageVersion.toString();

						var request:InstallRequest = confictGroup.versions[i].request;
						var requiringPackage:PackageVersion = request == null ? null : request.requiringPackage;
						var requiredBy:String = (requiringPackage == null) ? "" : " required by: " + requiringPackage.toStringWithIdentifier();

						APM.io.writeError( "CONFLICT", prefix + version + requiredBy );
					}
				}
				failure();
			}
		}
	}
}
