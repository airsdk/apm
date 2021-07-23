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
	import flash.events.Event;
	
	
	public class CommandEvent extends Event
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "CommandEvent";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function CommandEvent( type:String, bubbles:Boolean, cancelable:Boolean )
		{
			super( type, bubbles, cancelable );
		}
		
		
		override public function clone():Event
		{
			return new CommandEvent( type, bubbles, cancelable );
		}
		
	}
}
