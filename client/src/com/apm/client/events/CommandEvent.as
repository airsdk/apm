/**
 * @author 		Michael Archbold (https://michaelarchbold.com)
 * @created		28/5/2021
 */
package com.apm.client.events
{
	import flash.events.Event;
	
	
	public class CommandEvent extends Event
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "CommandEvent";
		
		
		/**
		 * @eventType complete
		 */
		public static const COMPLETE : String = "complete";
		
		
		/**
		 * @eventType usage
		 */
		public static const PRINT_USAGE : String = "usage";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		
		public var data:* = null;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function CommandEvent( type:String, data:*=null, bubbles:Boolean=false, cancelable:Boolean=false )
		{
			super( type, bubbles, cancelable );
			this.data = data;
		}
		
		
		override public function clone():Event
		{
			return new CommandEvent( type, data, bubbles, cancelable );
		}
		
	}
}
