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
	import com.apm.client.APMCore;
	import com.apm.client.Consts;
	import com.apm.data.packages.PackageDefinition;
	import com.apm.data.packages.PackageVersion;
	
	import flash.filesystem.File;
	
	
	public class PackageFileUtils
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "PackageFileUtils";
		
		public static const AIRPACKAGEEXTENSION : String = "airpackage";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function PackageFileUtils()
		{
		}
		
		
		public static function directoryForPackage( core:APMCore, packageDef:PackageDefinition ):File
		{
			var packageDir:File = new File( core.config.packagesDir + File.separator + packageDef.identifier );
			return packageDir;
		}
		
		
		public static function filenameForPackage( packageVersion:PackageVersion ):String
		{
			var filename:String = packageVersion.packageDef.identifier + "_" + packageVersion.version.toString() + "." + AIRPACKAGEEXTENSION;
			return filename;
		}
		
		
		public static function fileForPackage( core:APMCore, packageVersion:PackageVersion ):File
		{
			return PackageFileUtils.directoryForPackage( core, packageVersion.packageDef )
					.resolvePath(
							PackageFileUtils.filenameForPackage( packageVersion )
					);
		}
		
	}
	
}
