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
 * @created		8/9/2021
 */
package com.apm.client.processes.upgrade
{
	import com.apm.SemVer;
	import com.apm.client.APM;
	import com.apm.client.Consts;
	import com.apm.client.logging.Log;
	import com.apm.client.processes.ProcessBase;
	import com.apm.client.processes.ProcessQueue;
	import com.apm.client.processes.generic.ExtractZipProcess;
	import com.apm.remote.github.GitHubAPI;
	import com.apm.utils.FileUtils;
	
	import flash.filesystem.File;
	
	
	/**
	 * Checks for an update to apm and installs it if available
	 */
	public class UpgradeClientProcess extends ProcessBase
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "UpgradeClientProcess";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _githubAPI:GitHubAPI;
		private var _destination:File;
		private var _installQueue:ProcessQueue;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function UpgradeClientProcess()
		{
			_githubAPI = new GitHubAPI();
		}
		
		
		override public function start( completeCallback:Function = null, failureCallback:Function = null ):void
		{
			super.start( completeCallback, failureCallback );
			APM.io.writeLine( "apm: v" + new SemVer( Consts.VERSION ).toString() );
			APM.io.showSpinner( "Checking for latest release" );
			var currentVersion:SemVer = new SemVer( Consts.VERSION );
			
			_githubAPI.call( "/repos/airsdk/apm/releases", function ( success:Boolean, data:* ):void {
				if (success)
				{
					var releases:Array = JSON.parse( String( data ) ) as Array;
					var latestRelease:Object = releases[ 0 ];
					var latestVersion:SemVer = new SemVer( latestRelease.name );
					
					if (latestVersion.greaterThan( currentVersion ))
					{
						var assetUrl:String = null;
						var filename:String = "apm_" + latestVersion.toString() + ".zip";
						// find the download asset
						for each (var asset:Object in latestRelease.assets)
						{
							if (asset.name == filename)
							{
								assetUrl = asset.browser_download_url;
							}
						}
						
						if (assetUrl != null)
						{
							APM.io.stopSpinner( true, "Found new release: " + latestVersion.toString() );
							downloadUpdate( assetUrl, filename, latestVersion );
						}
						else
						{
							APM.io.stopSpinner( false, "Could not find release asset" );
							failure( "Could not find release asset" );
						}
					}
					else
					{
						APM.io.stopSpinner( true, "Already at latest version" );
						complete();
					}
				}
				else
				{
					APM.io.stopSpinner( false, "Error checking for latest release" );
					failure( "Error checking for latest release" );
				}
			} );
		}
		
		
		private function downloadUpdate( url:String, filename:String, version:SemVer ):void
		{
			Log.d( TAG, "downloadUpdate( " + url + ", " + filename + ", " + version.toString() + " )" );
			
			APM.io.showSpinner( "Installing new release" );
			
			if (!FileUtils.tmpDirectory.exists) FileUtils.tmpDirectory.createDirectory();
			
			_destination = FileUtils.tmpDirectory.resolvePath( filename );
			var appDir:File = new File( APM.config.appDirectory );
			
			Log.d( TAG, "Downloading to: " + _destination.nativePath );
			Log.d( TAG, "Extracting to: " + appDir.nativePath );
			
			_installQueue = new ProcessQueue();
			_installQueue.addProcess( new UpgradeClientDownloadProcess( url, _destination ) );
			_installQueue.addProcess( new ExtractZipProcess( _destination, new File( APM.config.appDirectory ), false ) );
			_installQueue.addProcess( new UpgradeClientFinaliseProcess() );
			_installQueue.start( function ():void {
									 APM.io.stopSpinner( true, "Install complete" );
									 complete();
								 },
								 function ( error:String ):void {
									 APM.io.stopSpinner( false, error );
									 failure( error );
								 } );
		}
		
		
	}
	
}
