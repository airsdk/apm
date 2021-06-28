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
 * @created		7/6/21
 */
package com.apm.remote.airsdk
{
	import com.apm.remote.lib.APIRequestQueue;
	
	import flash.events.EventDispatcher;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	
	
	/**
	 * API for accessing information about the AIR SDK releases
	 */
	public class AIRSDKAPI extends EventDispatcher
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "AIRSDKAPI";
		
		
		public static const DOWNLOAD_ENDPOINT:String = "https://airsdk.harman.com";
		
		public static const API_ENDPOINT:String = "https://dcdu3ujoji.execute-api.us-east-1.amazonaws.com/production";
		
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _requestQueue:APIRequestQueue;
		
		private var _endpoint:String = API_ENDPOINT;
		
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function AIRSDKAPI()
		{
			super();
			_requestQueue = new APIRequestQueue();
		}
		
		
		public function setEndpoint( endpoint:String ):AIRSDKAPI
		{
			this._endpoint = endpoint;
			return this;
		}
		
		
		public function getReleases( callback:Function = null ):void
		{
			var req:URLRequest = new URLRequest();
			req.method = URLRequestMethod.GET;
			req.url = _endpoint + "/releases";
			
			_requestQueue.add( req, "releases", function ( success:Boolean, data:* ):void {
				var builds:Array = [];
				if (success) builds = processReleases( data );
				
				if (callback != null)
				{
					callback( success, builds, data );
				}
				
			}, 2 );
		}
		
		
		private static function processReleases( data:String ):Array
		{
			var releases:Array = [];
			try
			{
				var releasesObj:Object = JSON.parse( data );
				if (releasesObj.hasOwnProperty( "releases" ))
				{
					for each (var releaseObj:Object in releasesObj.releases)
					{
						releases.push(
								AIRSDKBuild.fromObject( releaseObj )
						);
					}
				}
			}
			catch (e:Error)
			{
				trace( e );
			}
			return releases;
		}
		
		
		public function getRecentReleases( days:int, callback:Function = null ):void
		{
			// TODO
		}
		
		
		public function getLatestRelease( callback:Function = null ):void
		{
			// TODO
		}
		
		
		/**
		 *
		 * @param version
		 * @param callback Function callback of format <code>function( success:Boolean, build:AIRSDKBuild, message:String ):void</code>
		 */
		public function getRelease( version:String, callback:Function = null ):void
		{
			var req:URLRequest = new URLRequest();
			req.method = URLRequestMethod.GET;
			req.url = _endpoint + "/releases/" + version;
			
			_requestQueue.add( req, "release", function ( success:Boolean, data:* ):void {
				try
				{
					if (success)
					{
						var build:AIRSDKBuild = AIRSDKBuild.fromObject( JSON.parse( data ) );
						
						getUrls( version, function ( success:Boolean, urls:Object, data:String ):void {
							if (success)
							{
								build.urls = urls;
								getReleaseNotes( version, function ( success:Boolean, releaseNotes:Array, data:String ):void {
									if (success)
									{
										build.releaseNotes = releaseNotes;
									}
									
									if (callback != null)
									{
										callback( true, build, "" );
									}
									
//									else
//									{
//										if (callback != null)
//										{
//											callback( false, null, data );
//										}
//									}
								} );
							}
							else
							{
								if (callback != null)
								{
									callback( false, null, data );
								}
							}
						} );
					}
					else
					{
						if (callback != null)
						{
							callback( false, null, data );
						}
					}
				}
				catch (e:Error)
				{
					trace( e );
				}
			}, 2 );
		}
		
		
		public function getUrls( version:String, callback:Function = null ):void
		{
			var req:URLRequest = new URLRequest();
			req.method = URLRequestMethod.GET;
			req.url = _endpoint + "/releases/" + version + "/urls";
			
			_requestQueue.add( req, "release_urls", function ( success:Boolean, data:* ):void {
				if (success)
				{
					var urls:Object;
					try
					{
						urls = JSON.parse( data );
					}
					catch (e:Error)
					{
						trace( e );
					}
					
					if (callback != null)
					{
						callback( true, urls, data );
					}
				}
				else
				{
					if (callback != null)
					{
						callback( false, null, data );
					}
				}
			} );
		}
		
		
		public function getReleaseNotes( version:String, callback:Function = null ):void
		{
			var req:URLRequest = new URLRequest();
			req.method = URLRequestMethod.GET;
			req.url = _endpoint + "/releases/" + version + "/release_notes";
			
			_requestQueue.add( req, "release_notes", function ( success:Boolean, data:* ):void {
				if (success)
				{
					var releaseNotes:Array = [];
					try
					{
						var releaseNotesObject:Object = JSON.parse( data );
						if (releaseNotesObject.hasOwnProperty( "release_notes" ))
							releaseNotes = releaseNotesObject[ "release_notes" ];
					}
					catch (e:Error)
					{
						trace( e );
					}
					
					if (callback != null)
					{
						callback( true, releaseNotes, data );
					}
				}
				else
				{
					if (callback != null)
					{
						callback( false, null, data );
					}
				}
			} );
		}
		
		
	}
	
	
}
