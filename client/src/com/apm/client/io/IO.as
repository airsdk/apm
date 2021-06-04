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
package com.apm.client.io
{
	import flash.system.System;
	import flash.utils.clearInterval;
	import flash.utils.setInterval;
	
	
	/**
	 * This class handles all the output to the terminal particularly around
	 * being able to display visual features such as spinners / progress bars
	 * and handling input from the user (questions etc).
	 */
	public class IO
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "IO";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _colourSupported:Boolean = false;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function IO()
		{
		}
		
		
		public function setColourSupported( supported:Boolean ):void
		{
			_colourSupported = supported;
		}
		
		
		public function writeLine( s:String ):void
		{
			out( s + "\n" );
		}
		
		
		public function out( s:String ):void
		{
			System.output( s );
//			trace( s );
		}
		
		
		public function input( s:String = null ):String
		{
			return System.input();
		}
		
		
		public function question( question:String, defaultResponse:String = null ):String
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
		
		
		public function error( e:Error ):void
		{
			System.output( "ERROR: " + e.message + "\n" );
		}
		
		
		//
		//	UI elements
		//
		
		private var _current:String = "";
		
		
		public function setCurrentLineDisplay( s:String ):void
		{
			System.output( s );
		}
		
		
		// https://askubuntu.com/questions/831971/what-type-of-sequences-are-escape-sequences-starting-with-033
		
		
		public function showSpinner( message:String = "" ):void
		{
			_spinnerMessage = message;
			_spinnerInterval = setInterval( spinner_render, 150 );
		}
		
		
		public function stopSpinner( success:Boolean, message:String="" ):void
		{
			clearInterval( _spinnerInterval );

			System.output( "\x1B[1A\x1B[K" +
								   (success ? _successChar : _failedChar) +
								   " " + message );
			for (var i:int = 0; i < _spinnerMessage.length - message.length; i++) System.output( " " );
			System.output( "\n\n" );
		}
		
		
		private var _spinnerInterval:int;
		private var _spinnerSequence:Array = ["⣾", "⣽", "⣻", "⢿", "⡿", "⣟", "⣯", "⣷"];
		
		private var _spinnerComplete:String = "⣿";
		private var _successChar:String = "\u2713";
		private var _failedChar:String = "\u2717";
//		private var _spinnerSequence:Array = [ "|", "\\", "-", "/" ];
		private var _spinnerIndex:int = 0;
		private var _spinnerMessage:String;
		
		private function spinner_render():void
		{
			if (_spinnerIndex >= _spinnerSequence.length) _spinnerIndex = 0;
			if (_colourSupported)
				System.output( "\x1B[1;31m\x1B[1A\x1B[K" + _spinnerSequence[ _spinnerIndex++ ] + " \x1B[0;37m" + _spinnerMessage + "\n" );
			else
				System.output( "\x1B[1A\x1B[K" + _spinnerSequence[ _spinnerIndex++ ] + " " + _spinnerMessage + "\n" );
		}
		
		
	}
	
}
