/**
 * @author 		Michael Archbold (https://michaelarchbold.com)
 * @created		16/6/2023
 */
package com.apm.client.commands.project.processes
{
	import com.apm.client.APM;
	import com.apm.client.processes.ProcessBase;
	import com.apm.data.project.ProjectDefinition;
	import com.apm.data.common.Platform;

	public class ProjectAddProcess extends ProcessBase
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//

		private static const TAG:String = "PackageSetProcess";


		////////////////////////////////////////////////////////
		//  VARIABLES
		//


		private var _paramName:String;
		private var _paramValue:String;


		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//

		public function ProjectAddProcess( paramName:String, paramValue:String )
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
			else if (_paramValue == null)
			{
				var value:String = APM.io.question( "Add", _paramName );
				addProjectValue( project, _paramName, value )
			}
			else
			{
				addProjectValue( project, _paramName, _paramValue )
			}

			project.save();
			complete();
		}


		private function addProjectValue( project:ProjectDefinition, name:String, value:String ):void
		{
			switch (_paramName)
			{
				case "platforms":
				{
					var platformName:String = value.toLowerCase();
					if (!Platform.isKnownPlatformName(platformName))
					{
						APM.io.writeError( name, "Invalid platform name" );
						return;
					}

					for each (var platform:Platform in project.platforms)
					{
						if (platform.name == platformName)
						{
							APM.io.writeError( name, "This value already exists" );
							return;
						}
					}

					project.platforms.push( new Platform( platformName, true ) );
					break;
				}
				default:
				{
					APM.io.writeError( name, "This parameter is not an array or is invalid" );
				}
			}
		}


	}

}
