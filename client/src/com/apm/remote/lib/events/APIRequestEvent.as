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
package com.apm.remote.lib.events
{
	import com.apm.remote.lib.APIRequest;
	
	import flash.events.Event;
	
	public class APIRequestEvent extends Event
	{
 		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		public static const TAG : String = "APIRequestEvent";
		
		public static const COMPLETE	: String = "complete";
		public static const STATUS  	: String = "status";
		public static const ERROR	   : String = "error";
		
		
 		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		
		public var request : APIRequest;
		
		public var data: *;
		
		
 		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function APIRequestEvent( type:String, request:APIRequest, data:*=null, bubbles:Boolean=false, cancelable:Boolean =false )
		{
			super( type, bubbles, cancelable );
			this.request = request;
			this.data = data;
		}
		
		
		override public function clone():Event
		{
			return new APIRequestEvent( type, request, data, bubbles, cancelable );
		}
		
		
	}
}
