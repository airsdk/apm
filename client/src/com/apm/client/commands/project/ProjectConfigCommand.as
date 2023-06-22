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
package com.apm.client.commands.project
{
	import com.apm.client.APM;
	import com.apm.client.commands.Command;
	import com.apm.client.commands.project.processes.ProjectConfigDescribeProcess;
	import com.apm.client.commands.project.processes.ProjectConfigGetProcess;
	import com.apm.client.commands.project.processes.ProjectConfigSetProcess;
	import com.apm.client.commands.project.processes.ValidatePackageCacheProcess;
	import com.apm.client.events.CommandEvent;
	import com.apm.client.logging.Log;
	import com.apm.client.processes.ProcessQueue;
	
	import flash.events.EventDispatcher;
	
	
	public class ProjectConfigCommand extends EventDispatcher implements Command
	{
		
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "ProjectConfigCommand";
		
		
		public static const NAME:String = "project/config";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _parameters:Array;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function ProjectConfigCommand()
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
			return "controls the configuration parameters saved in the project definition";
		}
		
		
		public function get usage():String
		{
			return description + "\n" +
				   "\n" +
				   "apm project config                        Prints all configuration parameters \n" +
				   "apm project config set <param> <value>    Sets a <param> configuration parameter to the specified <value> \n" +
				   "apm project config set <param>            Asks for input to set the value for the <param> configuration parameter \n" +
				   "apm project config set <identifier>       Asks for input to set the values for all the <identifier> package parameters \n" +
				   "apm project config set                    Asks for input to set the values for all the project parameters \n" +
				   "apm project config get <param>            Prints the configuration parameter value for the <param> parameter \n" +
				   "apm project config describe               Prints the description for all the project parameters \n" +
				   "apm project config describe <param>       Prints the description for the <param> parameter \n" +
				   "apm project config describe <identifier>  Prints the description for all the <identifier> package parameters \n"
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
					var subCommand:String = _parameters[ 0 ];
					switch (subCommand)
					{
						case "set":
						{
//							if (_parameters.length < 2)
//							{
//								dispatchEvent( new CommandEvent( CommandEvent.PRINT_USAGE, name ) );
//								dispatchEvent( new CommandEvent( CommandEvent.COMPLETE, APM.CODE_ERROR ) );
//								return;
//							}
							
							queue.addProcess( new ProjectConfigSetProcess(
									_parameters.length < 2 ? null : _parameters[ 1 ],
									_parameters.length < 3 ? null : _parameters.slice( 2 ).join( " " )
							) );
							
							break;
						}
						
						case "get":
						{
							if (_parameters.length < 2)
							{
								queue.addProcess( new ProjectConfigGetProcess( null ) );
							}
							else
							{
								queue.addProcess( new ProjectConfigGetProcess( _parameters[ 1 ] ) );
							}
							break;
						}
						
						case "describe":
						{
							// This uses package cache to read package parameters from package definitions
							queue.addProcess( new ValidatePackageCacheProcess() );
							
							if (_parameters.length < 2)
							{
								queue.addProcess( new ProjectConfigDescribeProcess( null ) );
							}
							else
							{
								queue.addProcess( new ProjectConfigDescribeProcess( _parameters[ 1 ] ) );
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
					queue.addProcess( new ProjectConfigGetProcess( null ) );
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
