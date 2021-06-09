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
 * @created		18/5/21
 */
package com.apm.remote.repository
{
	import com.apm.data.PackageDefinition;
	import com.apm.remote.lib.APIRequestQueue;
	
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	
	public class RepositoryAPI
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "RepositoryAPI";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _requestQueue:APIRequestQueue;
		
		private var _endpoint:String = "http://localhost:3000";
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function RepositoryAPI()
		{
			super();
			_requestQueue = new APIRequestQueue();
		}
		
		
		public function setEndpoint( endpoint:String ):RepositoryAPI
		{
			this._endpoint = endpoint;
			return this;
		}
		
		
		public function search( query:String, callback:Function = null )
		{
			var vars:URLVariables = new URLVariables();
			vars[ "q" ] = query;
			
			var req:URLRequest = new URLRequest();
			req.method = URLRequestMethod.GET;
			req.url = _endpoint + "/api/search";
			req.data = vars;
			
			_requestQueue.add( req, "search", function ( success:Boolean, data:* ):void {
				
				var packages:Vector.<PackageDefinition> = new Vector.<PackageDefinition>();
				try
				{
					if (success)
					{
						var packagesArray:Array = JSON.parse( String( data ) ) as Array;
						for each (var packageObject:Object in packagesArray)
						{
							packages.push( new PackageDefinition().fromObject( packageObject ) );
						}
					}
				}
				catch (e:Error)
				{
					success = false;
				}
				
				if (callback != null)
				{
					callback( success, packages );
				}
			} );
		}
		
		
		public function getPackage( identifier:String, callback:Function = null ):void
		{
			var req:URLRequest = new URLRequest();
			req.method = URLRequestMethod.GET;
			req.url = _endpoint + "/api/packages/" + identifier;
			
			_requestQueue.add( req, "getpackage", function ( success:Boolean, data:* ):void {
				
				var packageDefinition:PackageDefinition = null;
				try
				{
					var dataObject:Object = JSON.parse( data );
					if (success)
					{
						packageDefinition = new PackageDefinition().fromObject( dataObject );
					}
				}
				catch (e:Error)
				{
					success = false;
				}
				
				if (callback != null)
				{
					callback( success, packageDefinition );
				}
			} );
		}
		
		
	}
}
