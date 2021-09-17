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
 * @created		15/6/21
 */
package com.apm.client.commands.packages.processes
{
	import com.apm.client.APM;
	import com.apm.client.analytics.Analytics;
	import com.apm.client.commands.packages.data.InstallPackageData;
	import com.apm.client.logging.Log;
	import com.apm.utils.PackageFileUtils;
	import com.apm.client.processes.ProcessBase;
	import com.apm.client.processes.ProcessQueue;
	import com.apm.client.processes.generic.ExtractZipProcess;
	
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
			APM.io.writeLine( "Installing package : " + _packageData.packageVersion.packageDef.toString() );
			
			var cacheDirForPackage:File = PackageFileUtils.cacheDirForPackage( APM.config.packagesDir, _packageData.packageVersion.packageDef.identifier );
			var packageDir:File = PackageFileUtils.directoryForPackage( APM.config.packagesDir, _packageData.packageVersion.packageDef.identifier );
			var packageFile:File = PackageFileUtils.fileForPackage( APM.config.packagesDir, _packageData.packageVersion );
			
			var queue:ProcessQueue = new ProcessQueue();
			
			if (_packageData.request.source == "file")
			{
				if (_packageData.request.packageFile != null && _packageData.request.packageFile.exists)
				{
					queue.addCallback( function():void {
						try
						{
							var packagesDir:File = new File( APM.config.packagesDir );
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
					});
				}
			}
			else
			{
				queue.addProcess( new DownloadPackageProcess( _packageData.packageVersion ) );
			}
			queue.addProcess( new ExtractZipProcess( packageFile, cacheDirForPackage ) );
			
			queue.start( function ():void {
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
						 function ( error:String ):void {
							 APM.io.writeError( "ERROR", "Failed to install package : " + _packageData.packageVersion.packageDef.toString() );
							 failure( error );
						 } );
			
		}
		
		
		override protected function complete( data:Object=null ):void
		{
			APM.io.writeLine( "Installed package : " + _packageData.packageVersion.packageDef.toString() );
			super.complete();
		}
		
		
	}
	
}
