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
 * @created		15/9/21
 */
package com.apm.client.repositories
{
	import com.apm.SemVer;
	import com.apm.SemVerRange;
	import com.apm.client.APM;
	import com.apm.client.logging.Log;
	import com.apm.client.processes.ProcessQueue;
	import com.apm.client.repositories.processes.RepositoryGetPackageVersionProcess;
	import com.apm.data.packages.PackageDefinition;
	import com.apm.data.packages.RepositoryDefinition;
	import com.apm.remote.repository.RepositoryAPI;
	import com.apm.remote.repository.RepositoryQueryOptions;
	
	
	/**
	 * This stores the result of a package resolution search
	 */
	public class PackageResolverResult
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "PackageResolver";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		
		public var resolvedPackage:PackageDefinition;
		
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function PackageResolverResult()
		{
		}
		
		
	}
	
}
