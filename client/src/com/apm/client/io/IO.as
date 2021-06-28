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
		
		
		public function writeResult( success:Boolean, message:String ):void
		{
			out( (success ? _successChar : _failedChar) + " " + message + "\n" );
		}
		
		
		public function writeError( tag:String, message:String ):void
		{
			if (_colourSupported)
			{
				out( "\x1B[1;31m" + tag + "\x1B[0;37m :: " + message + "\n");
			}
			else
			{
				out( tag + " :: " + message + "\n" );
			}
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
		
		
		// https://askubuntu.com/questions/831971/what-type-of-sequences-are-escape-sequences-starting-with-033
		// https://stackoverflow.com/questions/2616906/how-do-i-output-coloured-text-to-a-linux-terminal
		// https://github.com/sindresorhus/cli-spinners/blob/HEAD/spinners.json
		
		
		public function showSpinner( message:String = "" ):void
		{
			_spinnerMessage = message;
			spinner_render( true );
			_spinnerInterval = setInterval( spinner_render, 250 );
		}
		
		
		public function updateSpinner( message:String="" ):void
		{
			_spinnerMessage = message;
		}
		
		
		public function stopSpinner( success:Boolean, message:String = "", removeSpinner:Boolean=false ):void
		{
			clearInterval( _spinnerInterval );
			
			if (removeSpinner)
			{
				System.output( "\x1B[1A\x1B[K \n\x1B[1A" );
			}
			else
			{
				System.output( "\x1B[1A\x1B[K" +
									   (success ? _successChar : _failedChar) +
									   " " + message );
				
				var whitespace:String = "";
				for (var i:int = 0; i < _spinnerMessage.length - message.length; i++) whitespace += " ";
				System.output( whitespace + "\n" );
			}
		}
		
		
		private var _spinnerInterval:int;
		private var _spinnerSequence:Array = ["⣾", "⣽", "⣻", "⢿", "⡿", "⣟", "⣯", "⣷"];
		private var _spinnerComplete:String = "⣿";
		private var _successChar:String = "\u2713";
		private var _failedChar:String = "\u2717";
		private var _spinnerIndex:int = 0;
		private var _spinnerMessage:String;
		
		private function spinner_render( initial:Boolean = false ):void
		{
			if (_spinnerIndex >= _spinnerSequence.length) _spinnerIndex = 0;
			var output:String = "";
			if (!initial)
			{
				output += "\x1B[1A\x1B[K";
			}
			if (_colourSupported)
			{
				output += "\x1B[1;31m" + _spinnerSequence[ _spinnerIndex++ ] + " \x1B[0;37m" + _spinnerMessage + "\n";
			}
			else
			{
				output += _spinnerSequence[ _spinnerIndex++ ] + " " + _spinnerMessage + "\n";
			}
			System.output( output );
		}
		
		
		//
		//	PROGRESS BAR
		//
		
		
		public function showProgressBar( message:String = "" ):void
		{
			System.output( message + "\n" );
		}
		
		
		public function updateProgressBar( progress:Number, message:String = "" ):void
		{
			var percent:int = int(Math.floor(progress * 100));
			System.output( "\x1B[1A\x1B[K" + percent + "% " + message + "\n" );
		}
		
		
		public function completeProgressBar( success:Boolean, message:String = "" ):void
		{
			System.output( "\x1B[1A\x1B[K" + (success ? _successChar : _failedChar) + " " + message + "\n" );
		}
		
		
	}
	
}
