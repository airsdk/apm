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
	import com.apm.client.processes.ProcessBase;
	import com.apm.data.install.InstallData;
	import com.apm.data.install.InstallPackageData;
	import com.apm.utils.DeployFileUtils;
	import com.apm.utils.FileUtils;
	import com.apm.utils.PackageFileUtils;

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

		private var _installData:InstallData;


		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//

		public function InstallDeployProcess( installData:InstallData )
		{
			_installData = installData;
		}


		override public function start( completeCallback:Function = null, failureCallback:Function = null ):void
		{
			super.start( completeCallback, failureCallback );
			for each (var p:InstallPackageData in _installData.packagesToInstall)
			{
				var packageDir:File = PackageFileUtils.contentsDirForPackage( APM.config.packagesDirectory,
																			  p.packageVersion.packageDef.identifier );
				if (packageDir == null || !packageDir.exists)
				{
					return failure( "Contents directory for package does not exist" );
				}
				APM.io.showSpinner( "Deploying package: " + p.packageVersion.toStringWithIdentifier() );
				for each (var ref:File in packageDir.getDirectoryListing())
				{
					if (ref.isDirectory)
					{
						APM.io.updateSpinner( "Deploying package: " + p.packageVersion.toStringWithIdentifier() + " " + ref.name );
						var deployLocation:File = DeployFileUtils.getDeployLocation( APM.config, ref.name );
						if (deployLocation != null)
						{
							FileUtils.copyDirectoryTo( ref, deployLocation, true );
						}
					}
				}
				APM.io.stopSpinner( true, "Deployed: " + p.packageVersion.toStringWithIdentifier() );
			}
			complete();
		}


	}

}
