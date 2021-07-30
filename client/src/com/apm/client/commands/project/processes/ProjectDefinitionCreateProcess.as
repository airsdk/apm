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
package com.apm.client.commands.project.processes
{
	import com.apm.client.APMCore;
	import com.apm.client.processes.ProcessBase;
	import com.apm.data.project.ProjectDefinition;
	
	import flash.filesystem.File;
	
	
	public class ProjectDefinitionCreateProcess extends ProcessBase
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "ProjectDefinitionCreateProcess";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _core:APMCore;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function ProjectDefinitionCreateProcess( core:APMCore )
		{
			_core = core;
		}
		
		
		override public function start():void
		{
			if (_core.config.projectDefinition != null)
			{
				_core.io.writeLine( "Already have a config file " );
				
				var response:String = _core.io.question( "Overwrite? Y/n", "n" )
				if (response.toLowerCase() != "y")
				{
					return _core.exit( APMCore.CODE_ERROR );
				}
			}
			
			_core.io.writeLine( "Creating new project definition file" );
			
			var project:ProjectDefinition = new ProjectDefinition();
			
			//
			//	Walk through any questions
			
			project.applicationId = _core.io.question( "Application Identifier", "com.my.app" )
			project.applicationName = _core.io.question( "Application Name", "My Application" )
			project.version = _core.io.question( "Application Version", "1.0.0" )
			
			
			// TODO
			
			
			var projectFile:File = new File( _core.config.workingDir + File.separator + ProjectDefinition.DEFAULT_FILENAME );
			project.save( projectFile );
			
			complete();
		}
		
	}
	
}
