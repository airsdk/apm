/**
 * @author 		Michael Archbold (https://michaelarchbold.com)
 * @created		18/5/2021
 */
package com.apm.client.commands
{
	import com.apm.client.*;
	
	import flash.events.IEventDispatcher;
	
	
	public interface Command extends IEventDispatcher
	{
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		/**
		 * Starts the command execution with the current core configuration
		 */
		function execute():void;
		
		
		/**
		 * Sets the command line parameters passed for this command
		 *
		 * @param parameters
		 */
		function setParameters( parameters:Array ):void;
		
		
		function get name():String;
		
		function get category():String;
		
		function get description():String;
		
		function get usage():String;
		
		
		/**
		 * Whether this command access the network, eg package repository api or the air sdk api
		 */
		function get requiresNetwork():Boolean;
		
		
		/**
		 * Whether this command needs a project file
		 */
		function get requiresProject():Boolean;
		
		
		
	}
	
}
