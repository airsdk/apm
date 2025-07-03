/**
 * @author 		Michael Archbold (https://michaelarchbold.com)
 * @created		28/6/2021
 */
package com.apm.client.commands.packages.utils
{
	import com.apm.SemVer;
	import com.apm.client.APM;
	import com.apm.client.Consts;
	import com.apm.client.logging.Log;
	import com.apm.remote.github.GitHubAPI;
	
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	
	
	public class PackageRequestUtils
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "PackageRequestUtils";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		
		private static var GITHUB_ASSET:RegExp = /https:\/\/github\.com\/(.*)\/(.*)\/releases\/download\/(.*)\/(.*)/;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function PackageRequestUtils()
		{
		}
		
		
		/**
		 * Utility function that generates a URLRequest.
		 * <br/>
		 * This is done asynchronously to allow us to access a private repository url and extract the release asset from the url.
		 * Relies upon the user's github token.
		 *
		 * @param url			The url to generate the
		 * @param githubToken	The user's github token
		 * @param callback		Callback function of the form function( req:URLRequest ):void
		 */
		public static function generateURLRequestForPackage( url:String, githubToken:String, callback:Function ):void
		{
			Log.d( TAG, "generateURLRequestForPackage( " + url + " ... )" );
			if (GITHUB_ASSET.test( url ))
			{
				Log.d( TAG, "generateURLRequestForPackage(): GITHUB ASSET URL" );
				
				var params:Array = GITHUB_ASSET.exec( url );
				
				var repo:String = params[ 1 ] + "/" + params[ 2 ];
				var version:String = params[ 3 ];
				var filename:String = params[ 4 ];
				
				new GitHubAPI().setToken( githubToken )
						.call( "/repos/" + repo + "/releases", function ( success:Boolean, data:* ):void {
							
							if (success)
							{
								
								var releases:Array = JSON.parse( data as String ) as Array;
//								Log.d( TAG, "generateURLRequestForPackage(): release details: " + JSON.stringify(releases)  );
								for each (var release:Object in releases)
								{
									if (release.tag_name == version)
									{
										Log.d( TAG, "generateURLRequestForPackage(): release : " + JSON.stringify(release)  );
										// found release
										for each (var asset:Object in release.assets)
										{
											if (asset.name == filename)
											{
												Log.d( TAG, "generateURLRequestForPackage(): asset: " + JSON.stringify(asset)  );
												if (githubToken == null || githubToken.length == 0)
												{
													callback( generateURLRequest(
															asset.browser_download_url,
															githubToken
													));
												}
												else
												{
													return generateURLRequestForPackage(
															"https://api.github.com/repos/" + repo + "/releases/assets/" + asset.id,
															githubToken,
															callback );
												}
											}
										}
									}
								}
							}
							
							callback( generateURLRequest( url, githubToken ) );
							
						} );
			}
			else
			{
				Log.d( TAG, "generateURLRequestForPackage(): NORMAL URL" );
				callback( generateURLRequest( url, githubToken ) );
			}
		}
		
		
		private static function generateURLRequest( url:String, githubToken:String ):URLRequest
		{
			try
			{
				var headers:Array = [];
				headers.push( new URLRequestHeader( "User-Agent", "apm v" + Consts.VERSION ) );
				
				if (url.indexOf( "https://api.github.com/" ) == 0 && githubToken.length > 0)
				{
					headers.push( new URLRequestHeader( "Accept", "application/octet-stream" ) );
		
					if (githubToken != null && githubToken.length > 0)
					{
						Log.d( TAG, "generateURLRequest(): Attaching github auth token." );
						headers.push( new URLRequestHeader( "Authorization", "token " + githubToken ) );
					}
				}
				
				var req:URLRequest = new URLRequest( url );
				req.method = URLRequestMethod.GET;
				req.requestHeaders = headers;
				
				return req;
			}
			catch (e:Error)
			{
				Log.e( TAG, e );
			}
			return new URLRequest( url );
		}
		
		
	}
}
