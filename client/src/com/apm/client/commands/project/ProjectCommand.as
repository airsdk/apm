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
 * @author 		Michael Archbold (https://github.com/marchbold)
 * @created		24/2/2023
 */
package com.apm.client.commands.project
{
	import com.apm.client.APM;
	import com.apm.client.commands.Command;
	import com.apm.client.commands.project.processes.ProjectAddProcess;
	import com.apm.client.commands.project.processes.ProjectGetProcess;
	import com.apm.client.commands.project.processes.ProjectSetProcess;
	import com.apm.client.events.CommandEvent;
	import com.apm.client.logging.Log;
	import com.apm.client.processes.ProcessQueue;

	import flash.events.EventDispatcher;

	public class ProjectCommand extends EventDispatcher implements Command
	{

		////////////////////////////////////////////////////////
		//  CONSTANTS
		//

		private static const TAG:String = "ProjectCommand";

		public static const NAME:String = "project";


		////////////////////////////////////////////////////////
		//  VARIABLES
		//

		private var _parameters:Array;


		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//

		public function ProjectCommand()
		{
			super();
			_parameters = [];
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
			return "controls the project parameters saved in the project definition";
		}


		public function get usage():String
		{
			return description + "\n" +
					"\n" +
					"apm project                        Prints all project parameters \n" +
					"apm project get <param>            Prints the project parameter value for the <param> parameter \n" +
					"apm project set <param> <value>    Sets a <param> project parameter to the specified <value> \n" +
					"apm project set <param>            Asks for input to set the value for the <param> project parameter \n" +
					"apm project add <param> <value>    Adds the <value> to the specified <param> project parameter array \n" +
					"apm project add <param>            Asks for input to add a value to the <param> project parameter array \n"
					;
		}


		public function execute():void
		{
			Log.d( TAG, "execute(): [" + (_parameters.length > 0 ? _parameters.join( " " ) : " ") + "]\n" );
			try
			{
				var queue:ProcessQueue = new ProcessQueue();

				if (_parameters.length > 0)
				{
					var subCommand:String = _parameters[0];
					switch (subCommand)
					{
						case "set":
						{
							if (_parameters.length < 2)
							{
								dispatchEvent( new CommandEvent( CommandEvent.PRINT_USAGE, name ) );
								dispatchEvent( new CommandEvent( CommandEvent.COMPLETE, APM.CODE_ERROR ) );
								return;
							}

							queue.addProcess( new ProjectSetProcess(
									_parameters.length < 2 ? null : _parameters[1],
									_parameters.length < 3 ? null : _parameters.slice( 2 ).join( " " )
							) );

							break;
						}

						case "get":
						{
							if (_parameters.length < 2)
							{
								queue.addProcess( new ProjectGetProcess( null ) );
							}
							else
							{
								queue.addProcess( new ProjectGetProcess( _parameters[1] ) );
							}
							break;
						}

						case "add":
						{
							if (_parameters.length < 2)
							{
								dispatchEvent( new CommandEvent( CommandEvent.PRINT_USAGE, name ) );
								dispatchEvent( new CommandEvent( CommandEvent.COMPLETE, APM.CODE_ERROR ) );
								return;
							}

							queue.addProcess( new ProjectAddProcess(
									_parameters.length < 2 ? null : _parameters[1],
									_parameters.length < 3 ? null : _parameters.slice( 2 ).join( " " )
							) );

							break;
						}

						default:
						{
							dispatchEvent( new CommandEvent( CommandEvent.PRINT_USAGE, name ) );
							dispatchEvent( new CommandEvent( CommandEvent.COMPLETE, APM.CODE_ERROR ) );
							return;
						}
					}
				}
				else
				{
					// print all config
					queue.addProcess( new ProjectGetProcess( null ) );
				}


				queue.start(
						function ():void
						{
							dispatchEvent( new CommandEvent( CommandEvent.COMPLETE, APM.CODE_OK ) );
						},
						function ( error:String ):void
						{
							APM.io.writeError( NAME, error );
							dispatchEvent( new CommandEvent( CommandEvent.COMPLETE, APM.CODE_ERROR ) );
						}
				);

			}
			catch (e:Error)
			{
				APM.io.error( e );
				dispatchEvent( new CommandEvent( CommandEvent.COMPLETE, APM.CODE_ERROR ) );
			}
		}


	}


}
