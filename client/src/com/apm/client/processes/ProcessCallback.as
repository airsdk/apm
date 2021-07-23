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
 * @created		22/6/21
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
		
		
		override public function start():void
		{
			if (_callback != null) _callback();
			complete();
		}
		
	}
	
}
