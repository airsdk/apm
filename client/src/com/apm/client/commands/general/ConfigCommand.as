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
package com.apm.client.commands.general
{
	import com.apm.client.APM;
	import com.apm.client.commands.Command;
	import com.apm.client.events.CommandEvent;
	import com.apm.client.logging.Log;
	
	import flash.events.EventDispatcher;
	
	
	public class ConfigCommand extends EventDispatcher implements Command
	{
		
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "ConfigCommand";
		
		
		public static const NAME:String = "config";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _parameters:Array;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function ConfigCommand()
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
			return "controls the configuration parameters saved in the global user configuration";
		}
		
		
		public function get usage():String
		{
			return description + "\n" +
					"\n" +
					"apm config set <param> <value>    Sets a <param> user configuration parameter to the specified <value> \n" +
					"apm config get <param>            Prints the user configuration parameter value for the <param> parameter \n" +
					"apm config                        Prints all user configuration parameters \n";
		}
		
		
		public function execute():void
		{
			Log.d( TAG, "execute(): [" + (_parameters.length > 0 ? _parameters.join( " " ) : " ") + "]\n" );
			try
			{
				if (_parameters.length > 0)
				{
					var subCommand:String = _parameters[ 0 ];
					switch (subCommand)
					{
						case "set":
						{
							if (_parameters.length < 3)
							{
								dispatchEvent( new CommandEvent( CommandEvent.PRINT_USAGE, name ) );
								dispatchEvent( new CommandEvent( CommandEvent.COMPLETE, APM.CODE_ERROR ) );
								return;
							}
							
							var set_param:String = _parameters[ 1 ];
							var set_value:String = _parameters.slice( 2 ).join( " " );
							
							APM.config.user.setParamValue( set_param, set_value );
							APM.config.user.save();
							
							dispatchEvent( new CommandEvent( CommandEvent.COMPLETE, APM.CODE_OK ) );
							return;
						}
						
						case "get":
						{
							if (_parameters.length >= 2)
							{
								var get_param:String = _parameters[ 1 ];
								var get_value:String = APM.config.user.getParamValue( get_param );
								
								APM.io.writeValue( get_param, (get_value == null ? "null" : get_value) );
								
								dispatchEvent( new CommandEvent( CommandEvent.COMPLETE, APM.CODE_OK ) );
								return;
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
				
				// Print all configuration
				for each (var param:String in APM.config.user.getParamNames())
				{
					var value:String = APM.config.user.getParamValue( param );
					if (value != null)
					{
						APM.io.writeValue( param, value );
					}
				}
				dispatchEvent( new CommandEvent( CommandEvent.COMPLETE, APM.CODE_OK ) );
			}
			catch (e:Error)
			{
				APM.io.error( e );
				dispatchEvent( new CommandEvent( CommandEvent.COMPLETE, APM.CODE_ERROR ) );
			}
		}
		
	}
	
}
