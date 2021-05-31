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
package com.apm.client.commands
{
	import com.apm.client.*;
	
	
	public interface Command
	{
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		/**
		 * Starts the command execution with the current core configuration
		 *
		 * @param core
		 */
		function execute( core:APMCore ):void;
		
		
		/**
		 * Sets the command line parameters passed for this command
		 *
		 * @param parameters
		 */
		function setParameters( parameters:Array ):void;
		
		
		function get name():String;
		
		
		function get category():String;
		
		
		function get requiresNetwork():Boolean;
		
		
		function get description():String;
		
		
		function get usage():String;
		
		
	}
	
}
