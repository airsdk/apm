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
package com.apm.client.commands.packages
{
	import com.apm.client.APMCore;
	import com.apm.client.commands.Command;
	import com.apm.data.packages.PackageDefinition;
	import com.apm.remote.repository.RepositoryAPI;
	
	
	public class SearchCommand implements Command
	{
		
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "SearchCommand";
		
		
		public static const NAME:String = "search";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _repositoryAPI:RepositoryAPI;
		private var _parameters:Array;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function SearchCommand()
		{
			super();
			_repositoryAPI = new RepositoryAPI();
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
					"apm search <foo>    search for a package containing <foo> in the repository\n";
		}
		
		
		public function execute( core:APMCore ):void
		{
			if (_parameters == null || _parameters.length == 0)
			{
				core.io.writeLine( "no search params provided" );
				core.usage( NAME );
				return core.exit( APMCore.CODE_ERROR );
			}
			
			var query:String = _parameters.join( " " );
			core.io.showSpinner( "Searching packages for : " + query );
			
			_repositoryAPI.search( query, function ( success:Boolean, packages:Vector.<PackageDefinition> ):void {
				core.io.stopSpinner( success, "Search complete" );
				
				if (success)
				{
					core.io.writeLine( "found [" + packages.length + "] matching package(s) for search '" + query + "'" )
					if (packages.length > 0)
					{
						for (var i:int = 0; i < packages.length; i++)
						{
							core.io.writeLine(
									(i == packages.length - 1 ? "└──" : "├──") +
									packages[ i ].toDescriptiveString()
							);
						}
					}
					else
					{
						core.io.writeLine( "└── no matching packages found" );
					}
					core.exit( APMCore.CODE_OK );
				}
				else
				{
					core.io.writeLine( "error connecting to repository server" );
					core.exit( APMCore.CODE_ERROR );
				}
			} );
		}
		
	}
	
}
