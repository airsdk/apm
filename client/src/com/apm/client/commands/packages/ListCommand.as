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
 * @created		18/5/2021
 */
package com.apm.client.commands.packages
{
	import com.apm.client.APM;
	import com.apm.client.commands.Command;
	import com.apm.client.events.CommandEvent;
	import com.apm.data.project.ProjectDefinition;

	import flash.events.EventDispatcher;

	public class ListCommand extends EventDispatcher implements Command
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


		public function get requiresProject():Boolean
		{
			return true;
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


		public function execute():void
		{
			var project:ProjectDefinition = APM.config.projectDefinition;
			if (project == null)
			{
				APM.io.writeLine( "ERROR: project definition not found" );
				dispatchEvent( new CommandEvent( CommandEvent.COMPLETE, APM.CODE_ERROR ) );
				return;
			}

			APM.io.writeLine( project.getApplicationId( APM.config.buildType ) + "@" + project.getVersion( APM.config.buildType ) + " " + APM.config.workingDirectory + "" );
			if (project.dependencies.length == 0)
			{
				APM.io.writeLine( "└── (empty)" );
			}
			else
			{
				for (var i:int = 0; i < project.dependencies.length; i++)
				{
					APM.io.writeLine(
							(i == project.dependencies.length - 1 ? "└──" : "├──") +
							project.dependencies[i].toString() );
				}
			}
			dispatchEvent( new CommandEvent( CommandEvent.COMPLETE, APM.CODE_OK ) );

		}

	}

}
