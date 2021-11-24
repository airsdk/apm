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
 * @created		22/10/21
 */
package com.apm.client.commands.project.processes
{
	import com.apm.client.APM;
	import com.apm.client.processes.ProcessBase;
	import com.apm.data.project.ProjectDefinition;
	import com.apm.data.project.ProjectParameter;
	
	
	public class ProjectConfigGetProcess extends ProcessBase
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "ProjectConfigGetProcess";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _paramName:String;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function ProjectConfigGetProcess( paramName:String )
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
			
			var param:ProjectParameter;
			if (_paramName == null)
			{
				// print all config
				for each (param in APM.config.projectDefinition.getConfiguration( APM.config.buildType ))
				{
					APM.io.writeValue( param.name, param.value );
				}
			}
			else
			{
				param = project.getConfigurationParam( _paramName, APM.config.buildType );
				if (param == null)
				{
					APM.io.writeError( "parameter", "not found" );
				}
				else
				{
					APM.io.writeValue( param.name, param.value );
				}
			}
			
			complete();
		}
	
	}

}
