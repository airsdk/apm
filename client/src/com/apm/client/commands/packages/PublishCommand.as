/**
 * @author 		Michael Archbold (https://michaelarchbold.com)
 * @created		18/5/2021
 */
package com.apm.client.commands.packages
{
	import com.apm.client.APM;
	import com.apm.client.commands.Command;
	import com.apm.client.commands.packages.processes.PackageContentVerifyProcess;
	import com.apm.client.commands.packages.processes.PackageDefinitionLoadProcess;
	import com.apm.client.commands.packages.processes.PackageGenerateChecksumProcess;
	import com.apm.client.commands.packages.processes.PackagePublishProcess;
	import com.apm.client.commands.packages.processes.PackageRemoteContentVerifyProcess;
	import com.apm.client.events.CommandEvent;
	import com.apm.client.processes.ProcessQueue;
	import com.apm.client.processes.generic.ExtractZipProcess;
	import com.apm.data.packages.PackageDefinitionFile;
	import com.apm.utils.FileUtils;
	import com.apm.utils.PackageFileUtils;

	import flash.events.EventDispatcher;
	import flash.filesystem.File;

	public class PublishCommand extends EventDispatcher implements Command
	{

		////////////////////////////////////////////////////////
		//  CONSTANTS
		//

		private static const TAG:String = "PublishCommand";

		public static const NAME:String = "publish";


		////////////////////////////////////////////////////////
		//  VARIABLES
		//

		private var _parameters:Array;
		private var _queue:ProcessQueue;


		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//

		public function PublishCommand()
		{
			super();
			_queue = new ProcessQueue();
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
			return "publish a package in the repository";
		}


		public function get usage():String
		{
			return description + "\n" +
					"\n" +
					"apm publish          publish a package in the current directory\n" +
					"apm publish <foo>    publish a package in a directory named <foo>\n";
		}


		public function execute():void
		{
			var path:String = "";
			if (_parameters != null && _parameters.length > 0)
			{
				path = _parameters[0];
			}
			APM.io.writeLine( "Publishing package: " + path );

			var tmpDir:File = new File( APM.config.workingDirectory + File.separator + ".apm__tmp" );
			if (tmpDir.exists)
			{
				cleanup( tmpDir );
			}

			var source:File = FileUtils.getSourceForPath( path );
			if (!source.exists)
			{
				APM.io.writeError( source.name, "Specified package directory / file does not exist" );
				dispatchEvent( new CommandEvent( CommandEvent.COMPLETE, APM.CODE_ERROR ) );
				return;
			}


			var packageDefinitionFile:PackageDefinitionFile = new PackageDefinitionFile();
			if (source.isDirectory)
			{
				var f:File = source.resolvePath( PackageDefinitionFile.DEFAULT_FILENAME );
				if (!f.exists)
				{
					APM.io.writeError( PackageDefinitionFile.DEFAULT_FILENAME, "Package definition file does not exist" );
					dispatchEvent( new CommandEvent( CommandEvent.COMPLETE, APM.CODE_ERROR ) );
					return;
				}

				_queue.addProcess( new PackageContentVerifyProcess( source ) );
				_queue.addProcess( new PackageDefinitionLoadProcess( packageDefinitionFile, f ) );
			}
			else if (source.extension == "zip" || source.extension == PackageFileUtils.AIRPACKAGEEXTENSION)
			{
				var pf:File = tmpDir.resolvePath( PackageDefinitionFile.DEFAULT_FILENAME );

				_queue.addProcess( new ExtractZipProcess( source, tmpDir ) );
				_queue.addProcess( new PackageContentVerifyProcess( tmpDir ) );
				_queue.addProcess( new PackageDefinitionLoadProcess( packageDefinitionFile, pf ) );
				_queue.addProcess( new PackageGenerateChecksumProcess( packageDefinitionFile, source ) );
			}
			else
			{
				APM.io.writeError( source.name, "Cannot publish this file / directory" );
				dispatchEvent( new CommandEvent( CommandEvent.COMPLETE, APM.CODE_ERROR ) );
				return;
			}

			_queue.addProcess( new PackageRemoteContentVerifyProcess( packageDefinitionFile ) );
			_queue.addProcess( new PackagePublishProcess( packageDefinitionFile ) );

			_queue.start(
					function ():void
					{
						cleanup( tmpDir );
						dispatchEvent( new CommandEvent( CommandEvent.COMPLETE, APM.CODE_OK ) );
					},
					function ( message:String ):void
					{
						cleanup( tmpDir );
						APM.io.writeError( "ERROR", message );
						dispatchEvent( new CommandEvent( CommandEvent.COMPLETE, APM.CODE_ERROR ) );
					}
			);
		}


		private function cleanup( tmpDir:File ):void
		{
			if (tmpDir.exists)
			{
				tmpDir.deleteDirectory( true );
			}
		}

	}

}
