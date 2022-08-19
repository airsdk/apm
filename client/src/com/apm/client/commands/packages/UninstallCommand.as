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
	import com.apm.client.APM;
	import com.apm.client.analytics.Analytics;
	import com.apm.client.commands.Command;
	import com.apm.client.commands.packages.processes.UninstallPackageProcess;
	import com.apm.client.events.CommandEvent;
	import com.apm.client.processes.ProcessQueue;
	import com.apm.data.packages.PackageDependency;
	import com.apm.data.project.ProjectDefinition;

	import flash.events.EventDispatcher;

	public class UninstallCommand extends EventDispatcher implements Command
	{

		////////////////////////////////////////////////////////
		//  CONSTANTS
		//

		private static const TAG:String = "UninstallCommand";


		public static const NAME:String = "uninstall";


		////////////////////////////////////////////////////////
		//  VARIABLES
		//

		private var _parameters:Array;
		private var _queue:ProcessQueue;
		private var _packageDependency:PackageDependency;

		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//

		public function UninstallCommand()
		{
			super();
			_queue = new ProcessQueue();
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
			return "remove a dependency from your project";
		}


		public function get usage():String
		{
			return description + "\n" +
					"\n" +
					"apm uninstall <foo>            uninstall the <foo> dependency from your project\n" +
					"apm uninstall <foo> <out.xml>  uninstall the <foo> dependency from your project and remove it from the specified application descriptor\n"
					;
		}


		public function execute():void
		{
			var project:ProjectDefinition = APM.config.projectDefinition;
			if (project == null)
			{
				dispatchEvent( new CommandEvent( CommandEvent.COMPLETE, APM.CODE_ERROR ) );
				return;
			}

			if (_parameters != null && _parameters.length > 0)
			{
				var packageIdentifier:String = _parameters[0];
				var appDescriptorPath:String = (_parameters.length > 1 ? _parameters[1] : null);

				_packageDependency = project.getPackageDependency( packageIdentifier );
				if (_packageDependency != null)
				{
					_queue.addProcess( new UninstallPackageProcess( packageIdentifier,
																	packageIdentifier,
																	appDescriptorPath ) );
				}
			}

			if (_queue.length == 0)
			{
				APM.io.writeLine( "Nothing to uninstall" );
				dispatchEvent( new CommandEvent( CommandEvent.COMPLETE, APM.CODE_OK ) );
				return;
			}


			_queue.start(
					function ():void
					{

						APM.config.projectDefinition.save();

						if (APM.config.projectLock != null)
						{
							APM.config.projectLock.save();
						}

						Analytics.instance.uninstall( _packageDependency.identifier,
													  _packageDependency.version.toString(),
													  _packageDependency.source,
													  function ():void
													  {
														  dispatchEvent( new CommandEvent( CommandEvent.COMPLETE,
																						   APM.CODE_OK ) );
													  } );
					},
					function ( error:String ):void
					{
						dispatchEvent( new CommandEvent( CommandEvent.COMPLETE, APM.CODE_ERROR ) );
					} );

		}

	}

}
