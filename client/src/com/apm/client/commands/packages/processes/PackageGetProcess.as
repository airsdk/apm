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
 * @author 		Michael Archbold (https://github.com/marchbold)
 * @created		22/6/2023
 */
package com.apm.client.commands.packages.processes
{
	import com.apm.client.APM;
	import com.apm.client.processes.ProcessBase;
	import com.apm.data.packages.PackageDefinitionFile;

	import flash.filesystem.File;

	public class PackageGetProcess extends ProcessBase
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//

		private static const TAG:String = "PackageGetProcess";


		////////////////////////////////////////////////////////
		//  VARIABLES
		//

		private var _paramName:String;


		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//

		public function PackageGetProcess( paramName:String )
		{
			_paramName = paramName;
		}


		override public function start( completeCallback:Function = null, failureCallback:Function = null ):void
		{
			super.start( completeCallback, failureCallback );

			var packageDir:File = new File( APM.config.workingDirectory );
			var packageFile:File = packageDir.resolvePath( PackageDefinitionFile.DEFAULT_FILENAME );
			if (!packageFile.exists)
			{
				failure( "No package definition file found" );
				return;
			}

			var packageDefinitionFile:PackageDefinitionFile = new PackageDefinitionFile().load( packageFile );

			if (_paramName == null)
			{
				// print all config
				APM.io.writeLine( packageDefinitionFile.packageDef.identifier +
										  "[" + packageDefinitionFile.packageDef.type + "]"
										  + "@" + packageDefinitionFile.version.version.toString() );

				writeParam( packageDefinitionFile, "identifier" );
				writeParam( packageDefinitionFile, "type" );
				writeParam( packageDefinitionFile, "name" );
				writeParam( packageDefinitionFile, "version" );
				writeParam( packageDefinitionFile, "url" );
				writeParam( packageDefinitionFile, "docUrl" );
				APM.io.writeLine( "" );
				writeParam( packageDefinitionFile, "dependencies" );
				APM.io.writeLine( "" );
				writeParam( packageDefinitionFile, "tags" );
				APM.io.writeLine( "" );
				writeParam( packageDefinitionFile, "platforms" );

			}
			else
			{
				writeParam( packageDefinitionFile, _paramName );
			}

			complete();
		}

		private function writeParam( packageDefinitionFile:PackageDefinitionFile, paramName:String ):void
		{
			switch (paramName)
			{
				case "id":
				case "identifier":
				{
					APM.io.writeValue( "identifier", packageDefinitionFile.packageDef.identifier );
					break;
				}

				case "name":
				{
					APM.io.writeValue( "name", packageDefinitionFile.packageDef.name );
					break;
				}

				case "version":
				{
					APM.io.writeValue( "version", packageDefinitionFile.version.version.toString() );
					break;
				}

				case "url":
				{
					APM.io.writeValue( "url", packageDefinitionFile.packageDef.url );
					break;
				}

				case "docUrl":
				{
					APM.io.writeValue( "docUrl", packageDefinitionFile.packageDef.docUrl );
					break;
				}

				case "type":
				{
					APM.io.writeValue( "type", packageDefinitionFile.packageDef.type );
					break;
				}

				case "platforms":
				{
					APM.io.writeLine( "platforms" );
					if (packageDefinitionFile.version.platforms.length == 0)
					{
						APM.io.writeLine( "└── (all)" );
					}
					else
					{
						for (var p:int = 0; p < packageDefinitionFile.version.platforms.length; p++)
						{
							APM.io.writeLine(
									(p == packageDefinitionFile.version.platforms.length - 1 ? "└──" : "├──") +
									packageDefinitionFile.version.platforms[p].toString() );
						}
					}
					break;
				}

				case "dependencies":
				{
					APM.io.writeLine( "" );
					APM.io.writeLine( "dependencies" );
					if (packageDefinitionFile.dependencies.length == 0)
					{
						APM.io.writeLine( "└── (none)" );
					}
					else
					{
						for (var d:int = 0; d < packageDefinitionFile.dependencies.length; d++)
						{
							APM.io.writeLine(
									(d == packageDefinitionFile.dependencies.length - 1 ? "└──" : "├──") +
									packageDefinitionFile.dependencies[d].toString() );
						}
					}
					break;
				}

				case "tags":
				{
					APM.io.writeLine( "tags" );
					if (packageDefinitionFile.packageDef.tags.length == 0)
					{
						APM.io.writeLine( "└── (none)" );
					}
					else
					{
						for (var t:int = 0; t < packageDefinitionFile.packageDef.tags.length; t++)
						{
							APM.io.writeLine(
									(t == packageDefinitionFile.packageDef.tags.length - 1 ? "└──" : "├──") +
									packageDefinitionFile.packageDef.tags[t].toString() );
						}
					}
					break;
				}

				default:
				{
					APM.io.writeError( "parameter", "not found" );
					break;
				}
			}
		}

	}

}
