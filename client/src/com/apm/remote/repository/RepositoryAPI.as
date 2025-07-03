/**
 * @author 		Michael Archbold (https://michaelarchbold.com)
 * @created		18/5/2021
 */
package com.apm.remote.repository
{
	import com.apm.SemVer;
	import com.apm.SemVerRange;
	import com.apm.data.packages.PackageDefinition;
	import com.apm.data.packages.PackageDefinitionFile;
	import com.apm.remote.lib.APIRequestQueue;
	
	import flash.events.EventDispatcher;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	
	public class RepositoryAPI extends EventDispatcher implements Repository
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "RepositoryAPI";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _name:String;
		/**
		 * The name (source name) of this repository
		 */
		public function get name():String  { return _name; }
		public function set name( value:String ):void { _name = value; }
		
		
		private var _endpoint:String;
		/**
		 * The url endpoint
		 */
		public function get endpoint():String { return _endpoint; }
		public function set endpoint( endpoint:String ):void { this._endpoint = endpoint; }
		
		
		// Auth token for publish actions
		private var _token:String;
		
		
		private var _requestQueue:APIRequestQueue;

		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function RepositoryAPI( endpoint:String )
		{
			super();
			_requestQueue = new APIRequestQueue();
			_endpoint = endpoint;
		}
		
		
		public function setName( name:String ):Repository
		{
			_name = name;
			return this;
		}
		
		
		public function setToken( token:String ):Repository
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
			req.url = _endpoint + "/api/packages/" + identifier + "/" + version + "/analytics/" + event;
			req.data = vars;
			
			_requestQueue.add( req, "analytics", function ( success:Boolean, data:* ):void {
				if (callback != null)
				{
					callback();
				}
			} );
		}
		
		
		public function search( query:String, options:RepositoryQueryOptions = null, callback:Function = null ):void
		{
			var vars:URLVariables = new URLVariables();
			vars[ "q" ] = query;
//			vars[ "t" ] = request;
			
			if (options != null) options.apply( vars );
			
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
		
		
		public function getPackage( identifier:String, options:RepositoryQueryOptions = null, callback:Function = null ):void
		{
			var vars:URLVariables = new URLVariables();
			
			if (options != null) options.apply( vars );
			
			var req:URLRequest = new URLRequest();
			req.method = URLRequestMethod.GET;
			req.url = _endpoint + "/api/packages/" + identifier;
			req.data = vars;
			
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
		
		
		public function getPackageVersion( identifier:String, version:SemVerRange, options:RepositoryQueryOptions = null, callback:Function = null ):void
		{
			var vars:URLVariables = new URLVariables();
			
			if (options != null) options.apply( vars );
			
			var req:URLRequest = new URLRequest();
			req.method = URLRequestMethod.GET;
			req.url = _endpoint + "/api/packages/" + identifier + "/" + (version == null ? "latest" : version.toString());
			req.data = vars;
			
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
			req.url = _endpoint + "/api/packages/" + packageDef.packageDef.identifier + "/update";
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
