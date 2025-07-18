/**
 * @author 		Michael Archbold (https://michaelarchbold.com)
 * @created		6/8/2021
 */
package com.apm.client.analytics
{
	import com.apm.client.repositories.RepositoryResolver;
	import com.apm.remote.repository.RepositoryAPI;
	
	
	/**
	 * A really basic analytics implementation so we can display install stats on
	 * the repository site.
	 */
	public class Analytics
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "Analytics";
		
		
		////////////////////////////////////////////////////////
		//	SINGLETON REFERENCE
		//
		
		private static var _shouldCreateInstance:Boolean = false;
		private static var _instance:Analytics;
		public static function get instance():Analytics
		{
			if (_instance == null)
			{
				_shouldCreateInstance = true;
				_instance = new Analytics();
				_shouldCreateInstance = false;
			}
			return _instance;
		}
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function Analytics()
		{
			if (_shouldCreateInstance)
			{
			}
			else
			{
				throw new Error( "Use Analytics.instance to access the analytics functionality" );
			}
		}
		
		
		public function install( identifier:String, version:String, source:String, callback:Function = null ):void
		{
			if (source == "file")
			{
				callback();
			}
			else
			{
				RepositoryResolver.repositoryForSource( source )
						.logEvent( "install", identifier, version, callback );
			}
		}
		
		
		public function download( identifier:String, version:String, source:String, callback:Function = null ):void
		{
			if (source == "file")
			{
				callback();
			}
			else
			{
				RepositoryResolver.repositoryForSource( source )
						.logEvent( "download", identifier, version, callback );
			}
		}
		
		
		public function uninstall( identifier:String, version:String, source:String, callback:Function = null ):void
		{
			if (source == "file")
			{
				callback();
			}
			else
			{
				RepositoryResolver.repositoryForSource( source )
						.logEvent( "uninstall", identifier, version, callback );
			}
		}
		
		
	}
}
