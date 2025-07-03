/**
 * @author 		Michael Archbold (https://michaelarchbold.com)
 * @created		22/6/2021
 */
package com.apm.client.processes
{
	
	public class ProcessCallback extends ProcessBase
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "ProcessCallback";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _callback:Function;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function ProcessCallback( callback:Function )
		{
			super();
			_callback = callback;
		}
		
		
		override public function start( completeCallback:Function=null, failureCallback:Function=null ):void
		{
			if (_callback != null) _callback();
			complete();
		}
		
	}
	
}
