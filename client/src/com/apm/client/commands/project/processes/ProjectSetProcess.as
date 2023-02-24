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
	import com.apm.data.packages.PackageDefinitionFile;
	import com.apm.data.packages.PackageParameter;
	import com.apm.data.project.ProjectDefinition;
	import com.apm.data.project.ProjectParameter;
	import com.apm.utils.ProjectPackageCache;

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
			else if (_paramValue == null)
			{
				var value:String = APM.io.question( "Set", _paramName );
				setProjectValue( project, _paramName, value )
			}
			else
			{
				setProjectValue( project, _paramName, _paramValue )
			}

			project.save();
			complete();
		}


		private function setProjectValue( project:ProjectDefinition, name:String, value:String ):void
		{
			switch (_paramName)
			{
				case "id":
				case "identifier":
				{
					project.setApplicationId( value, APM.config.buildType );
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
				default:
				{
					APM.io.writeError( name, "Invalid project parameter name" );
				}
			}
		}


	}

}
