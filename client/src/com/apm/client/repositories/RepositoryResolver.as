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
 * @created		17/9/21
 */
package com.apm.client.repositories
{
	import com.apm.client.APM;
	import com.apm.data.packages.RepositoryDefinition;
	import com.apm.remote.repository.LocalRepository;
	import com.apm.remote.repository.Repository;
	import com.apm.remote.repository.RepositoryAPI;
	
	
	public class RepositoryResolver
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "RepositoryResolver";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function RepositoryResolver()
		{
		}
		
		
		public static function repositoryForSource( source:String = null ):Repository
		{
			if (source != null)
			{
				for each (var repository:RepositoryDefinition in APM.config.projectDefinition.repositories)
				{
					if (repository.name == source)
					{
						switch (repository.type)
						{
							case RepositoryDefinition.TYPE_LOCAL:
							{
								return new LocalRepository( repository.location )
										.setName( repository.name );
							}
	
							case RepositoryDefinition.TYPE_REMOTE:
							{
								return new RepositoryAPI( repository.location )
										.setName( repository.name );
							}
						}
					}
				}
			}
			return new RepositoryAPI( APM.config.getDefaultRemoteRepositoryEndpoint() );
		}
		
	}
}
