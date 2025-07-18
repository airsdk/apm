/**
 * @author 		Michael Archbold (https://michaelarchbold.com)
 * @created		18/5/2021
 */
package com.apm.client.io
{
	
	/**
	 * This class handles all the output to the terminal particularly around
	 * being able to display visual features such as spinners / progress bars
	 * and handling input from the user (questions etc).
	 */
	public interface IO
	{
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		function get terminalControlSupported():Boolean;
		
		
		function set terminalControlSupported( value:Boolean ):void;
		
		
		function get colourSupported():Boolean;
		
		
		function set colourSupported( value:Boolean ):void;
		
		
		function set colourMode( value:String ):void;
		
		
		function writeLine( s:String, colour:String = null ):void;
		
		
		function writeValue( key:String, value:String ):void;
		
		
		function writeResult( success:Boolean, message:String ):void;
		
		
		function writeError( tag:String, message:String ):void;
		
		
		function out( s:String ):void;
		
		
		function input( s:String = null ):String;
		
		
		function question( question:String, defaultResponse:String = null ):String;
		
		
		function error( e:Error ):void;
		
		
		//
		//	UI elements
		//
		
		function showSpinner( message:String = "" ):void;
		
		
		function updateSpinner( message:String = "" ):void;
		
		
		function stopSpinner( success:Boolean, message:String = "", removeSpinner:Boolean = false ):void;
		
		
		//
		//	PROGRESS BAR
		//
		
		function showProgressBar( message:String = "" ):void;
		
		
		function updateProgressBar( progress:Number, message:String = "" ):void;
		
		
		function completeProgressBar( success:Boolean, message:String = "" ):void;
		
		
	}
	
}
