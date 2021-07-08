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
	import com.apm.client.processes.ProcessBase;
	import com.apm.data.packages.PackageDefinitionFile;
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
		
		private var _core:APMCore;
		private var _packageDefinition:PackageDefinitionFile;
		private var _repositoryAPI:RepositoryAPI;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function PackagePublishProcess( core:APMCore, packageDefinition:PackageDefinitionFile )
		{
			_core = core;
			_packageDefinition = packageDefinition;
			
			_repositoryAPI = new RepositoryAPI();
		}
		
		
		override public function start():void
		{
			if (_core.config.user.publisher_token == null || _core.config.user.publisher_token.length == 0)
			{
				return failure( "No publisher token currently set" );
			}
			
			_core.io.showSpinner( "Publish package" );
			
			
			// TODO:: Populate dependencies...
			
			
			_repositoryAPI
					.setToken( _core.config.user.publisher_token )
					.publish( _packageDefinition, function ( success:Boolean, packageDefinition:* ):void {
						if (success)
						{
						
						}
						else
						{
						
						}
						
						_core.io.stopSpinner( success, "Package published" );
						complete();
					} );
			
		}
		
		
	}
	
}
