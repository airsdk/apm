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
	import com.apm.client.APM;
	import com.apm.client.logging.Log;
	import com.apm.client.processes.ProcessQueue;
	import com.apm.client.repositories.processes.RepositoryGetPackageVersionProcess;
	import com.apm.data.packages.PackageDefinition;
	import com.apm.data.packages.RepositoryDefinition;
	import com.apm.remote.repository.Repository;
	import com.apm.remote.repository.RepositoryAPI;
	
	
	/**
	 * This is a central package resolver, that attempts to locate a package
	 * either locally in a local filesystem repository or remotely in the repository
	 */
	public class PackageResolver
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "PackageResolver";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _repositoryAPI:RepositoryAPI;
		
		public var resolvedPackage:PackageDefinition;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function PackageResolver()
		{
		}
		
		public function search( query:String, callback:Function = null ):void
		{
			// TODO:: Add/implement source
			RepositoryResolver.repositoryForSource()
					.search( query, callback );
		}
		
		
		public function getPackage( identifier:String, callback:Function = null ):void
		{
			// TODO:: Add/implement source
			RepositoryResolver.repositoryForSource()
					.getPackage( identifier, callback );
		}
		
		
		public function getPackageVersion( identifier:String, version:SemVer, source:String, callback:Function = null ):void
		{
			// TODO:: Implement source
			var searchQueue:ProcessQueue = new ProcessQueue();
			var repo:Repository;
			if (APM.config.projectDefinition)
			{
				for each (var repository:RepositoryDefinition in APM.config.projectDefinition.repositories)
				{
					searchQueue.addProcess(
							new RepositoryGetPackageVersionProcess(
									this,
									RepositoryResolver.repositoryForSource( repository.name ),
									identifier,
									version
							)
					);
				}
			}
			
			// Add one for the common server
			searchQueue.addProcess(
					new RepositoryGetPackageVersionProcess(
							this,
							RepositoryResolver.repositoryForSource(),
							identifier,
							version
					)
			);
			
			searchQueue.start(
					function ():void {
						callback( resolvedPackage != null, resolvedPackage );
					},
					function ( error:String ):void {
						Log.d( TAG, "ERROR:" + error );
						callback( false, null );
					}
			);
			
		}
		
		
	}
	
}
