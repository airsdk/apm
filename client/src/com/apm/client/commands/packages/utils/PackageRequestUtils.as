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
 * @created		28/6/21
 */
package com.apm.client.commands.packages.utils
{
	import com.apm.SemVer;
	import com.apm.client.APMCore;
	import com.apm.client.Consts;
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
		 * @param url		The url to generate the
		 * @param core		APMCore
		 * @param callback	Callback function of the form function( req:URLRequest ):void
		 */
		public static function generateURLRequestForPackage( url:String, core:APMCore, callback:Function ):void
		{
			if (GITHUB_ASSET.test( url ))
			{
				var params:Array = GITHUB_ASSET.exec( url );
				
				var repo:String = params[ 1 ] + "/" + params[ 2 ];
				var version:String = params[ 3 ];
				var filename:String = params[ 4 ];
				
				new GitHubAPI().setToken( core.config.user.github_token )
						.call( "/repos/" + repo + "/releases", function ( success:Boolean, data:* ):void {
							
							if (success)
							{
								var releases:Array = JSON.parse( data as String ) as Array;
								for each (var release:Object in releases)
								{
									if (release.name == version)
									{
										// found release
										for each (var asset:Object in release.assets)
										{
											if (asset.name == filename)
											{
												return generateURLRequestForPackage(
														"https://api.github.com/repos/" + repo + "/releases/assets/" + asset.id,
														core,
														callback );
											}
										}
									}
								}
							}
							
							callback( generateURLRequest( url, core ) );
							
						} );
			}
			else
			{
				callback( generateURLRequest( url, core ) );
			}
		}
		
		
		private static function generateURLRequest( url:String, core:APMCore ):URLRequest
		{
			var headers:Array = [];
			headers.push( new URLRequestHeader( "User-Agent", "apm v" + new SemVer( Consts.VERSION ).toString() ) );
			
			if (url.indexOf( "github.com" ) >= 0 && core.config.user.github_token.length > 0)
			{
				headers.push( new URLRequestHeader( "Accept", "application/octet-stream" ) );
				headers.push( new URLRequestHeader( "Authorization", "token " + core.config.user.github_token ) );
			}
			
			var req:URLRequest = new URLRequest( url );
			req.method = URLRequestMethod.GET;
			req.requestHeaders = headers;
			
			return req;
		}
		
		
	}
}
