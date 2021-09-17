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
	import com.apm.client.repositories.PackageResolver;
	import com.apm.client.processes.ProcessBase;
	import com.apm.data.packages.PackageDefinition;
	import com.apm.data.packages.PackageDefinitionFile;
	import com.apm.data.packages.PackageDependency;
	
	
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
		
		private var _dependency:PackageDependency;
		private var _packageResolver:PackageResolver;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function PackageDependenciesVerifyProcess( dependency:PackageDependency )
		{
			_dependency = dependency;
			_packageResolver = new PackageResolver();
		}
		
		
		override public function start( completeCallback:Function = null, failureCallback:Function = null ):void
		{
			super.start( completeCallback, failureCallback );
			APM.io.showSpinner( "Checking dependency: " + _dependency.toString() );
			
			if (_dependency.identifier == null || _dependency.identifier.length == 0 || _dependency.version == null)
			{
				failure( "INVALID DEPENDENCY [" + _dependency.toString() + "] - check your dependencies in the " + PackageDefinitionFile.DEFAULT_FILENAME );
			}
			_packageResolver.getPackageVersion(
					_dependency.identifier,
					_dependency.version,
					_dependency.source,
					function ( success:Boolean, packageDef:PackageDefinition ):void {
						if (success && packageDef != null && packageDef.versions.length > 0)
						{
							APM.io.stopSpinner( true, "VERIFIED: " + _dependency.toString() );
							complete();
						}
						else
						{
							APM.io.stopSpinner( false, "Could not verify: " + _dependency.toString() );
							failure( "INVALID DEPENDENCY [" + _dependency.toString() + "] - check your dependencies in the " + PackageDefinitionFile.DEFAULT_FILENAME );
						}
					}
			);
			
		}
		
		
	}
	
}
