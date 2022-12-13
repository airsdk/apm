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
	import com.apm.utils.DeployFileUtils;
	import com.apm.utils.FileUtils;
	import com.apm.utils.PackageFileUtils;
	import com.apm.client.logging.Log;
	import com.apm.client.processes.ProcessBase;
	import com.apm.data.packages.PackageDefinitionFile;
	
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
		
		private var _packageDefinition:PackageDefinitionFile;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function UninstallFilesForPackageProcess( packageDefinition:PackageDefinitionFile )
		{
			super();
			_packageDefinition = packageDefinition;
		}
		
		
		override public function start( completeCallback:Function = null, failureCallback:Function = null ):void
		{
			super.start( completeCallback, failureCallback );
			APM.io.showSpinner( "Removing package : " + _packageDefinition.packageDef.identifier );
			
			var cacheDir:File = PackageFileUtils.contentsDirForPackage( APM.config.packagesDirectory, _packageDefinition.packageDef.identifier );
			for each (var ref:File in cacheDir.getDirectoryListing())
			{
				if (ref.isDirectory)
				{
					var deployLocation:File = DeployFileUtils.getDeployLocation( APM.config, ref.name );
					if (deployLocation != null)
					{
						var listing:Array = generateDirectoryListing( ref );
						
						deleteListedFilesFromDirectory( listing, deployLocation );
						
						FileUtils.removeEmptyDirectories( deployLocation, true );
					}
				}
			}
			cacheDir.deleteDirectory( true );
			
			var packageDir:File = PackageFileUtils.directoryForPackage( APM.config.packagesDirectory, _packageDefinition.packageDef.identifier );
			packageDir.deleteDirectory( true );
			
			APM.io.stopSpinner( true, "Removed package : " + _packageDefinition.packageDef.identifier );
			complete();
		}
		
		
		private function deleteListedFilesFromDirectory( listing:Array, directory:File ):void
		{
			for each (var path:String in listing)
			{
				Log.d( TAG, "Removing package : " + _packageDefinition.packageDef.identifier + " / " + path );
				APM.io.updateSpinner( "Removing package : " + _packageDefinition.packageDef.identifier + " / " + path );
				var f:File = directory.resolvePath( path );
				if (f.exists)
					f.deleteFile();
			}
		}
		
		
		private static function generateDirectoryListing( directory:File, path:String = "", listing:Array = null ):Array
		{
			if (listing == null) listing = [];
			for each (var f:File in directory.getDirectoryListing())
			{
				if (f.isDirectory)
				{
					generateDirectoryListing( f, path + f.name + File.separator, listing );
				}
				else
				{
					listing.push( path + f.name );
				}
			}
			return listing;
		}
		
	}
	
}
