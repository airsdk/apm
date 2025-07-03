/**
 * @author 		Michael Archbold (https://michaelarchbold.com)
 * @created		28/5/2021
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
