/**
 * @author 		Michael Archbold (https://michaelarchbold.com)
 * @created		29/9/2021
 */
package com.apm.client.commands.project.processes
{
	import com.apm.client.APM;
	import com.apm.client.logging.Log;
	import com.apm.client.processes.ProcessBase;
	import com.apm.data.common.Platform;
	import com.apm.data.common.PlatformConfiguration;
	import com.apm.data.common.PlatformParameter;
	import com.apm.data.project.ProjectDefinition;
	import com.apm.data.project.ProjectParameter;

	/**
	 * This process does a quick check that the packages in the project definition
	 * file are available in the package cache.
	 */
	public class ValidateProjectParametersProcess extends ProcessBase
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//

		private static const TAG:String = "ValidateProjectParametersProcess";


		////////////////////////////////////////////////////////
		//  VARIABLES
		//


		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//

		public function ValidateProjectParametersProcess()
		{
		}


		override public function start( completeCallback:Function = null, failureCallback:Function = null ):void
		{
			super.start( completeCallback, failureCallback );

			Log.d( TAG, "Validating parameters in project definition" );

			var project:ProjectDefinition = APM.config.projectDefinition;
			if (project == null)
			{
				failure( "No project file found" );
				return;
			}

			var isValid:Boolean = true;
			for each (var param:ProjectParameter in project.getConfiguration( APM.config.buildType ))
			{
				if (!param.isValid( project.platforms ))
				{
					isValid = false;
					APM.io.writeError( "validation", "Parameter not valid: " + param.name + "=" + param.value );
					ProjectConfigDescribeProcess.describeParameter( param );
					APM.io.writeLine( "" );
				}
			}

			for each (var platform:String in Platform.ALL_PLATFORMS)
			{
				if (!project.shouldIncludePlatform( platform )) continue;
				var platformConfig:PlatformConfiguration = project.getPlatformConfiguration( platform );
				if (platformConfig == null) continue;
				for each (var platformParam:PlatformParameter in platformConfig.parameters)
				{
					if (!platformParam.isValid())
					{
						isValid = false;
						APM.io.writeError( "validation", "Platform parameter not valid: " + platformParam.name + "=" + platformParam.value );
						APM.io.writeLine( "" );
					}
				}
			}

			if (!isValid)
			{
				failure( "Invalid project configuration parameters" );
				return;
			}

			complete();
		}

	}

}
