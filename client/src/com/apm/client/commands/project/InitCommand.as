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
	import com.apm.client.IO;
	import com.apm.client.commands.Command;
	import com.apm.client.logging.Log;
	import com.apm.data.ProjectDefinition;
	
	import flash.filesystem.File;
	
	
	public class InitCommand implements Command
	{
		
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "InitCommand";
		
		
		public static const NAME:String = "init";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _parameters:Array;
		
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function InitCommand()
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
		
		
		public function get description():String
		{
			return "initialise a new apm project file for your application";
		}
		
		
		public function get usage():String
		{
			return description + "\n" +
					"\n" +
					"apm init          initialise a new apm project file for your application\n"
		}
		
		
		public function execute( core:APMCore ):void
		{
			Log.d( TAG, "execute(): " + (_parameters.length > 0 ? _parameters[ 0 ] : "...") + "\n" );
			try
			{
				if (core.config.projectDefinition != null)
				{
					core.io.writeLine( "Already have a config file " );
					
					var response:String = core.io.question( "Overwrite? Y/n", "n" )
					if (response.toLowerCase() != "y")
					{
						return core.exit( APMCore.CODE_ERROR );
					}
				}
				
				core.io.writeLine( "Creating new project definition file" );
				
				var project:ProjectDefinition = new ProjectDefinition();
				
				//
				//	Walk through any questions
				
				project.applicationId = core.io.question( "Application Identifier", "com.my.app")
				project.applicationName = core.io.question( "Application Name", "My Application")
				project.version = core.io.question( "Application Consts", "1.0.0" )
	
				// TODO
			
			
				var projectFile:File = new File( core.config.workingDir + File.separator + ProjectDefinition.DEFAULT_FILENAME );
				project.save( projectFile );
				
				core.exit( APMCore.CODE_OK );
			}
			catch (e:Error)
			{
				core.io.error( e );
			}
		}

		
		
	}
	
	
}
