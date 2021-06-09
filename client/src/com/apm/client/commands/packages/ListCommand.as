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
 * @created		18/5/21
 */
package com.apm.client.commands.packages
{
	import com.apm.client.APMCore;
	import com.apm.client.commands.Command;
	import com.apm.data.Dependency;
	import com.apm.data.ProjectDefinition;
	
	
	public class ListCommand implements Command
	{
		
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "ListCommand";
		
		
		public static const NAME:String = "list";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _parameters:Array;
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function ListCommand()
		{
			super();
		}
		
		
		public function setParameters( parameters:Array ):void
		{
			_parameters = parameters;
		}
		
		
		public function get name():String
		{
			return NAME;
		}
		
		
		public function get category():String
		{
			return "";
		}
		
		
		public function get requiresNetwork():Boolean
		{
			return false;
		}
		
		
		public function get description():String
		{
			return "lists dependencies currently added to your project";
		}
		
		
		public function get usage():String
		{
			return description + "\n" +
					"\n" +
					"apm list          list all the dependencies in your project\n"
		}
		
		
		public function execute( core:APMCore ):void
		{
			var project:ProjectDefinition = core.config.projectDefinition;
			if (project == null)
			{
				core.io.writeLine( "ERROR: project definition not found" );
				return core.exit( APMCore.CODE_ERROR );
			}
			
			core.io.writeLine( project.applicationName + "@" + project.version + " " + core.config.workingDir + "" );
			if (project.dependencies.length == 0)
			{
				core.io.writeLine( "└── (empty)" );
			}
			else
			{
				for (var i:int = 0; i < project.dependencies.length; i++)
				{
					core.io.writeLine(
							(i == project.dependencies.length - 1 ? "└──" : "├──")+
							project.dependencies[i].toString() );
				}
			}
			return core.exit( APMCore.CODE_OK );
		}
		
	}
	
}
