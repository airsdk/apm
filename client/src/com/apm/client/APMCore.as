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
package com.apm.client
{
	import com.apm.SemVer;
	import com.apm.client.commands.Command;
	import com.apm.client.commands.general.HelpCommand;
	import com.apm.client.commands.general.VersionCommand;
	import com.apm.client.commands.packages.InstallCommand;
	import com.apm.client.commands.packages.SearchCommand;
	import com.apm.client.commands.project.InitCommand;
	import com.apm.client.commands.project.ProjectConfigCommand;
	import com.apm.client.config.RunConfig;
	import com.apm.client.logging.Log;
	
	import flash.desktop.NativeApplication;
	import flash.display.Sprite;
	
	
	public class APMCore extends Sprite
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "APMCore";
		
		public static const CODE_OK:int = 0;
		public static const CODE_ERROR:int = 1;
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _instance:APMCore;
		private var _arguments:Array;
		private var _command:Command;
		
		private var _config:RunConfig;
		
		public function get config():RunConfig { return _config; }
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function APMCore()
		{
			_instance = this;
			_config = new RunConfig();
			
			addCommand( InstallCommand.NAME, InstallCommand );
			addCommand( SearchCommand.NAME, SearchCommand );
			addCommand( HelpCommand.NAME, HelpCommand );
			addCommand( VersionCommand.NAME, VersionCommand );
			addCommand( InitCommand.NAME, InitCommand );
			addCommand( ProjectConfigCommand.NAME, ProjectConfigCommand );
		}
		
		
		public function main( arguments:Array ):void
		{
			try
			{
				_arguments = arguments;
				if (_arguments.length == 0)
				{
					usage();
					return exit( CODE_ERROR );
				}
				
				for (var i:int = 0; i < arguments.length; i++)
				{
					var arg:String = arguments[ i ];
					switch (arg)
					{
						case "-workingdir":
						{
							_config.workingDir = arguments[ ++i ];
							break;
						}
						
						case "-v":
						case "-version":
						{
							// PRINT VERSION
							IO.writeLine( new SemVer( Consts.VERSION ).toString() );
							return exit( CODE_OK );
						}
						
						case "-loglevel":
						case "-l":
						{
							var level:String = arguments[ ++i ];
							switch (level)
							{
								case "v":
								case "verbose":
									Log.setLogLevel( Log.LEVEL_VERBOSE );
									break;
								
								case "d":
								case "debug":
									Log.setLogLevel( Log.LEVEL_DEBUG );
									break;
								
								default:
									Log.setLogLevel( Log.LEVEL_NORMAL );
									break;
							}
							break;
						}
						
						default:
						{
							// Check for command
							var CommandClass:Class = getCommand( arg );
							if (CommandClass == null && i + 1 < arguments.length)
							{
								CommandClass = getCommand( arg + "/" + arguments[ i + 1 ] )
								if (CommandClass != null) i++;
							}
							
							if (CommandClass != null)
							{
								_command = new CommandClass();
								if (i < arguments.length - 1)
								{
									_command.setParameters( arguments.slice( i + 1 ) );
								}
								i = arguments.length;
								break;
							}
							else
							{
								throw new Error( "Unknown command: " + arg );
							}
						}
					}
				}
				
			}
			catch (e:Error)
			{
				IO.error( e );
				return exit( CODE_ERROR );
			}
			
			
			if (_command == null)
			{
				usage();
				return exit( CODE_ERROR );
			}
			
			try
			{
				_config.loadEnvironment( function ():void {
					_command.execute( _instance );
				} );
			}
			catch (e:Error)
			{
				IO.error( e );
				return exit( CODE_ERROR );
			}
			
		}
		
		
		//
		//	COMMAND HANDLING
		//
		
		private var _commandMap:Object;
		
		
		private function addCommand( name:String, commandClass:Class ):void
		{
			if (_commandMap == null) _commandMap = {};
			_commandMap[ name ] = commandClass;
		}
		
		
		private function getCommand( name:String ):Class
		{
			if (_commandMap != null && _commandMap[ name ] != null)
			{
				return _commandMap[ name ];
			}
			return null;
		}
		
		
		//
		//	PROCESS HANDLING
		//
		
		
		public function usage( usageForCommand:String = null ):void
		{
			if (usageForCommand != null && _commandMap.hasOwnProperty( usageForCommand ))
			{
				var command:Command = new _commandMap[ usageForCommand ]();
				if (command != null)
				{
					IO.out( "apm " + command.name.replace( "/", " " ) + "\n" );
					IO.out( "\n" );
					IO.out( command.usage );
					return;
				}
			}
			
			IO.out( "apm <command>\n" );
			IO.out( "\n" );
			IO.out( "Usage:\n" );
			IO.out( "\n" );
			
			for (var commandName:String in _commandMap)
			{
				var command:Command = new _commandMap[ commandName ]();
				var commandUsage:String = "apm " + commandName + " ";
				while (commandUsage.length < 20) commandUsage += " ";
				commandUsage += command.description + "\n";
				IO.out( commandUsage );
			}
		}
		
		
		/**
		 * This is called on the end of the process
		 *
		 * @param returnCode	Success or failure of the command
		 */
		public function exit( returnCode:int = CODE_OK ):void
		{
			NativeApplication.nativeApplication.exit( returnCode );
		}
		
		
	}
}
