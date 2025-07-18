/**
 * @author 		Michael Archbold (https://michaelarchbold.com)
 * @created		22/6/2023
 */
package com.apm.client.commands.packages.processes
{
	import com.apm.SemVer;
	import com.apm.client.APM;
	import com.apm.client.processes.ProcessBase;
	import com.apm.data.common.Platform;
	import com.apm.data.packages.PackageDefinitionFile;

	import flash.filesystem.File;

	public class PackageSetProcess extends ProcessBase
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//

		private static const TAG:String = "PackageSetProcess";


		////////////////////////////////////////////////////////
		//  VARIABLES
		//


		private var _paramName:String;
		private var _paramValue:String;


		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//

		public function PackageSetProcess( paramName:String, paramValue:String )
		{
			_paramName = paramName;
			_paramValue = paramValue;
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
				failure( "No parameter name specified" );
				return;
			}
			else if (_paramValue == null)
			{
				var value:String = APM.io.question( "Set", _paramName );
				setPackageValue( packageDefinitionFile, _paramName, value )
			}
			else
			{
				setPackageValue( packageDefinitionFile, _paramName, _paramValue )
			}
			packageDefinitionFile.save();
			complete();
		}


		private function setPackageValue( packageDefinitionFile:PackageDefinitionFile, name:String, value:String ):void
		{
			switch (_paramName)
			{
				case "id":
				case "identifier":
				{
					packageDefinitionFile.packageDef.identifier = value;
					break;
				}
				case "url":
				{
					packageDefinitionFile.packageDef.url = value;
					break;
				}
				case "docUrl":
				{
					packageDefinitionFile.packageDef.docUrl = value;
					break;
				}
				case "name":
				{
					packageDefinitionFile.packageDef.name = value;
					break;
				}
				case "type":
				{
					packageDefinitionFile.packageDef.type = value;
					break;
				}
				case "version":
				{
					packageDefinitionFile.version.version = SemVer.fromString( value );
					break;
				}
				case "platforms":
				{
					packageDefinitionFile.version.platforms.length = 0;
					var platforms:Array = value.split( "," );
					for each (var platform:String in platforms)
					{
						if (!Platform.isKnownPlatformName( platform ))
						{
							APM.io.writeError( name, "Invalid platform name: " + platform );
							continue;
						}

						packageDefinitionFile.version.platforms.push( new Platform( platform, true ) );
					}
					break;
				}
				case "tags":
				{
					packageDefinitionFile.packageDef.tags.length = 0;
					var tags:Array = value.split( "," );
					for each (var tag:String in tags)
					{
						packageDefinitionFile.packageDef.tags.push( tag );
					}
					break;
				}
				default:
				{
					APM.io.writeError( name, "Invalid project parameter name" );
				}
			}
		}


	}

}
