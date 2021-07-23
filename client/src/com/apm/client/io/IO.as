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
		
		function setTerminalControlSupported( supported:Boolean ):void;
		
		function setColourSupported( supported:Boolean ):void;
		
		function writeLine( s:String ):void;
		
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
		
		function updateSpinner( message:String="" ):void;
		
		function stopSpinner( success:Boolean, message:String = "", removeSpinner:Boolean=false ):void;
		
		
		//
		//	PROGRESS BAR
		//
		
		function showProgressBar( message:String = "" ):void;
		
		function updateProgressBar( progress:Number, message:String = "" ):void;
		
		function completeProgressBar( success:Boolean, message:String = "" ):void;
		
		
	}
	
}
