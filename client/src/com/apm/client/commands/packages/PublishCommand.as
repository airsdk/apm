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
	import com.apm.client.Consts;
	import com.apm.client.commands.Command;
	import com.apm.client.commands.packages.processes.PackageContentCreateProcess;
	import com.apm.client.commands.packages.processes.PackageContentVerifyProcess;
	import com.apm.client.commands.packages.processes.PackageDefinitionLoadProcess;
	import com.apm.client.commands.packages.processes.PackageDependenciesVerifyProcess;
	import com.apm.client.commands.packages.processes.PackageGenerateChecksumProcess;
	import com.apm.client.commands.packages.processes.PackagePublishProcess;
	import com.apm.client.commands.packages.processes.PackageRemoteContentVerifyProcess;
	import com.apm.client.processes.ProcessQueue;
	import com.apm.client.processes.generic.ExtractZipProcess;
	import com.apm.data.packages.PackageDefinitionFile;
	import com.apm.data.packages.PackageDependency;
	import com.apm.utils.PackageFileUtils;
	
	import flash.filesystem.File;
	
	
	public class PublishCommand implements Command
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
		
		
		public function execute( core:APMCore ):void
		{
			var path:String = "";
			if (_parameters != null && _parameters.length > 0)
			{
				path = _parameters[ 0 ];
			}
			core.io.writeLine( "Publishing package: " + path );
			
			var tmpDir:File = new File( core.config.workingDir + File.separator + ".apm__tmp" );
			if (tmpDir.exists)
			{
				cleanup( tmpDir );
			}
			
			var source:File = new File( core.config.workingDir + File.separator + path );
			if (!source.exists)
			{
				core.io.writeError( source.name, "Specified package directory / file does not exist" );
				return core.exit( APMCore.CODE_ERROR );
			}

			
			var packageDefinitionFile:PackageDefinitionFile = new PackageDefinitionFile();
			if (source.isDirectory)
			{
				var f:File = source.resolvePath( PackageDefinitionFile.DEFAULT_FILENAME );
				if (!f.exists)
				{
					core.io.writeError( PackageDefinitionFile.DEFAULT_FILENAME, "Package definition file does not exist" );
					return core.exit( APMCore.CODE_ERROR );
				}
				
				_queue.addProcess( new PackageContentVerifyProcess( core, source ));
				_queue.addProcess( new PackageDefinitionLoadProcess( core, packageDefinitionFile, f ));
			}
			else if (source.extension == "zip" || source.extension == PackageFileUtils.AIRPACKAGEEXTENSION)
			{
				var pf:File = tmpDir.resolvePath( PackageDefinitionFile.DEFAULT_FILENAME );
				
				_queue.addProcess( new ExtractZipProcess( core, source, tmpDir ) );
				_queue.addProcess( new PackageContentVerifyProcess( core, tmpDir ));
				_queue.addProcess( new PackageDefinitionLoadProcess( core, packageDefinitionFile, pf ));
				_queue.addProcess( new PackageGenerateChecksumProcess( core, packageDefinitionFile, source ));
			}
			else
			{
				core.io.writeError( source.name, "Cannot publish this file / directory" );
				return core.exit( APMCore.CODE_ERROR );
			}
			
			_queue.addProcess( new PackageRemoteContentVerifyProcess( core, packageDefinitionFile ) );
			_queue.addProcess( new PackagePublishProcess( core, packageDefinitionFile ) );
			
			_queue.start(
					function ():void {
						cleanup( tmpDir );
						core.exit( APMCore.CODE_OK );
					},
					function ( message:String ):void {
						cleanup( tmpDir );
						core.io.writeError( "ERROR", message );
						core.exit( APMCore.CODE_ERROR );
						
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
