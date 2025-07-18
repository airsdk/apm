/**
 * @author 		Michael Archbold (https://michaelarchbold.com)
 * @created		22/6/2021
 */
package com.apm.client.commands.packages.processes
{
	import com.apm.client.APM;
	import com.apm.client.processes.ProcessBase;
	import com.apm.data.common.Platform;
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
				if (!APM.config.projectDefinition.shouldIncludePackage( p.packageVersion ))
				{
					continue;
				}

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
							switch (ref.name)
							{
								case PackageFileUtils.AIRPACKAGE_ASSETS:
									// Check each asset directory (named after the platform) for inclusion in project
									for each (var assetsDir:File in ref.getDirectoryListing())
									{
										var assetsPlatform:String = Platform.getPlatformFromVariant( assetsDir.name );
										if (APM.config.projectDefinition.shouldIncludePlatform( assetsPlatform ))
										{
											var assetsDeployLocation:File = deployLocation.resolvePath( assetsDir.name );
											FileUtils.copyDirectoryTo( assetsDir, assetsDeployLocation, true );
										}
									}
									break;

								default:
									FileUtils.copyDirectoryTo( ref, deployLocation, true );
									break;
							}
						}

					}
				}
				APM.io.stopSpinner( true, "Deployed: " + p.packageVersion.toStringWithIdentifier() );
			}
			complete();
		}


	}

}
