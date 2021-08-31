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
package com.apm.client.commands.project
{
	import com.apm.client.APM;
	import com.apm.client.commands.Command;
	import com.apm.client.events.CommandEvent;
	import com.apm.client.logging.Log;
	
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
					"apm project config set <param> <value>    Sets a <param> configuration parameter to the specified <value> \n" +
					"apm project config get <param>            Prints the configuration parameter value for the <param> parameter \n" +
					"apm project config                        Prints all configuration parameters \n";
		}
		
		
		public function execute():void
		{
			Log.d( TAG, "execute(): " + (_parameters.length > 0 ? _parameters[ 0 ] : "...") + "\n" );
			try
			{
				for (var i:int = 0; i < _parameters.length; i++)
				{
					var arg:String = _parameters[ i ];
					switch (arg)
					{
						case "set":
						{
							if (_parameters.length < 3)
							{
								dispatchEvent( new CommandEvent( CommandEvent.PRINT_USAGE, name ));
								dispatchEvent( new CommandEvent( CommandEvent.COMPLETE, APM.CODE_ERROR ));
								return;
							}
							
							var set_param:String = _parameters[ ++i ];
							var set_value:String = _parameters.slice( ++i ).join(" ");
							
							APM.config.projectDefinition.setConfigurationParam( set_param, set_value );
							APM.config.projectDefinition.save();
							dispatchEvent( new CommandEvent( CommandEvent.COMPLETE, APM.CODE_OK ));
							return;
							break;
						}
						
						case "get":
						{
							if (_parameters.length >= 2)
							{
								var param:String = _parameters[ ++i ];
								var value:String = APM.config.projectDefinition.getConfigurationParam( param );
								APM.io.writeLine( param + "=" + (value == null ? "null" : value) );
								dispatchEvent( new CommandEvent( CommandEvent.COMPLETE, APM.CODE_OK ));
								return;
							}
							else
							{
								dispatchEvent( new CommandEvent( CommandEvent.PRINT_USAGE, name ));
								dispatchEvent( new CommandEvent( CommandEvent.COMPLETE, APM.CODE_ERROR ));
								return;
							}
							break;
						}
					}
				}

				// print all config
				for (var key:String in APM.config.projectDefinition.configuration)
				{
					APM.io.writeLine( key + "=" + APM.config.projectDefinition.getConfigurationParam( key ) );
				}
				dispatchEvent( new CommandEvent( CommandEvent.COMPLETE, APM.CODE_OK ));
			}
			catch (e:Error)
			{
				APM.io.error( e );
				dispatchEvent( new CommandEvent( CommandEvent.COMPLETE, APM.CODE_ERROR ));
			}
		}
		
		
	}
	
	
}
