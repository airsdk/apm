/**
 * @author 		Michael Archbold (https://michaelarchbold.com)
 * @created		24/2/2023
 */
package com.apm.client.commands.project.processes
{
	import com.apm.client.APM;
	import com.apm.client.processes.ProcessBase;
	import com.apm.data.common.Platform;
	import com.apm.data.common.PlatformConfiguration;
	import com.apm.data.common.PlatformParameter;
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
		private var _platformName:String;


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


			var platformConfig:PlatformConfiguration;
			var platformParam:PlatformParameter;
			if (_paramName == null)
			{
				// print all config
				APM.io.writeLine( project.getApplicationId( APM.config.buildType ) + "@" + project.getVersion( APM.config.buildType ) + " " + APM.config.workingDirectory + "" );

				APM.io.writeValue( "identifier", project.getApplicationId( APM.config.buildType ) );
				APM.io.writeValue( "name", project.getApplicationName( APM.config.buildType ).toString() );
				APM.io.writeValue( "filename", project.getApplicationFilename( APM.config.buildType ) );
				APM.io.writeValue( "version", project.getVersion( APM.config.buildType ) );
				APM.io.writeValue( "versionLabel", project.getVersionLabel( APM.config.buildType ) );

				APM.io.writeLine( "platforms" );
				if (project.platforms.length == 0)
				{
					APM.io.writeLine( "└── (all)" );
				}
				else
				{
					for (var p:int = 0; p < project.platforms.length; p++)
					{
						APM.io.writeLine(
								(p == project.platforms.length - 1 ? "└──" : "├──") +
								project.platforms[p].toString() );
					}
				}

				APM.io.writeLine( "platformConfigurations" );
				for each (var platform:String in Platform.ALL_PLATFORMS)
				{
					platformConfig = project.getPlatformConfiguration( platform );
					if (platformConfig == null) continue;

					APM.io.writeLine( "└──" + platform );
					for (var pp:int = 0; pp < platformConfig.parameters.length; pp++)
					{
						platformParam = platformConfig.parameters[pp];
						APM.io.writeValue( "  " + (pp == platformConfig.parameters.length - 1 ? "└──" : "├──") + platformParam.name, platformParam.value );
					}
				}

				APM.io.writeLine( "" );
				APM.io.writeLine( "configuration" );
				for each (var param:ProjectParameter in project.getConfiguration( APM.config.buildType ))
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
					for (var d:int = 0; d < project.dependencies.length; d++)
					{
						APM.io.writeLine(
								(d == project.dependencies.length - 1 ? "└──" : "├──") +
								project.dependencies[d].toString() );
					}
				}
			}
			else
			{
				if (_paramName.indexOf( "/" ) >= 0)
				{
					// This is a platform parameter
					_platformName = _paramName.split( "/" )[0];
					_paramName = _paramName.split( "/" )[1];
					if (!Platform.isKnownPlatformName( _platformName ))
					{
						failure( "Invalid platform name: " + _platformName );
						return;
					}

					platformConfig = project.getPlatformConfiguration( _platformName );
					if (platformConfig == null)
					{
						failure( "Platform not found: " + _platformName );
						return;
					}

					platformParam = platformConfig.getParameter( _paramName );
					if (platformParam == null)
					{
						failure( "Parameter not found: " + _platformName + "/" + _paramName );
						return;
					}

					APM.io.writeValue( _platformName + "/" + platformParam.name, platformParam.value );
				}
				else
				{
					switch (_paramName)
					{
						case "id":
						case "identifier":
							APM.io.writeValue( "identifier", project.getApplicationId( APM.config.buildType ) );
							break;

						case "name":
							APM.io.writeValue( "name", project.getApplicationName( APM.config.buildType ).toString() );
							break;

						case "filename":
							APM.io.writeValue( "filename", project.getApplicationFilename( APM.config.buildType ) );
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
			}

			complete();
		}

	}

}
