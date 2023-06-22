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
 * @created		7/6/2021
 */
package com.apm.remote.airsdk.events
{
	import flash.events.Event;
	
	
	public class AIRSDKAPIEvent extends Event
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "AIRSDKAPIEvent";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		
		public function AIRSDKAPIEvent( type:String, bubbles:Boolean = false, cancelable:Boolean = false )
		{
			super( type, bubbles, cancelable );
		}
		
		
		override public function clone():Event
		{
			return new AIRSDKAPIEvent( type, bubbles, cancelable );
		}
		
		
		
		
		
		
		
		
	}
}
