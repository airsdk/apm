/**
 * @author 		Michael Archbold (https://michaelarchbold.com)
 * @created		15/6/2021
 */
package com.apm.client.commands.packages.processes
{
	import com.apm.client.APM;
	import com.apm.client.analytics.Analytics;
	import com.apm.client.logging.Log;
	import com.apm.client.processes.ProcessBase;
	import com.apm.client.processes.ProcessQueue;
	import com.apm.client.processes.generic.ExtractZipProcess;
	import com.apm.data.install.InstallPackageData;
	import com.apm.data.user.PackageCache;
	import com.apm.utils.PackageFileUtils;

	import flash.filesystem.File;

	/**
	 * This process downloads and extracts an AIR package
	 */
	public class InstallPackageProcess extends ProcessBase
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//

		private static const TAG:String = "InstallPackageProcess";


		////////////////////////////////////////////////////////
		//  VARIABLES
		//

		private var _packageData:InstallPackageData;


		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//

		public function InstallPackageProcess( installPackageData:InstallPackageData )
		{
			super();
			_packageData = installPackageData;
		}


		override public function start( completeCallback:Function = null, failureCallback:Function = null ):void
		{
			super.start( completeCallback, failureCallback );
			APM.io.writeLine( "Installing package : " + _packageData.packageVersion.toStringWithIdentifier() );

			var contentsDirForPackage:File = PackageFileUtils.contentsDirForPackage( APM.config.packagesDirectory, _packageData.packageVersion.packageDef.identifier );

			var queue:ProcessQueue = new ProcessQueue();

			if (_packageData.request.source == "file")
			{
				var packageDir:File = PackageFileUtils.directoryForPackage( APM.config.packagesDirectory, _packageData.packageVersion.packageDef.identifier );
				var packageFile:File = PackageFileUtils.fileForPackage( APM.config.packagesDirectory, _packageData.packageVersion );
				if (_packageData.request.packageFile != null && _packageData.request.packageFile.exists)
				{
					queue.addCallback(
							function ():void
							{
								try
								{
									var packagesDir:File = new File( APM.config.packagesDirectory );
									if (!packagesDir.exists) packagesDir.createDirectory();
									if (!packageDir.exists) packageDir.createDirectory();

									if (_packageData.request.packageFile.nativePath != packageFile.nativePath)
									{
										_packageData.request.packageFile.copyTo( packageFile, true );
									}
									APM.io.writeResult( true, "Copying package : " + _packageData.request.packageFile.name );
								}
								catch (e:Error)
								{
									Log.e( TAG, e );
									APM.io.writeResult( false, "Failed to copy package : " + _packageData.request.packageFile.name + " :: " + e.message );
								}
							} );
				}
				queue.addProcess( new ExtractZipProcess( packageFile, contentsDirForPackage ) );
			}
			else
			{
				queue.addProcess( new DownloadPackageProcess( _packageData.packageVersion ) );

				var cachePackageFile:File = new PackageCache( APM.config.airSdkCacheDirectory )
						.getPackageFile( _packageData.packageVersion );
				queue.addProcess( new ExtractZipProcess( cachePackageFile, contentsDirForPackage ) );
			}

			queue.start(
					function ():void
					{
						if (_packageData.request.isNew)
						{
							Analytics.instance.install(
									_packageData.packageVersion.packageDef.identifier,
									_packageData.packageVersion.version.toString(),
									_packageData.packageVersion.source,
									complete );
						}
						else
						{
							complete();
						}
					},
					function ( error:String ):void
					{
						APM.io.writeError( "ERROR", "Failed to install package : " + _packageData.packageVersion.toStringWithIdentifier() );
						failure( error );
					} );

		}


		override protected function complete( data:Object = null ):void
		{
			APM.io.writeLine( "Installed package : " + _packageData.packageVersion.toStringWithIdentifier() );
			super.complete();
		}


	}

}
