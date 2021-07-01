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
	import com.apm.client.APMCore;
	import com.apm.client.commands.packages.utils.PackageRequestUtils;
	import com.apm.client.processes.ProcessBase;
	import com.apm.data.packages.PackageDefinition;
	import com.apm.data.packages.PackageDefinitionFile;
	import com.apm.data.packages.PackageDependency;
	import com.apm.remote.repository.RepositoryAPI;
	
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.filesystem.File;
	import flash.html.script.Package;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	
	
	/**
	 * Verifies the dependencies for a package structure in the specified path.
	 * <br/>
	 * The process will check the dependencies for the package exist in the package repository and fail if not.
	 */
	public class PackageDependenciesVerifyProcess extends ProcessBase
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "PackageDependenciesVerifyProcess";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _core:APMCore;
		private var _dependency:PackageDependency;
		private var _repositoryAPI:RepositoryAPI;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function PackageDependenciesVerifyProcess( core:APMCore, dependency:PackageDependency )
		{
			_core = core;
			_dependency = dependency;
			_repositoryAPI = new RepositoryAPI();
		}
		
		
		override public function start():void
		{
			_core.io.showSpinner( "Checking dependency: " + _dependency.toString() );
			
			_repositoryAPI.getPackageVersion( _dependency.identifier, _dependency.version, function( success:Boolean, packageDef:PackageDefinition ):void {
				if (success && packageDef != null)
				{
					_core.io.stopSpinner( true,"Dependency VERIFIED: " + _dependency.toString() );
					complete();
				}
				else
				{
					_core.io.stopSpinner( false, "Dependency INVALID: " + _dependency.toString() );
					failure();
				}
			});
			
		}
		
		
	
		
		
	}
	
}
