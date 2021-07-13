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
 * @created		28/5/21
 */
package com.apm.client.config.processes
{
	import com.apm.client.config.RunConfig;
	import com.apm.client.logging.Log;
	import com.apm.client.processes.Process;
	import com.apm.client.processes.ProcessBase;
	import com.apm.client.processes.ProcessQueue;
	import com.apm.client.processes.events.ProcessEvent;
	import com.apm.data.project.ProjectDefinition;
	
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	
	
	public class LoadProjectDefinitionProcess extends ProcessBase
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "LoadMacOSEnvironmentVariablesProcess";
		
		
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
		
		
		override public function start():void
		{
			Log.d( TAG, "start()" );
			try
			{
				var f:File = new File( _config.workingDir + File.separator + ProjectDefinition.DEFAULT_FILENAME );
				if (f.exists)
				{
					Log.d( TAG, "found project file - loading ..." );
					_config.projectDefinition = new ProjectDefinition();
					_config.projectDefinition.load( f );
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
