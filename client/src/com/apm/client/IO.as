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
package com.apm.client
{
	import flash.system.System;
	
	
	public class IO
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "IO";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function IO()
		{
		}
		
		
		public static function writeLine( s:String ):void
		{
			out( s + "\n" );
		}
		
		
		public static function out( s:String ):void
		{
			System.output( s );
//			trace( s );
		}
		
		
		public static function input( s:String = null ):String
		{
			return System.input();
		}
		
		
		public static function question( question:String, defaultResponse:String = null ):String
		{
			if (defaultResponse != null)
				out( question + " [" + defaultResponse + "]: " );
			else
				out( question + ": " );
			
			var resp:String = input();
			if (resp.length == 0 && defaultResponse != null)
				resp = defaultResponse;
			return resp;
		}
		
		
		public static function error( e:Error ):void
		{
			System.output( "ERROR: " + e.message + "\n" );
		}
		
		
	}
}
