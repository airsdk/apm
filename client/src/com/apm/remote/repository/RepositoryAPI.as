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
	import com.apm.SemVer;
	import com.apm.client.APM;
	import com.apm.data.packages.PackageDefinition;
	import com.apm.data.packages.PackageDefinitionFile;
	import com.apm.remote.lib.APIRequestQueue;
	
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
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
		
		// Auth token for publish actions
		private var _token:String;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function RepositoryAPI()
		{
			super();
			_requestQueue = new APIRequestQueue();
		}
		
		
		private function get endpoint():String
		{
			return APM.config.getRemoteRepositoryEndpoint();
		}
		
		
		public function setToken( token:String ):RepositoryAPI
		{
			this._token = token;
			return this;
		}
		
		
		public function logEvent( event:String, identifier:String, version:String, callback:Function = null ):void
		{
			var vars:URLVariables = new URLVariables();
			vars[ "v" ] = version;
			
			var req:URLRequest = new URLRequest();
			req.method = URLRequestMethod.POST;
			req.url = endpoint + "/api/packages/" + identifier + "/" + version + "/analytics/" + event;
			req.data = vars;
			
			_requestQueue.add( req, "analytics", function ( success:Boolean, data:* ):void {
				if (callback != null)
				{
					callback();
				}
			} );
		}
		
		
		public function search( query:String, callback:Function = null ):void
		{
			var vars:URLVariables = new URLVariables();
			vars[ "q" ] = query;
//			vars[ "t" ] = query;
			
			var req:URLRequest = new URLRequest();
			req.method = URLRequestMethod.GET;
			req.url = endpoint + "/api/search";
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
			req.url = endpoint + "/api/packages/" + identifier;
			
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
		
		
		public function getPackageVersion( identifier:String, version:SemVer, callback:Function = null ):void
		{
			var req:URLRequest = new URLRequest();
			req.method = URLRequestMethod.GET;
			req.url = endpoint + "/api/packages/" + identifier + "/" + (version == null ? "latest" : version.toString());
			
			_requestQueue.add( req, "getpackageversion", function ( success:Boolean, data:* ):void {
				
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
		
		
		//
		//	PUBLISH ACTIONS
		//
		
		
		public function publish( packageDef:PackageDefinitionFile, callback:Function = null ):void
		{
			var headers:Array = [];
			headers.push( new URLRequestHeader( "Authorization", "token " + _token ) );
			headers.push( new URLRequestHeader( "Content-Type", "application/json" ) );
			
			var req:URLRequest = new URLRequest();
			req.requestHeaders = headers;
			req.method = URLRequestMethod.POST;
			req.url = endpoint + "/api/packages/" + packageDef.packageDef.identifier + "/update";
			req.data = JSON.stringify( {
										   packageDef: packageDef.toObject( true, true ),
										   readme:     packageDef.readme,
										   changelog:  packageDef.changelog
									   } );
			
			_requestQueue.add( req, "publish", function ( success:Boolean, data:* ):void {
				
				if (callback != null)
				{
					callback( success, data );
				}
			} );
		}
		
	}
}
