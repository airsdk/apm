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
 * @created		28/6/2021
 */
package com.apm.remote.github
{
	import com.apm.remote.lib.APIRequestQueue;
	
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	
	
	public class GitHubAPI
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "GitHubAPI";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		
		private var _requestQueue:APIRequestQueue;
		
		private var _endpoint:String = "https://api.github.com";
		
		private var _token:String = "";
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function GitHubAPI()
		{
			_requestQueue = new APIRequestQueue();
		}
		
		
		public function setToken( token:String ):GitHubAPI
		{
			this._token = token;
			return this;
		}
		
		
		public function call( query:String, callback:Function ):void
		{
			var headers:Array = [];
			headers.push( new URLRequestHeader( "Accept", "application/vnd.github.v3.raw" ) );
			if (_token.length > 0)
			{
				headers.push( new URLRequestHeader( "Authorization", "token " + _token ) );
			}
			
			var req:URLRequest = new URLRequest( _endpoint + query );
			req.method = URLRequestMethod.GET;
			req.requestHeaders = headers;
			
			_requestQueue.add( req, "gh", callback );
		}
		
	}
	
}
