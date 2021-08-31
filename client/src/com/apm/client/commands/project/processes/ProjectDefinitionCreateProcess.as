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
	import com.apm.client.APM;
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
		
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function ProjectDefinitionCreateProcess()
		{
		}
		
		
		override public function start( completeCallback:Function = null, failureCallback:Function = null ):void
		{
			super.start( completeCallback, failureCallback );
			if (APM.config.projectDefinition != null)
			{
				APM.io.writeLine( "Already have a config file " );
				
				var response:String = APM.io.question( "Overwrite? Y/n", "n" )
				if (response.toLowerCase() != "y")
				{
					complete();
					return;
				}
			}
			
			APM.io.writeLine( "Creating new project definition file" );
			
			var project:ProjectDefinition = new ProjectDefinition();
			
			//
			//	Walk through any questions
			
			project.applicationId = APM.io.question( "Application Identifier", "com.my.app" )
			project.applicationName = APM.io.question( "Application Name", "My Application" )
			project.version = APM.io.question( "Application Version", "1.0.0" )
			
			
			// TODO
			
			
			var projectFile:File = new File( APM.config.workingDir + File.separator + ProjectDefinition.DEFAULT_FILENAME );
			project.save( projectFile );
			
			complete();
		}
		
	}
	
}
