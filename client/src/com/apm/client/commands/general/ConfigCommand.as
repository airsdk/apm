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
	import com.apm.data.user.UserSettings;
	
	import flash.events.EventDispatcher;
	
	import flash.filesystem.File;
	
	
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
					"apm config get <param>            Prints the user configuration parameter value for the <param> parameter \n";
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
							var set_value:String = _parameters.slice( ++i ).join( " " );
							
							switch (set_param)
							{
								case "publisher_token":
								{
									APM.config.user.publisherToken = set_value;
									break;
								}
								case "github_token":
								{
									APM.config.user.githubToken = set_value;
									break;
								}
								case "disable_terminal_control_sequences":
								{
									APM.config.user.disableTerminalControlSequences = (set_value == "true" || set_value == "1");
									break;
								}
							}
							APM.config.user.save();
							dispatchEvent( new CommandEvent( CommandEvent.COMPLETE, APM.CODE_OK ));
							return;
						}
						
						case "get":
						{
							if (_parameters.length >= 2)
							{
								var param:String = _parameters[ ++i ];
								var value:String = "unknown";
								
								switch (param)
								{
									case "publisher_token":
									{
										value = APM.config.user.publisherToken;
										break;
									}
									case "github_token":
									{
										value = APM.config.user.githubToken;
										break;
									}
									case "disable_terminal_control_sequences":
									{
										value = APM.config.user.disableTerminalControlSequences ? "true" : "false";
										break;
									}
								}
								
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
