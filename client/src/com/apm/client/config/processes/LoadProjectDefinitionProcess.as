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
 * @created		28/5/2021
 */
package com.apm.client.config.processes
{
	import com.apm.client.config.RunConfig;
	import com.apm.client.logging.Log;
	import com.apm.client.processes.ProcessBase;
	import com.apm.data.project.ProjectDefinition;
	import com.apm.data.project.ProjectLock;
	
	import flash.filesystem.File;
	
	
	public class LoadProjectDefinitionProcess extends ProcessBase
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "LoadProjectDefinitionProcess";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		
		private var _config:RunConfig;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function LoadProjectDefinitionProcess( config:RunConfig )
		{
			_config = config;
		}
		
		
		override public function start( completeCallback:Function = null, failureCallback:Function = null ):void
		{
			super.start( completeCallback, failureCallback );
			Log.d( TAG, "start()" );
			try
			{
				var projectFile:File = new File( _config.workingDirectory + File.separator + ProjectDefinition.DEFAULT_FILENAME );
				if (projectFile.exists)
				{
					Log.d( TAG, "found project file - loading ..." );
					_config.projectDefinition = new ProjectDefinition()
							.load( projectFile );
				}
				
				var lockFile:File = new File( _config.workingDirectory + File.separator + ProjectLock.DEFAULT_FILENAME );
				if (lockFile.exists)
				{
					Log.d( TAG, "found project lock file - loading ..." );
					_config.projectLock = new ProjectLock()
							.load( lockFile );
				}
				
				complete();
			}
			catch (e:Error)
			{
				Log.e( TAG, e );
				if (e.errorID == 1132) // Invalid JSON parse
				{
					failure( "Could not parse project file, check the format is correct" );
				}
				else
				{
					failure( e.message );
				}
			}
		}
		
	}
	
}
