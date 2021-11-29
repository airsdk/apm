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
	import com.apm.client.io.IOColour;
	import com.apm.client.processes.ProcessBase;
	import com.apm.data.packages.PackageDefinitionFile;
	import com.apm.data.packages.PackageDefinitionFile;
	import com.apm.data.packages.PackageParameter;
	import com.apm.data.project.ProjectDefinition;
	import com.apm.data.project.ProjectParameter;
	import com.apm.utils.PackageCacheUtils;
	
	import flash.html.script.Package;
	
	
	public class ProjectConfigDescribeProcess extends ProcessBase
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "ProjectConfigDescribeProcess";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _paramName:String = null;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function ProjectConfigDescribeProcess( paramName:String )
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
				for each (var p:ProjectParameter in APM.config.projectDefinition.getConfiguration( APM.config.buildType ))
				{
					_queue.addProcess( new ProjectConfigDescribeProcess( p.name ) );
				}
				complete();
				return;
			}
			
			
			var param:ProjectParameter = project.getConfigurationParam( _paramName, APM.config.buildType );
			var paramPackage:PackageDefinitionFile = PackageCacheUtils.getCachedPackage( _paramName );
			
			if (param != null)
			{
				describeParameter( param );
			}
			else if (paramPackage != null)
			{
				for each (var pp:PackageParameter in paramPackage.version.parameters)
				{
					_queue.addProcess( new ProjectConfigDescribeProcess( pp.name ) );
				}
			}
			else
			{
				APM.io.writeError( "parameter", _paramName + " not found" );
			}
			
			complete();
		}
		
		
		public static function describeParameter( param:ProjectParameter ):void
		{
			var linePrefix:String = "# ";
			var linePadding:String = "        ";
			
			var packages:Vector.<PackageDefinitionFile> = PackageCacheUtils.getCachedPackages();
			var descriptions:Array = [];
			for each (var packageDef:PackageDefinitionFile in packages)
			{
				for each (var packageParam:PackageParameter in packageDef.version.parameters)
				{
					if (packageParam.name == param.name)
					{
						if (packageParam.description == null)
						{
							descriptions.push( "[" + packageDef.packageDef.identifier + "]: " + "no description provided" );
						}
						else
						{
							// Allow for multiple lines - prefix the first with the identifier and the rest with padding
							var lines:Array = packageParam.description.replace( /\r/g, "" ).split( "\n" );
							for (var i:int = 0; i < lines.length; i++)
							{
								descriptions.push(
										(i == 0 ? "[" + packageDef.packageDef.identifier + "]: " : linePadding) +
										lines[ i ]
								);
							}
						}
					}
				}
			}
			
			var description:String = "";
			for each (var d:String in descriptions)
			{
				description += "\n" + linePrefix + d;
			}
			
			APM.io.writeLine( description, IOColour.LIGHT_BLUE );
			APM.io.writeValue( param.name, param.value + (param.required ? " (required)" : "") );
		}
		
	}
	
}
