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
	import com.apm.client.APMCore;
	import com.apm.client.commands.packages.data.InstallData;
	import com.apm.client.commands.packages.data.InstallPackageData;
	import com.apm.client.commands.packages.data.InstallPackageDataGroup;
	import com.apm.client.commands.packages.utils.InstallDataValidator;
	import com.apm.client.processes.ProcessBase;
	
	
	public class InstallDataValidationProcess extends ProcessBase
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "InstallValidationProcess";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _core:APMCore;
		private var _installData:InstallData;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function InstallDataValidationProcess( core:APMCore, installData:InstallData )
		{
			super();
			_core = core;
			_installData = installData;
		}
		
		
		override public function start( completeCallback:Function = null, failureCallback:Function = null ):void
		{
			super.start( completeCallback, failureCallback );
			// Once here we should have all the data for the required packages
			// We now verify the install, checking for conflicts and resolving if possible
			var resolver:InstallDataValidator = new InstallDataValidator();
			if (resolver.verifyInstall( _installData )) // fails if a conflicting package was found
			{
				// dependencies could be resolved - proceed to installation
				_queue.clear();
				for each (var packageToRemove:InstallPackageData in _installData.packagesToRemove)
				{
					var identifier:String = packageToRemove.packageVersion.packageDef.identifier;
					_queue.addProcess(
							new UninstallPackageProcess( _core, identifier, identifier, true )
					);
				}
				for each (var p:InstallPackageData in _installData.packagesToInstall)
				{
					_queue.addProcess(
							new InstallPackageProcess( _core, p )
					);
				}
				
				_queue.addProcess( new InstallDeployProcess( _core, _installData ) );
				_queue.addProcess( new InstallFinaliseProcess( _core, _installData ) );
				
				complete();
			}
			else
			{
				_core.io.writeError( "CONFLICT", "fatal error : found [" + _installData.packagesConflicting.length + "] conflicting packages" );
				for each (var confictGroup:InstallPackageDataGroup in _installData.packagesConflicting)
				{
					_core.io.writeError( "CONFLICT", confictGroup.packageIdentifier );
					for (var i:int = 0; i < confictGroup.versions.length; i++)
					{
						_core.io.writeError( "CONFLICT",
											 (i == confictGroup.versions.length - 1 ? "└── " : "├── ") +
													 confictGroup.versions[ i ].packageVersion.toString() +
													 " required by: " + confictGroup.versions[ i ].query.requiringPackage.packageDef.toString()
						);
					}
				}
				failure();
			}
		}
	}
}
