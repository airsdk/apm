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
 * @created		15/6/21
 */
package com.apm.client.commands.packages.processes
{
	import com.apm.client.APM;
	import com.apm.data.install.InstallData;
	import com.apm.data.install.InstallRequest;
	import com.apm.client.logging.Log;
	import com.apm.client.repositories.PackageResolver;
	import com.apm.client.processes.ProcessBase;
	import com.apm.client.processes.ProcessQueue;
	import com.apm.client.processes.generic.ExtractZipProcess;
	import com.apm.data.packages.PackageDefinitionFile;
	import com.apm.data.packages.PackageDependency;
	import com.apm.data.packages.PackageVersion;
	import com.apm.utils.PackageFileUtils;
	
	import flash.filesystem.File;
	
	
	/**
	 * This process is to request the package and assemble the listed dependencies
	 */
	public class InstallLocalPackageProcess extends ProcessBase
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "InstallQueryPackageProcess";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _packageFile:File;
		private var _installData:InstallData;
		private var _failIfInstalled:Boolean;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function InstallLocalPackageProcess(
				packageFile:File,
				data:InstallData,
				failIfInstalled:Boolean = true )
		{
			super();
			_packageFile = packageFile;
			_installData = data;
			_failIfInstalled = failIfInstalled;
		}
		
		
		override public function start( completeCallback:Function = null, failureCallback:Function = null ):void
		{
			super.start( completeCallback, failureCallback );
			
			var packageDefinitionFile:PackageDefinitionFile = new PackageDefinitionFile();
			var packageDir:File = new File();
			
			var subqueue:ProcessQueue = new ProcessQueue();
			subqueue.addProcess( new PackageExtractDefinitionProcess( packageDefinitionFile, _packageFile ) );
			subqueue.start(
					function ():void {
						_installData.addPackage( packageDefinitionFile.version,
												 new InstallRequest(
														 packageDefinitionFile.packageDef.identifier,
														 packageDefinitionFile.version.version.toString(),
														 "file",
														 null,
														 true,
														 _packageFile
												 )
						);
						
						// Queue dependencies for install
						for each (var dep:PackageDependency in packageDefinitionFile.dependencies)
						{
							_queue.addProcess(
									new InstallQueryPackageProcess(
											_installData,
											new InstallRequest(
													dep.identifier,
													dep.version.toString(),
													dep.source,
													packageDefinitionFile.version )
									) );
						}
						complete();
					},
					function ( error:String ):void {
						failure( error );
					}
			)
			
		}
		
		
	}
	
}
