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
	import com.apm.client.APMCore;
	import com.apm.client.commands.Command;
	import com.apm.client.logging.Log;
	import com.apm.data.user.UserSettings;
	
	import flash.filesystem.File;
	
	
	public class ConfigCommand implements Command
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
		
		
		public function execute( core:APMCore ):void
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
								core.usage( name );
								return core.exit( APMCore.CODE_ERROR );
							}
							
							var set_param:String = _parameters[ ++i ];
							var set_value:String = _parameters.slice( ++i ).join( " " );
							
							switch (set_param)
							{
								case "publisher_token":
								{
									core.config.user.publisherToken = set_value;
									break;
								}
								case "github_token":
								{
									core.config.user.githubToken = set_value;
									break;
								}
								case "disable_terminal_control_sequences":
								{
									core.config.user.disableTerminalControlSequences = (set_value == "true" || set_value == "1");
									break;
								}
							}
							core.config.user.save();
							return core.exit( APMCore.CODE_OK );
							break;
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
										value = core.config.user.publisherToken;
										break;
									}
									case "github_token":
									{
										value = core.config.user.githubToken;
										break;
									}
									case "disable_terminal_control_sequences":
									{
										value = core.config.user.disableTerminalControlSequences ? "true" : "false";
										break;
									}
								}
								
								core.io.writeLine( param + "=" + (value == null ? "null" : value) );
								return core.exit( APMCore.CODE_OK );
							}
							else
							{
								core.usage( name );
								return core.exit( APMCore.CODE_ERROR );
							}
							break;
						}
					}
				}
				
				core.exit( APMCore.CODE_OK );
			}
			catch (e:Error)
			{
				core.io.error( e );
				core.exit( APMCore.CODE_ERROR );
			}
		}
		
		
	}
	
	
}
