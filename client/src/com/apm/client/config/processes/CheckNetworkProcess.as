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
package com.apm.client.config.processes
{
	import com.apm.client.config.RunConfig;
	import com.apm.client.logging.Log;
	import com.apm.client.processes.ProcessBase;
	
	import flash.events.HTTPStatusEvent;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	
	
	/**
	 * Checks internet network connectivity
	 */
	public class CheckNetworkProcess extends ProcessBase
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "CheckNetworkProcess";
		
		private static const DEFAULT_URL:String = "https://google.com";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _config:RunConfig;
		
		private var _loader:URLLoader;
		
		private var _testUrl:String;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function CheckNetworkProcess( config:RunConfig, testUrl:String = DEFAULT_URL )
		{
			_config = config;
			_testUrl = testUrl;
		}
		
		
		override public function start( completeCallback:Function = null, failureCallback:Function = null ):void
		{
			super.start( completeCallback, failureCallback );
			Log.d( TAG, "start()" );
			try
			{
				_loader = new URLLoader();
				_loader.addEventListener( HTTPStatusEvent.HTTP_STATUS, statusHandler );
				_loader.load( new URLRequest( _testUrl ) );
			}
			catch (e:Error)
			{
			}
		}
		
		
		private function statusHandler( event:HTTPStatusEvent ):void
		{
			_config.hasNetwork = (event.status == 200);
			_loader.removeEventListener( HTTPStatusEvent.HTTP_STATUS, statusHandler );
			_loader.close();
			complete();
		}
		
	}
	
}
