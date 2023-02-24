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
 * @created		24/2/2023
 */
package com.apm.client.commands.project.processes
{
	import com.apm.client.APM;
	import com.apm.client.processes.ProcessBase;
	import com.apm.data.project.ProjectDefinition;
	import com.apm.data.project.ProjectParameter;
	
	
	public class ProjectGetProcess extends ProcessBase
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "ProjectGetProcess";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _paramName:String;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function ProjectGetProcess( paramName:String )
		{
			_paramName = paramName;
		}
		
		
		override public function start( completeCallback:Function = null, failureCallback:Function = null ):void
		{
			super.start( completeCallback, failureCallback );
			
			var project:ProjectDefinition = APM.config.projectDefinition;
			if (project == null)
			{
				failure( "No project file found" );
				return;
			}

			if (_paramName == null)
			{
				// print all config
				APM.io.writeLine( project.getApplicationId( APM.config.buildType ) + "@" + project.getVersion( APM.config.buildType ) + " " + APM.config.workingDirectory + "" );

				APM.io.writeValue( "identifier", project.getApplicationId( APM.config.buildType ) );
				APM.io.writeValue( "version", project.getVersion( APM.config.buildType ) );
				APM.io.writeValue( "versionLabel", project.getVersionLabel( APM.config.buildType ) );

				APM.io.writeLine( "" );
				APM.io.writeLine( "configuration" );
				for each (var param:ProjectParameter in APM.config.projectDefinition.getConfiguration( APM.config.buildType ))
				{
					APM.io.writeValue( param.name, param.value );
				}

				APM.io.writeLine( "" );
				APM.io.writeLine( "dependencies" );
				if (project.dependencies.length == 0)
				{
					APM.io.writeLine( "└── (empty)" );
				}
				else
				{
					for (var i:int = 0; i < project.dependencies.length; i++)
					{
						APM.io.writeLine(
								(i == project.dependencies.length - 1 ? "└──" : "├──") +
								project.dependencies[ i ].toString() );
					}
				}
			}
			else
			{
				switch (_paramName)
				{
					case "id":
					case "identifier":
						APM.io.writeValue( "identifier", project.getApplicationId( APM.config.buildType ) );
						break;

					case "version":
						APM.io.writeValue( "version", project.getVersion( APM.config.buildType ) );
						break;

					case "versionLabel":
						APM.io.writeValue( "versionLabel", project.getVersionLabel( APM.config.buildType ) );
						break;

					default:
						APM.io.writeError( "parameter", "not found" );
						break;
				}
			}

			complete();
		}
	
	}

}
