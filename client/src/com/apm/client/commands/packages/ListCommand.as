/**
 * @author 		Michael Archbold (https://michaelarchbold.com)
 * @created		18/5/2021
 */
package com.apm.client.commands.packages
{
	import com.apm.client.APM;
	import com.apm.client.commands.Command;
	import com.apm.client.io.utils.ListOutput;
	import com.apm.client.events.CommandEvent;
	import com.apm.data.install.InstallPackageData;
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
			return "lists packages currently added to your project";
		}


		public function get usage():String
		{
			return description + "\n" +
					"\n" +
					"apm list          list all the packages in your project\n" +
					"\n" +
					"options: \n" +
					"  --dependencies(--deps)  include package dependencies in the list\n" +
					"                          (default will only list the project installed packages)\n"
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

			var includeDependencies:Boolean = false;
			if (_parameters != null)
			{
				for each (var param:String in _parameters)
				{
					if (param == "--dependencies" || param == "--deps" || param == "--all")
					{
						includeDependencies = true;
					}
				}
			}

			APM.io.writeLine( project.getApplicationId( APM.config.buildType ) + "@" + project.getVersion( APM.config.buildType ) + " " + APM.config.workingDirectory + "" );
			if (project.dependencies.length == 0)
			{
				APM.io.writeLine( ListOutput.marker() + "(empty)" );
			}
			else
			{
				if (includeDependencies)
				{
					if (APM.config.projectLock == null)
					{
						APM.io.writeLine( "ERROR: project lock not found, run 'apm install' first" );
						dispatchEvent( new CommandEvent( CommandEvent.COMPLETE, APM.CODE_ERROR ) );
						return;
					}

					var allDependencies:Vector.<InstallPackageData> = APM.config.projectLock.dependencies;
					for (var j:int = 0; j < allDependencies.length; j++)
					{
						var installData:InstallPackageData = allDependencies[j];
						APM.io.writeLine(
								ListOutput.marker(j == allDependencies.length - 1 ) +
								installData.packageVersion.toStringWithIdentifier()
						);
					}
				}
				else
				{
					for (var i:int = 0; i < project.dependencies.length; i++)
					{
						APM.io.writeLine(
								ListOutput.marker(i == project.dependencies.length - 1 ) +
								project.dependencies[i].toString() );
					}
				}
			}

			dispatchEvent( new CommandEvent( CommandEvent.COMPLETE, APM.CODE_OK ) );

		}

	}

}
