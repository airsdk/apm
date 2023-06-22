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
package com.apm.client.commands.packages
{
	import com.apm.client.APM;
	import com.apm.client.commands.Command;
	import com.apm.client.events.CommandEvent;
	import com.apm.client.repositories.PackageResolver;
	import com.apm.data.packages.PackageDefinition;
	
	import flash.events.EventDispatcher;
	
	
	public class SearchCommand extends EventDispatcher implements Command
	{
		
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "SearchCommand";
		
		
		public static const NAME:String = "search";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _parameters:Array;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function SearchCommand()
		{
			super();
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
			return true;
		}
		
		
		public function get requiresProject():Boolean
		{
			return false;
		}
		
		
		public function get description():String
		{
			return "search for a dependency in the repository";
		}
		
		
		public function get usage():String
		{
			return description + "\n" +
				   "\n" +
				   "apm search <foo>         search for a package containing <foo> in the repository\n" +
				   "\n" +
				   "options: \n" +
				   "  --include-prerelease   includes pre-release package versions in the search"
			;
		}
		
		
		public function execute():void
		{
			if (_parameters == null || _parameters.length == 0)
			{
				APM.io.writeLine( "no search params provided" );
				dispatchEvent( new CommandEvent( CommandEvent.PRINT_USAGE, NAME ) );
				dispatchEvent( new CommandEvent( CommandEvent.COMPLETE, APM.CODE_ERROR ) );
				return;
			}
			
			var query:String = _parameters.join( " " );
			
			APM.io.showSpinner( "Searching packages for : " + query );
			
			PackageResolver.instance.search(
					query,
					null,
					function ( success:Boolean, packages:Vector.<PackageDefinition> ):void
					{
						APM.io.stopSpinner( success, "Search complete" );
						
						if (success)
						{
							APM.io.writeLine( "found [" + packages.length + "] matching package(s) for search '" + query + "'" )
							if (packages.length > 0)
							{
								for (var i:int = 0; i < packages.length; i++)
								{
									APM.io.writeLine(
											(i == packages.length - 1 ? "└──" : "├──") +
											packages[ i ].toDescriptiveString()
									);
								}
							}
							else
							{
								APM.io.writeLine( "└── no matching packages found" );
							}
							dispatchEvent( new CommandEvent( CommandEvent.COMPLETE, APM.CODE_OK ) );
						}
						else
						{
							APM.io.writeLine( "error connecting to repository server" );
							dispatchEvent( new CommandEvent( CommandEvent.COMPLETE, APM.CODE_ERROR ) );
						}
					}
			);
		}
		
	}
	
}
