/**
 * @author 		Michael Archbold (https://michaelarchbold.com)
 * @created		15/9/2021
 */
package com.apm.client.repositories.processes
{
	import com.apm.SemVer;
	import com.apm.SemVerRange;
	import com.apm.client.logging.Log;
	import com.apm.client.processes.ProcessBase;
	import com.apm.client.repositories.PackageResolver;
	import com.apm.client.repositories.PackageResolverResult;
	import com.apm.data.packages.PackageDefinition;
	import com.apm.data.packages.PackageVersion;
	import com.apm.remote.repository.Repository;
	import com.apm.remote.repository.RepositoryQueryOptions;
	
	
	public class RepositoryGetPackageVersionProcess extends ProcessBase
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "RepositoryGetPackageVersionProcess";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _result:PackageResolverResult;
		private var _repository:Repository;
		private var _identifier:String;
		private var _version:SemVerRange;
		private var _options:RepositoryQueryOptions;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function RepositoryGetPackageVersionProcess( result:PackageResolverResult, repo:Repository, identifier:String, version:SemVerRange, options:RepositoryQueryOptions )
		{
			_result = result;
			_repository = repo;
			_identifier = identifier;
			_version = version;
			_options = options;
		}
		
		
		override public function start( completeCallback:Function = null, failureCallback:Function = null ):void
		{
			super.start( completeCallback, failureCallback );
			try
			{
				_repository.getPackageVersion(
						_identifier,
						_version,
						_options,
						function ( success:Boolean, packageDefinition:PackageDefinition ):void
						{
							if (success)
							{
								if (_repository.name != null)
								{
									for each (var v:PackageVersion in packageDefinition.versions)
									{
										v.source = _repository.name;
									}
								}
								_result.resolvedPackage = packageDefinition;
							}
							complete();
						}
				);
			}
			catch (e:Error)
			{
				Log.e( TAG, e );
				failure( e.message );
			}
		}
		
	}
	
}
