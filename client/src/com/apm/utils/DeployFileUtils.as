/**
 * @author 		Michael Archbold (https://michaelarchbold.com)
 * @created		13/7/2021
 */
package com.apm.utils
{
	import com.apm.client.commands.packages.utils.*;
	import com.apm.client.config.RunConfig;
	
	import flash.filesystem.File;
	
	
	public class DeployFileUtils
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "DeployFileUtils";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function DeployFileUtils()
		{
		}
		
		
		public static const DEPLOY_OPTIONS:Object = {};
		
		{
			DEPLOY_OPTIONS[ PackageFileUtils.AIRPACKAGE_ANE_DIR ] = "aneDir";
			DEPLOY_OPTIONS[ PackageFileUtils.AIRPACKAGE_SWC_DIR ] = "swcDir";
			DEPLOY_OPTIONS[ PackageFileUtils.AIRPACKAGE_SRC_DIR ] = "srcDir";
			DEPLOY_OPTIONS[ PackageFileUtils.AIRPACKAGE_ASSETS ] = "assetsDir";
			DEPLOY_OPTIONS[ ProjectPackageCache.PACKAGE_CACHE_DIR ] = "packageCacheDir";
			DEPLOY_OPTIONS[ "config" ] = "configDir";
		}
		
		
		public static const DEFAULT_DIRS:Object = {};
		
		{
			DEFAULT_DIRS[ PackageFileUtils.AIRPACKAGE_ANE_DIR ] = "ane";
			DEFAULT_DIRS[ PackageFileUtils.AIRPACKAGE_SWC_DIR ] = "libs";
			DEFAULT_DIRS[ PackageFileUtils.AIRPACKAGE_SRC_DIR ] = "libs_src";
			DEFAULT_DIRS[ PackageFileUtils.AIRPACKAGE_ASSETS ] = "assets";
			DEFAULT_DIRS[ ProjectPackageCache.PACKAGE_CACHE_DIR ] = ProjectPackageCache.PACKAGE_CACHE_DIR;
			DEFAULT_DIRS[ "config" ] = "config";
		}
		
		
		public static function getDeployLocation( config:RunConfig, dirName:String ):File
		{
			var deployDirForType:File;
			var working:File = new File( config.workingDirectory );
			var option:String = DEPLOY_OPTIONS.hasOwnProperty( dirName ) ? DEPLOY_OPTIONS[ dirName ] : dirName;
			if (config.projectDefinition != null && config.projectDefinition.deployOptions.hasOwnProperty( option ))
			{
				var deployPathForType:String = config.projectDefinition.deployOptions[ option ];
				deployDirForType = FileUtils.getSourceForPath( deployPathForType );
			}
			else
			{
				switch (dirName)
				{
					case PackageFileUtils.AIRPACKAGE_ANE_DIR:
					case PackageFileUtils.AIRPACKAGE_SWC_DIR:
					case PackageFileUtils.AIRPACKAGE_SRC_DIR:
					case PackageFileUtils.AIRPACKAGE_ASSETS:
					case ProjectPackageCache.PACKAGE_CACHE_DIR:
					case "config":
						deployDirForType = working.resolvePath( DEFAULT_DIRS[ dirName ] );
						break;
					
					case PackageFileUtils.AIRPACKAGE_PLATFORMS: // Should not be deployed
					default:
						return null;
				}
			}
			if (!deployDirForType.exists) deployDirForType.createDirectory();
			return deployDirForType;
		}
		
		
	}
	
}
