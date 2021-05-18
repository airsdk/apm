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
	import com.apm.client.commands.HelpCommand;
	import com.apm.client.commands.InstallCommand;
	import com.apm.client.commands.SearchCommand;
	
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
		
		private var _arguments:Array;
		private var _workingDir:String;
		private var _command:Command;
		
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function APMCore()
		{
			addCommand( InstallCommand.NAME, InstallCommand );
			addCommand( SearchCommand.NAME, SearchCommand );
			addCommand( HelpCommand.NAME, HelpCommand );
		}
		
		
		public function main( arguments:Array ):int
		{
			try
			{
				_arguments = arguments;
				if (_arguments.length == 0)
				{
					usage();
					return CODE_ERROR;
				}
				
				for (var i:int = 0; i < arguments.length; i++)
				{
					var arg:String = arguments[ i ];
					switch (arg)
					{
						case "-workingdir":
						{
							_workingDir = arguments[ ++i ];
							break;
						}
						
						case "-k":
						{
							break;
						}
						
						default:
						{
							// Check for command
							var CommandClass:Class = getCommand( arg );
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
				return CODE_ERROR;
			}
			
			
			if (_command == null)
			{
				usage();
				return CODE_ERROR;
			}
			
			
			try
			{
				_command.execute( this );
			}
			catch (e:Error)
			{
				IO.error( e );
				return CODE_ERROR;
			}

//			var projectFile:File = new File( _workingDir + File.separator + "project.apm" );
//
//			var project:ProjectDefinition = new ProjectDefinition()
//					.load( projectFile );
//
//			var projectFileOut:File = new File( _workingDir + File.separator + "project.apm.out" );
//			project.save( projectFileOut );
			
			return CODE_OK;
		}
		
		
		private var _commandMap:Object;
		
		
		private function addCommand( name:String, commandClass:Class ):void
		{
			if (_commandMap == null) _commandMap = {};
			_commandMap[ name ] = commandClass;
		}
		
		
		private function getCommand( name:String ):Class
		{
			if (_commandMap != null && _commandMap.hasOwnProperty( name ))
			{
				return _commandMap[ name ];
			}
			return null;
		}
		
		
		public function usage( usageForCommand:String = null ):void
		{
			if (usageForCommand != null && _commandMap.hasOwnProperty(usageForCommand))
			{
				var command:Command = new _commandMap[ usageForCommand ]();
				if (command != null)
				{
					IO.out( "apm " + command.name + "\n" );
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
		
	}
}
