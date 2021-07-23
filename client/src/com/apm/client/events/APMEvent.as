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
 * @created		28/5/21
 */
package com.apm.client.events
{
	import flash.events.DataEvent;
	import flash.events.Event;
	
	
	public class APMEvent extends DataEvent
	{
		
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "APMEvent";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		
		public function APMEvent( type:String, bubbles:Boolean=false, cancelable:Boolean=false, data:String = "" )
		{
			super( type, bubbles, cancelable, data );
		}
		
		
		override public function clone():Event
		{
			return new APMEvent( type, bubbles, cancelable, data );
		}
		
		
	}
	
}
