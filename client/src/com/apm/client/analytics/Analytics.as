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
 * @created		6/8/21
 */
package com.apm.client.analytics
{
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
		
		private var _repositoryAPI:RepositoryAPI;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function Analytics()
		{
			if (_shouldCreateInstance)
			{
				_repositoryAPI = new RepositoryAPI();
			}
			else
			{
				throw new Error( "Use Analytics.instance to access the analytics functionality" );
			}
		}
		
		
		public function install( identifier:String, version:String, callback:Function = null ):void
		{
			_repositoryAPI.logEvent( "install", identifier, version, callback );
		}
		
		
		public function download( identifier:String, version:String, callback:Function = null ):void
		{
			_repositoryAPI.logEvent( "download", identifier, version, callback );
		}
		
		
		public function uninstall( identifier:String, version:String, callback:Function = null ):void
		{
			_repositoryAPI.logEvent( "uninstall", identifier, version, callback );
		}
		
		
	}
}
