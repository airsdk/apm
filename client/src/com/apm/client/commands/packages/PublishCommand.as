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
	import com.apm.client.commands.packages.processes.PackageContentCreateProcess;
	import com.apm.client.commands.packages.processes.PackageContentVerifyProcess;
	import com.apm.client.commands.packages.processes.PackageDependenciesVerifyProcess;
	import com.apm.client.commands.packages.processes.PackagePublishProcess;
	import com.apm.client.commands.packages.processes.PackageRemoteContentVerifyProcess;
	import com.apm.client.processes.ProcessQueue;
	import com.apm.data.packages.PackageDefinitionFile;
	import com.apm.data.packages.PackageDependency;
	
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
			
			core.io.writeLine( "Publishing package" );
			
			var directory:File = new File( core.config.workingDir + File.separator + path );
			if (!directory.exists)
			{
				core.io.writeError( directory.name, "Specified package directory does not exist" );
				return core.exit( APMCore.CODE_ERROR );
			}
			var packageDefinitionFile:File = directory.resolvePath( PackageDefinitionFile.DEFAULT_FILENAME );
			if (!packageDefinitionFile.exists)
			{
				core.io.writeError( PackageDefinitionFile.DEFAULT_FILENAME, "Package definition file does not exist" );
				return core.exit( APMCore.CODE_ERROR );
			}
			var f:PackageDefinitionFile = new PackageDefinitionFile().load( packageDefinitionFile );
			
			_queue.addProcess( new PackageRemoteContentVerifyProcess( core, f ) );
			for each (var dep:PackageDependency in f.dependencies)
			{
				_queue.addProcess( new PackageDependenciesVerifyProcess( core, dep ) );
			}
			_queue.addProcess( new PackagePublishProcess( core, f ) );
			
			_queue.start(
					function ():void {
						core.exit( APMCore.CODE_OK );
					},
					function ( message:String ):void {
						core.io.writeError( "ERROR", message );
						core.exit( APMCore.CODE_ERROR );
						
					}
			);
		}
		
	}
	
}
