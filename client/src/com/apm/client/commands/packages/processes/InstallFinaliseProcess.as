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
 * @created		22/6/21
 */
package com.apm.client.commands.packages.processes
{
	import com.apm.client.APMCore;
	import com.apm.client.commands.packages.data.InstallData;
	import com.apm.client.commands.packages.data.InstallPackageData;
	import com.apm.client.processes.ProcessBase;
	import com.apm.data.packages.PackageParameter;
	
	
	public class InstallFinaliseProcess extends ProcessBase
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "InstallFinaliseProcess";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _core : APMCore;
		private var _installData : InstallData;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function InstallFinaliseProcess( core:APMCore, installData:InstallData )
		{
			_core = core;
			_installData = installData;
		}
		
		
		override public function start():void
		{
			_core.config.projectDefinition.clearPackageDependencies();
			
			// save all the installed packages into the project file
			for each (var p:InstallPackageData in _installData.packagesToInstall)
			{
				if (p.query.requiringPackage == null)
				{
					_core.config.projectDefinition.addPackageDependency( p.packageVersion );
				}

				// Ensure all extension parameters are added with defaults
				for each (var param:PackageParameter in p.packageVersion.parameters)
				{
					if (!_core.config.projectDefinition.configuration.hasOwnProperty( param.name ))
					{
						_core.config.projectDefinition.configuration[ param.name ] = param.defaultValue;
					}
				}
			}
			
			_core.config.projectDefinition.save();
			complete();
		}
		
	}
}
