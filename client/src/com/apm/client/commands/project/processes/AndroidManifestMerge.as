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
 * @created		31/8/2021
 */
package com.apm.client.commands.project.processes
{
	
	public class AndroidManifestMerge
	{
		public static const MERGE_TOOL_VERSION:String = "31.9.0";
		
		private static const MERGE_TOOL_FILENAME:String = "manifest-merger-@MERGE_TOOL_VERSION@.jar";
	
	
		public static function get mergeToolFilename():String
		{
			return MERGE_TOOL_FILENAME
					.replace( /@MERGE_TOOL_VERSION@/g, MERGE_TOOL_VERSION );
		}
		
	}

}
