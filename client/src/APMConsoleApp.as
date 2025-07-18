/**
 * @author 		Michael Archbold (https://michaelarchbold.com)
 * @created		18/5/2021
 */
package
{
	import com.apm.client.APM;
	import com.apm.client.events.APMEvent;
	
	import flash.desktop.NativeApplication;
	import flash.desktop.SystemIdleMode;
	import flash.display.Sprite;
	import flash.events.InvokeEvent;
	import flash.system.System;
	import flash.utils.setInterval;
	
	
	public class APMConsoleApp extends Sprite
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "APMConsoleApp";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		
		protected var apmContext:APM;
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		
		public function APMConsoleApp()
		{
			apmContext = new APM();
			
			NativeApplication.nativeApplication.executeInBackground = true;
			NativeApplication.nativeApplication.systemIdleMode = SystemIdleMode.KEEP_AWAKE;
			NativeApplication.nativeApplication.idleThreshold = 86400;
			
			NativeApplication.nativeApplication.addEventListener( InvokeEvent.INVOKE, invokeHandler );
		}
		
		
		private function invokeHandler( event:InvokeEvent ):void
		{
			apmContext.main( event.arguments );
		}
		
		
	}
	
}
