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
	import com.apm.client.APM;
	import com.apm.client.commands.packages.data.InstallData;
	import com.apm.client.commands.packages.data.InstallPackageData;
	import com.apm.client.processes.ProcessBase;
	import com.apm.data.packages.PackageParameter;
	import com.apm.data.packages.PackageVersion;
	
	
	/**
	 * This is the final process in the install command,
	 * it updates the project config file to represent the resolved
	 * installation state.
	 */
	public class InstallFinaliseProcess extends ProcessBase
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "InstallFinaliseProcess";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _installData:InstallData;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function InstallFinaliseProcess( installData:InstallData )
		{
			_installData = installData;
		}
		
		
		override public function start( completeCallback:Function = null, failureCallback:Function = null ):void
		{
			super.start( completeCallback, failureCallback );
//			APM.config.projectDefinition.clearPackageDependencies();
			
			// save all the installed packages into the project file
			for each (var p:InstallPackageData in _installData.packagesToInstall)
			{
				if (p.request.requiringPackage == null)
				{
					var packageVersion:PackageVersion = p.packageVersion;
					packageVersion.source = p.request.source;
					
					APM.config.projectDefinition.addPackageDependency( packageVersion );
				}
				
				// Ensure all extension parameters are added with defaults
				for each (var param:PackageParameter in p.packageVersion.parameters)
				{
					if (!APM.config.projectDefinition.configuration.hasOwnProperty( param.name ))
					{
						APM.config.projectDefinition.configuration[ param.name ] = param.defaultValue;
					}
				}
			}
			
			APM.config.projectDefinition.save();
			complete();
		}
		
	}
}
