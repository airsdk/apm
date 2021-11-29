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
	import com.apm.data.packages.PackageDefinitionFile;
	import com.apm.data.packages.PackageParameter;
	import com.apm.data.project.ProjectDefinition;
	import com.apm.data.project.ProjectParameter;
	import com.apm.utils.PackageCacheUtils;
	
	
	public class ProjectConfigSetProcess extends ProcessBase
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "ProjectConfigGetProcess";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		
		private var _paramName:String;
		private var _paramValue:String;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function ProjectConfigSetProcess( paramName:String, paramValue:String )
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
				// set all config
				for each (var p:ProjectParameter in APM.config.projectDefinition.getConfiguration( APM.config.buildType ))
				{
					_queue.addProcess( new ProjectConfigSetProcess( p.name, null ) );
				}
			}
			else if (_paramValue == null)
			{
				var param:ProjectParameter = project.getConfigurationParam( _paramName, APM.config.buildType );
				var paramPackage:PackageDefinitionFile = PackageCacheUtils.getCachedPackage( _paramName );
				
				if (param != null)
				{
					ProjectConfigDescribeProcess.describeParameter( param );
					var value:String = APM.io.question( "Set", param.value );
					if (value != null && value.length > 0)
					{
						param.value = value;
						project.save();
					}
				}
				else if (paramPackage != null)
				{
					if (paramPackage.version != null && paramPackage.version.parameters.length > 0)
					{
						for each (var pp:PackageParameter in paramPackage.version.parameters)
						{
							_queue.addProcess( new ProjectConfigSetProcess( pp.name, null ) );
						}
					}
					else
					{
						APM.io.writeError( _paramName, "No configuration parameters required" );
					}
				}
			}
			else
			{
				project.setConfigurationParamValue( _paramName, _paramValue, APM.config.buildType );
				project.save();
			}
			
			complete();
		}
		
	}
	
}
