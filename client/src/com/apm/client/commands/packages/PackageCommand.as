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
 * @created		22/6/2023
 */
package com.apm.client.commands.packages
{
	import com.apm.client.APM;
	import com.apm.client.commands.Command;
	import com.apm.client.commands.packages.processes.PackageGetProcess;
	import com.apm.client.commands.packages.processes.PackageSetProcess;
	import com.apm.client.events.CommandEvent;
	import com.apm.client.logging.Log;
	import com.apm.client.processes.ProcessQueue;

	import flash.events.EventDispatcher;

	public class PackageCommand extends EventDispatcher implements Command
	{

		////////////////////////////////////////////////////////
		//  CONSTANTS
		//

		private static const TAG:String = "PackageCommand";

		public static const NAME:String = "package";


		////////////////////////////////////////////////////////
		//  VARIABLES
		//

		private var _parameters:Array;


		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//

		public function PackageCommand()
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
			return false;
		}


		public function get description():String
		{
			return "set a package parameter in a package under construction";
		}


		public function get usage():String
		{
			return description + "\n" +
					"\n" +
					"apm package set <param> <value>    set a package parameter (there must be a package.json in the working dir)\n";
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

							queue.addProcess( new PackageSetProcess(
									_parameters.length < 2 ? null : _parameters[1],
									_parameters.length < 3 ? null : _parameters.slice( 2 ).join( " " )
							) );

							break
						}

						case "get":
						{
							if (_parameters.length < 2)
							{
								queue.addProcess( new PackageGetProcess( null ) );
							}
							else
							{
								queue.addProcess( new PackageGetProcess( _parameters[1] ) );
							}
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
					queue.addProcess( new PackageGetProcess( null ) );
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
