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
 * @created		13/7/21
 * @copyright	http://distriqt.com/copyright/license.txt
 */
package com.apm.client.commands.packages.utils 
{
	import com.apm.client.config.RunConfig;
	import com.apm.data.project.ProjectDefinition;
	
	import flash.filesystem.File;
	
	
	public class DeployFileUtils
    {
 		////////////////////////////////////////////////////////
        //  CONSTANTS
        //
        
        private static const TAG : String = "DeployFileUtils";
        
        
 		////////////////////////////////////////////////////////
        //  VARIABLES
        //
        

 		////////////////////////////////////////////////////////
        //  FUNCTIONALITY
        //
        
        public function DeployFileUtils() 
        {
        }
	
		public static const DEPLOY_OPTIONS:Object = {
			ane: "aneDir",
			swc: "swcDir",
			src: "srcDir"
		};
		
		public static const DEFAULT_DIRS:Object = {
			ane: "ane",
			swc: "libs",
			src: "libs_src"
		};
		
		public static function getDeployLocation( config:RunConfig, type:String ):File
		{
			var deployDirForType:File;
			var working:File = new File( config.workingDir );
			var option:String = DEPLOY_OPTIONS.hasOwnProperty(type) ? DEPLOY_OPTIONS[type] : type;
			if (config.projectDefinition.deployOptions.hasOwnProperty( option ))
			{
				var deployPathForType:String = config.projectDefinition.deployOptions[option];
				deployDirForType = working.resolvePath( deployPathForType );
			}
			else
			{
				switch (type)
				{
					case "ane":
					case "swc":
					case "src":
						deployDirForType = working.resolvePath( DEFAULT_DIRS[type] );
						break;
					default:
						deployDirForType = working.resolvePath( type );
				}
			}
			if (!deployDirForType.exists) deployDirForType.createDirectory();
			return deployDirForType;
		}
		
        
    }
}
