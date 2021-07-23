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
	
	import flash.events.EventDispatcher;
	import flash.net.URLRequest;
	import flash.utils.setTimeout;
	
	
	public class APIRequestQueue extends EventDispatcher
	{
 		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		public static const TAG : String = "APIRequestQueue";
		
		
 		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _queue  : Vector.<APIRequest>;

		private var _currentRequest : APIRequest;
		
		
 		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function APIRequestQueue()
		{
			_queue = new Vector.<APIRequest>();
		}
		
		
		public function add( request:URLRequest, id:String, callback:Function=null, maxAttempts:int=2 ):void
		{
			_queue.push( new APIRequest( request, id, callback, maxAttempts ) );
			checkQueue();
		}
		
		
		private function checkQueue():void
		{
			if (_queue.length > 0)
			{
				if (_currentRequest == null)
				{
					_currentRequest = _queue.shift();
					_currentRequest.addEventListener( APIRequestEvent.COMPLETE, request_completeHandler );
					_currentRequest.addEventListener( APIRequestEvent.STATUS, request_statusHandler );
					_currentRequest.addEventListener( APIRequestEvent.ERROR, request_errorHandler );
					_currentRequest.start();
				}
			}
		}
		
		
		private function completeRequest():void
		{
			var request:APIRequest = _currentRequest;
			if (request != null)
			{
				request.dispose();
				request.removeEventListener( APIRequestEvent.COMPLETE, request_completeHandler );
				request.removeEventListener( APIRequestEvent.STATUS, request_statusHandler );
				request.removeEventListener( APIRequestEvent.ERROR, request_errorHandler );
			}
			_currentRequest = null;

			checkQueue();
			
			if (request != null)
			{
				request.triggerCallback();
			}
		}
		
		
		
		////////////////////////////////////////////////////////
		//  EVENT HANDLERS
		//
		
		private function request_completeHandler( event:APIRequestEvent ):void
		{
			dispatchEvent( event.clone() );
			completeRequest();
		}
		
		
		private function request_statusHandler( event:APIRequestEvent ):void
		{
			dispatchEvent( event.clone() );
		}
		
		
		private function request_errorHandler( event:APIRequestEvent ):void
		{
			if (_currentRequest.attemptCount < _currentRequest.maxAttempts)
			{
				setTimeout( function():void {
					_currentRequest.start();
				}, 500 * _currentRequest.attemptCount );
			}
			else
			{
				dispatchEvent( event.clone() );
				completeRequest();
			}
		}
		
		
	}
	
}
