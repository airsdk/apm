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
	
	import flash.desktop.NativeApplication;
	import flash.events.InvokeEvent;
	
	
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
		}
		
		
		private function invokeHandler( event:InvokeEvent ):void
		{
			var returnCode:int = main( event.arguments );
			
			NativeApplication.nativeApplication.exit( returnCode );
		}
		
	}
	
}
