/**
 * @author 		Michael Archbold (https://michaelarchbold.com)
 * @created		29/9/2021
 */
package com.apm.client.commands.project.processes
{
	import com.apm.client.APM;
	import com.apm.client.logging.Log;
	import com.apm.client.processes.ProcessBase;
	import com.apm.data.project.ProjectDefinition;
	import com.apm.utils.ProjectPackageCache;
	
	import flash.filesystem.File;
	
	
	/**
	 * This process does a quick check that the packages in the project definition
	 * file are available in the package cache.
	 */
	public class ValidatePackageCacheProcess extends ProcessBase
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "ValidatePackageCacheProcess";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function ValidatePackageCacheProcess()
		{
		}
		
		
		override public function start( completeCallback:Function = null, failureCallback:Function = null ):void
		{
			super.start( completeCallback, failureCallback );
			
			Log.d( TAG, "Validating packages in project definition are installed" );
			
			var project:ProjectDefinition = APM.config.projectDefinition;
			if (project == null)
			{
				failure( "No project file found" );
				return;
			}
			
			var packagesDir:File = new File( APM.config.packagesDirectory );
			for (var i:int = 0; i < project.dependencies.length; i++)
			{
				if (!ProjectPackageCache.isPackageInstalled(
						project.dependencies[ i ].identifier,
						project.dependencies[ i ].version
				))
				{
					failure( "Required package not installed: " + project.dependencies[ i ].toString() + " : run 'apm install'" );
					return;
				}
			}
			
			complete();
		}
		
	}
	
}
