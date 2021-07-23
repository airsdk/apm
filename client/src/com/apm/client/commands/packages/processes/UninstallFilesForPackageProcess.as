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
	import com.apm.client.commands.packages.data.InstallQueryRequest;
	import com.apm.client.commands.packages.utils.DeployFileUtils;
	import com.apm.client.commands.packages.utils.FileUtils;
	import com.apm.client.commands.packages.utils.PackageFileUtils;
	import com.apm.client.logging.Log;
	import com.apm.client.processes.ProcessBase;
	import com.apm.client.processes.ProcessQueue;
	import com.apm.data.packages.PackageDefinitionFile;
	import com.apm.data.packages.PackageDependency;
	
	import flash.filesystem.File;
	
	
	/**
	 * This process deletes all the files associated with an AIR package
	 * - it does not remove any related dependencies
	 */
	public class UninstallFilesForPackageProcess extends ProcessBase
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "UninstallFilesForPackageProcess";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _core:APMCore;
		private var _packageDefinition:PackageDefinitionFile;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function UninstallFilesForPackageProcess( core:APMCore, packageDefinition:PackageDefinitionFile )
		{
			super();
			_core = core;
			_packageDefinition = packageDefinition;
		}
		
		
		override public function start():void
		{
			_core.io.showSpinner( "Removing package : " + _packageDefinition.packageDef.identifier );
			
			var cacheDir:File = PackageFileUtils.cacheDirForPackage( _core, _packageDefinition.packageDef.identifier );
			for each (var ref:File in cacheDir.getDirectoryListing())
			{
				if (ref.isDirectory)
				{
					var deployLocation:File = DeployFileUtils.getDeployLocation( _core.config, ref.name );

					var listing:Array = generateDirectoryListing( ref );

					deleteListedFilesFromDirectory( listing, deployLocation );
//					FileUtils.copyDirectoryTo( ref, deployLocation, true );
				}
			}
			cacheDir.deleteDirectory( true );
			
			var packageDir:File = PackageFileUtils.directoryForPackage( _core, _packageDefinition.packageDef.identifier );
			packageDir.deleteDirectory( true );
			
			_core.io.stopSpinner( true, "Removed package : " + _packageDefinition.packageDef.identifier );
			complete();
		}
		

		private function deleteListedFilesFromDirectory( listing:Array, directory:File ):void
		{
			for each (var path:String in listing)
			{
				_core.io.updateSpinner( "Removing package : " + _packageDefinition.packageDef.identifier + " / " + path );
				var f:File = directory.resolvePath( path );
				if (f.exists)
					f.deleteFile();
			}
		}
		
		private function generateDirectoryListing( directory:File, path:String="", listing:Array=null ):Array
		{
			if (listing == null) listing = [];
			for each (var f:File in directory.getDirectoryListing())
			{
				if (f.isDirectory) {
					generateDirectoryListing( f, path + f.name + File.separator, listing );
				}
				else {
					listing.push( path + f.name );
				}
			}
			return listing;
		}
		
	}
	
}
