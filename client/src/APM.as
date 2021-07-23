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
package
{
	import com.apm.client.APMCore;
	import com.apm.client.events.APMEvent;
	
	import flash.desktop.NativeApplication;
	import flash.desktop.SystemIdleMode;
	import flash.events.InvokeEvent;
	import flash.system.System;
	import flash.utils.setInterval;
	
	
	public class APM extends APMCore
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "APM";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		
		public function APM()
		{
			NativeApplication.nativeApplication.addEventListener( InvokeEvent.INVOKE, invokeHandler );
			
			NativeApplication.nativeApplication.executeInBackground = true;
			NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.KEEP_AWAKE;
			NativeApplication.nativeApplication.idleThreshold = 86400;
		}
		
		
		private function invokeHandler( event:InvokeEvent ):void
		{
			main( event.arguments );
		}
		
		
	}
	
}
