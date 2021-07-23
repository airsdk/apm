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
	import com.apm.client.APMCore;
	import com.apm.client.commands.packages.data.InstallPackageData;
	import com.apm.client.commands.packages.utils.PackageFileUtils;
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
		
		private var _core:APMCore;
		private var _installData:InstallPackageData;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function InstallPackageProcess( core:APMCore, installData:InstallPackageData )
		{
			super();
			_core = core;
			_installData = installData;
		}
		
		
		override public function start():void
		{
			_core.io.writeLine( "Installing package : " + _installData.packageVersion.packageDef.toString() );
			
			var queue:ProcessQueue = new ProcessQueue();
			
			queue.addProcess( new DownloadPackageProcess( _core, _installData.packageVersion ) );
			
			var packageDir:File = PackageFileUtils.cacheDirForPackage( _core, _installData.packageVersion.packageDef.identifier );
			var packageFile:File = PackageFileUtils.fileForPackage( _core, _installData.packageVersion );
			
			queue.addProcess( new ExtractZipProcess( _core, packageFile, packageDir ) );
			
			queue.start( function ():void {
							 _core.io.writeLine( "Installed package : " + _installData.packageVersion.packageDef.toString() );
							 complete();
						 },
						 function ( error:String ):void {
							 _core.io.writeError( "ERROR", "Failed to install package : " + _installData.packageVersion.packageDef.toString() );
							 failure( error );
						 } );
			
		}
		
		
	}
	
}
