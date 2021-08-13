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
 * @brief
 * @author 		marchbold
 * @created		12/7/21
 * @copyright	http://distriqt.com/copyright/license.txt
 */
package com.apm.client.commands.packages.utils
{
	import com.apm.client.APMCore;
	import com.apm.data.packages.PackageVersion;
	
	import flash.filesystem.File;
	
	
	public class PackageFileUtils
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "PackageFileUtils";
		
		public static const AIRPACKAGEEXTENSION:String = "airpackage";
		
		
		public static const AIRPACKAGE_SWC_DIR:String = "swc";
		public static const AIRPACKAGE_ANE_DIR:String = "ane";
		public static const AIRPACKAGE_SRC_DIR:String = "src";
		
		public static const AIRPACKAGE_ASSETS:String = "assets";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function PackageFileUtils()
		{
		}
		
		
		public static function directoryForPackage( core:APMCore, identifier:String ):File
		{
			var packageDir:File = new File( core.config.packagesDir + File.separator + identifier );
			return packageDir;
		}
		
		
		public static function filenameForPackage( packageVersion:PackageVersion ):String
		{
			var filename:String = packageVersion.packageDef.identifier + "_" + packageVersion.version.toString() + "." + AIRPACKAGEEXTENSION;
			return filename;
		}
		
		
		public static function fileForPackage( core:APMCore, packageVersion:PackageVersion ):File
		{
			return PackageFileUtils.directoryForPackage( core, packageVersion.packageDef.identifier )
					.resolvePath(
							PackageFileUtils.filenameForPackage( packageVersion )
					);
		}
		
		
		public static function cacheDirForPackage( core:APMCore, identifier:String ):File
		{
			return PackageFileUtils.directoryForPackage( core, identifier )
					.resolvePath(
							"contents"
					);
		}
		
	}
	
}
