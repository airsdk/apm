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
 * @created		29/9/21
 */
package com.apm.client.commands.project.processes
{
	import com.apm.client.APM;
	import com.apm.client.logging.Log;
	import com.apm.client.processes.ProcessBase;
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
			
			for each (var param:ProjectParameter in APM.config.projectDefinition.getConfiguration( APM.config.buildType ))
			{
				if (!param.isValid())
				{
					failure( "Parameter not valid: " + param.name + "=" + param.value );
					return;
				}
			}
			
			complete();
		}
		
	}
	
}
