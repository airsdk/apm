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
	import com.apm.utils.DeployFileUtils;
	import com.apm.utils.FileUtils;
	import com.apm.utils.PackageFileUtils;
	import com.apm.client.logging.Log;
	import com.apm.client.processes.ProcessBase;
	import com.apm.data.packages.PackageParameter;
	
	import flash.filesystem.File;
	
	
	/**
	 * This is the deploy process in the install command,
	 * it copies the files into the appropriate place for the application.
	 */
	public class InstallDeployProcess extends ProcessBase
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "InstallDeployProcess";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _core:APMCore;
		private var _installData:InstallData;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function InstallDeployProcess( core:APMCore, installData:InstallData )
		{
			_core = core;
			_installData = installData;
		}
		
		
		override public function start( completeCallback:Function = null, failureCallback:Function = null ):void
		{
			super.start( completeCallback, failureCallback );
			for each (var p:InstallPackageData in _installData.packagesToInstall)
			{
				_core.io.showSpinner( "Deploying package: " + p.packageVersion.packageDef.toString() );
				var packageDir:File = PackageFileUtils.cacheDirForPackage( _core, p.packageVersion.packageDef.identifier );
				for each (var ref:File in packageDir.getDirectoryListing())
				{
					if (ref.isDirectory)
					{
						_core.io.updateSpinner( "Deploying package: " + p.packageVersion.packageDef.toString() + " " + ref.name );
						var deployLocation:File = DeployFileUtils.getDeployLocation( _core.config, ref.name );
						FileUtils.copyDirectoryTo( ref, deployLocation, true );
					}
				}
				_core.io.stopSpinner( true, "Deployed: " + p.packageVersion.packageDef.toString() );
			}
			complete();
		}
		
		
	}
	
}
