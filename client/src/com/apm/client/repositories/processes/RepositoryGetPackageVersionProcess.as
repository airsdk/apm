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
package com.apm.client.repositories.processes
{
	import com.apm.SemVer;
	import com.apm.client.logging.Log;
	import com.apm.client.repositories.PackageResolver;
	import com.apm.client.processes.ProcessBase;
	import com.apm.data.packages.PackageDefinition;
	import com.apm.data.packages.PackageVersion;
	import com.apm.remote.repository.Repository;
	
	
	public class RepositoryGetPackageVersionProcess extends ProcessBase
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "RepositoryGetPackageVersionProcess";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _resolver:PackageResolver;
		private var _repository:Repository;
		private var _identifier:String;
		private var _version:SemVer;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function RepositoryGetPackageVersionProcess( resolver:PackageResolver, repo:Repository, identifier:String, version:SemVer )
		{
			_resolver = resolver;
			_repository = repo;
			_identifier = identifier;
			_version = version;
		}
		
		
		override public function start( completeCallback:Function = null, failureCallback:Function = null ):void
		{
			super.start( completeCallback, failureCallback );
			try
			{
				_repository.getPackageVersion( _identifier, _version, function( success:Boolean, packageDefinition:PackageDefinition ):void
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
						_resolver.resolvedPackage = packageDefinition;
					}
					complete();
				});
			}
			catch (e:Error)
			{
				Log.e( TAG, e );
				failure( e.message );
			}
		}
		
	}
	
}
