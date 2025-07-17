/**
 * @author 		Michael Archbold (https://michaelarchbold.com)
 * @created		24/2/2023
 */
package com.apm.client.commands.project.processes
{
	import com.apm.client.APM;
	import com.apm.client.processes.ProcessBase;
	import com.apm.data.common.Platform;
	import com.apm.data.common.PlatformParameter;
	import com.apm.data.project.ProjectDefinition;

	public class ProjectSetProcess extends ProcessBase
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//

		private static const TAG:String = "ProjectSetProcess";


		////////////////////////////////////////////////////////
		//  VARIABLES
		//


		private var _paramName:String;
		private var _paramValue:String;
		private var _platformName:String;


		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//

		public function ProjectSetProcess( paramName:String, paramValue:String )
		{
			_paramName = paramName;
			_paramValue = paramValue;
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
				failure( "No parameter name specified" );
				return;
			}

			if (_paramName.indexOf( "/" ) >= 0)
			{
				// This is a platform parameter
				_platformName = _paramName.split( "/" )[0];
				_paramName = _paramName.split( "/" )[1];
				if (!Platform.isKnownPlatformName( _platformName ))
				{
					APM.io.writeError( "platform", "Invalid platform name: " + _platformName );
					return;
				}
			}

			if (_paramValue == null)
			{
				var value:String = APM.io.question( "Set", _paramName );
				setProjectValue( project, _platformName, _paramName, value )
			}
			else
			{
				setProjectValue( project, _platformName, _paramName, _paramValue )
			}

			project.save();
			complete();
		}


		private function setProjectValue( project:ProjectDefinition, platform:String, name:String, value:String ):void
		{
			if (platform != null)
			{
				var param:PlatformParameter = new PlatformParameter( name, value );
				if (!param.isValid())
				{
					APM.io.writeError( name, "Invalid platform parameter: " + platform + " :: " + param.name + " = " + param.value );
					return;
				}
				project.setPlatformParameter(
						new Platform( platform ),
						param
				);
				return;
			}

			switch (name)
			{
				case "id":
				case "identifier":
				{
					project.setApplicationId( value, APM.config.buildType );
					break;
				}
				case "filename":
				{
					project.setApplicationFilename( value, APM.config.buildType );
					break;
				}
				case "name":
				{
					project.setApplicationName( value, APM.config.buildType );
					break;
				}
				case "version":
				{
					project.setVersion( value, APM.config.buildType );
					break;
				}
				case "versionLabel":
				{
					project.setVersionLabel( value, APM.config.buildType );
					break;
				}
				case "platforms":
				{
					project.platforms.length = 0;
					var platforms:Array = value.split( "," );
					for each (var p:String in platforms)
					{
						if (!Platform.isKnownPlatformName( p ))
						{
							APM.io.writeError( name, "Invalid platform name: " + p );
							continue;
						}

						project.platforms.push( new Platform( p, true ) );
					}
					break;
				}
				default:
				{
					APM.io.writeError( name, "Invalid project parameter name" );
				}
			}
		}


	}

}
