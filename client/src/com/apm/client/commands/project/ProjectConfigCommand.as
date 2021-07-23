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
	import com.apm.client.APMCore;
	import com.apm.client.commands.Command;
	import com.apm.client.logging.Log;
	
	
	public class ProjectConfigCommand implements Command
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
							var set_value:String = _parameters.slice( ++i ).join(" ");
							
							core.config.projectDefinition.setConfigurationParam( set_param, set_value );
							core.config.projectDefinition.save();
							return core.exit( APMCore.CODE_OK );
							break;
						}
						
						case "get":
						{
							if (_parameters.length >= 2)
							{
								var param:String = _parameters[ ++i ];
								var value:String = core.config.projectDefinition.getConfigurationParam( param );
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

				// print all config
				for (var key:String in core.config.projectDefinition.configuration)
				{
					core.io.writeLine( key + "=" + core.config.projectDefinition.getConfigurationParam( key ) );
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
