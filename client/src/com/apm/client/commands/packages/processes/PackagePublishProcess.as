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
	import com.apm.client.processes.ProcessBase;
	import com.apm.client.repositories.RepositoryResolver;
	import com.apm.data.packages.PackageDefinitionFile;
	import com.apm.remote.repository.Repository;
	import com.apm.remote.repository.RepositoryAPI;
	
	
	/**
	 * Publishes a verified package to the package repository.
	 */
	public class PackagePublishProcess extends ProcessBase
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "PackagePublishProcess";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _packageDefinition:PackageDefinitionFile;
		private var _repositoryAPI:Repository;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function PackagePublishProcess( packageDefinition:PackageDefinitionFile )
		{
			_packageDefinition = packageDefinition;
		}
		
		
		override public function start( completeCallback:Function = null, failureCallback:Function = null ):void
		{
			super.start( completeCallback, failureCallback );
			if (APM.config.user.publisherToken == null || APM.config.user.publisherToken.length == 0)
			{
				return failure( "No publisher token currently set" );
			}
			
			APM.io.showSpinner( "Publish package" );
			
			RepositoryResolver.repositoryForSource()
					.setToken( APM.config.user.publisherToken )
					.publish( _packageDefinition, function ( success:Boolean, data:* ):void {
						APM.io.stopSpinner( success, "Package published" + (success ? "" : " ERROR: " + data) );
						complete();
					} );
			
		}
		
		
	}
	
}
