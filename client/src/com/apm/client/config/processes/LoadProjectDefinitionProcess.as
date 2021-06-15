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
	import com.apm.client.processes.ProcessQueue;
	import com.apm.client.processes.events.ProcessEvent;
	import com.apm.data.ProjectDefinition;
	
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	import flash.utils.setTimeout;
	
	
	public class LoadProjectDefinitionProcess extends EventDispatcher implements Process
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "LoadMacOSEnvironmentVariablesProcess";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		
		private var _config : RunConfig;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function LoadProjectDefinitionProcess( config:RunConfig )
		{
			_config = config;
		}
		
		
		public function set queue( value:ProcessQueue ):void
		{
		}
		
		
		public function start():void
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
			}
			catch (e:Error)
			{
				Log.e( TAG, e );
			}
			
			dispatchEvent( new ProcessEvent( ProcessEvent.COMPLETE ))
		}
		
	}
	
}
