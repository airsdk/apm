/**
 *		__	   __			   __
 *   ____/ /_ ____/ /______ _ ___  / /_
 *  / __  / / ___/ __/ ___/ / __ `/ __/
 * / /_/ / (__  ) / / /  / / /_/ / / 
 * \__,_/_/____/_/ /_/  /_/\__, /_/ 
 *						   / /
 *						   \/
 * http://distriqt.com
 *
 * @brief  		
 * @author 		"Michael Archbold (ma@distriqt.com)"
 * @created		7/12/16
 * @copyright	http://distriqt.com/copyright/license.txt
 */
package com.apm.remote.lib
{
	import com.apm.remote.lib.events.APIRequestEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	public class APIRequest extends EventDispatcher
	{
 		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		public static const TAG : String = "APIRequest";
		
		
 		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _request : URLRequest;
		private var _loader : URLLoader;
		
		private var _id : String;
		public function get id():String { return _id; }
		
		
		private var _attemptCount:int = 0;
		public function get attemptCount():int { return _attemptCount; }
		
		private var _maxAttempts:int = 1;
		public function get maxAttempts():int { return _maxAttempts; }
		
		private var _callback:Function = null;
		public function get callback():Function { return _callback; }
		
		private var _status:int = 0;
		public function get status():int { return _status; }
		
		private var _data:*;
		public function get data():* { return _data; }
		
		private var _success:Boolean = false;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function APIRequest( request:URLRequest, id:String, callback:Function=null, maxAttempts:int=2 )
		{
			_request = request;
			_id = id;
			_callback = callback;
			_maxAttempts = maxAttempts;
		}
	
		
		public function start():void
		{
			clearLoader();
			
			_success = false;
			
			_loader = new URLLoader();
			_loader.addEventListener( Event.COMPLETE, loader_completeHandler );
			_loader.addEventListener( ProgressEvent.PROGRESS, loader_progressHandler );
			_loader.addEventListener( IOErrorEvent.IO_ERROR, loader_errorHandler );
			_loader.addEventListener( HTTPStatusEvent.HTTP_STATUS, loader_statusHandler );
			_loader.addEventListener( SecurityErrorEvent.SECURITY_ERROR, loader_securityErrorHandler );
			_loader.load( _request );
			
			_attemptCount ++;
		}
	
		
		public function dispose():void
		{
			clearLoader();
		}
		
		
		public function triggerCallback():void
		{
			try
			{
				if (_callback != null)
				{
					_callback( _success, _data );
				}
				_callback = null;
			}
			catch (e:Error)
			{
			}
		}
		
		
		//
		//	INTERNALS
		//
	
		private function clearLoader():void
		{
			if (_loader != null)
			{
				_loader.removeEventListener( Event.COMPLETE, loader_completeHandler );
				_loader.removeEventListener( ProgressEvent.PROGRESS, loader_progressHandler );
				_loader.removeEventListener( IOErrorEvent.IO_ERROR, loader_errorHandler );
				_loader.removeEventListener( HTTPStatusEvent.HTTP_STATUS, loader_statusHandler );
				_loader.removeEventListener( SecurityErrorEvent.SECURITY_ERROR, loader_securityErrorHandler );
				_loader = null;
			}
		}
		
		
		////////////////////////////////////////////////////////
		//  EVENT HANDLERS
		//
		
		private function loader_completeHandler( event:Event ):void
		{
			_success = true;
			_data = _loader.data;
			dispatchEvent( new APIRequestEvent( APIRequestEvent.COMPLETE, this, _data ));
		}
		
		private function loader_progressHandler( event:ProgressEvent ):void
		{
		}
		
		private function loader_errorHandler( event:IOErrorEvent ):void
		{
			_data = _loader.data;
			dispatchEvent( new APIRequestEvent( APIRequestEvent.ERROR, this, event.text ));
		}
		
		private function loader_statusHandler( event:HTTPStatusEvent ):void
		{
			_status = event.status;
			dispatchEvent( new APIRequestEvent( APIRequestEvent.STATUS, this, event.status ));
		}
		
		private function loader_securityErrorHandler( event:SecurityErrorEvent ):void
		{
			_data = _loader.data;
			dispatchEvent( new APIRequestEvent( APIRequestEvent.ERROR, this, event.text ));
		}
		
		
		
	}
}
