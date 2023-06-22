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
 * @created		18/5/2021
 */
package com.apm.client.commands.packages
{
	import com.apm.client.APM;
	import com.apm.client.commands.Command;
	import com.apm.client.commands.packages.processes.PackageDefinitionCreateProcess;
	import com.apm.client.commands.packages.processes.ViewPackageProcess;
	import com.apm.client.events.CommandEvent;
	import com.apm.client.processes.ProcessQueue;
	
	import flash.events.EventDispatcher;
	
	
	public class CreateCommand extends EventDispatcher implements Command
	{
		
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "CreateCommand";
		
		public static const NAME:String = "create";
		
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _parameters:Array;
		private var _queue:ProcessQueue;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function CreateCommand()
		{
			super();
			_queue = new ProcessQueue();
		}
		
		
		public function setParameters( parameters:Array ):void
		{
			_parameters = parameters;
		}
		
		
		public function get name():String
		{
			return NAME;
		}
		
		
		public function get category():String
		{
			return "";
		}
		
		
		public function get requiresNetwork():Boolean
		{
			return false;
		}
		
		
		public function get requiresProject():Boolean
		{
			return false;
		}
		
		
		public function get description():String
		{
			return "create a package template for a new package in the repository";
		}
		
		
		public function get usage():String
		{
			return description + "\n" +
					"\n" +
					"apm create          creates a template package in the current directory\n" +
					"apm create <foo>    creates a template package in the <foo> sub-directory\n";
		}
		
		
		public function execute():void
		{
			var name:String = "";
			if (_parameters != null && _parameters.length > 0)
			{
				name = _parameters[0];
			}
			
			_queue.addProcess( new PackageDefinitionCreateProcess( name ));
			
			_queue.start(
					function ():void
					{
						dispatchEvent( new CommandEvent( CommandEvent.COMPLETE, APM.CODE_OK ));
					},
					function ( message:String ):void
					{
						dispatchEvent( new CommandEvent( CommandEvent.COMPLETE, APM.CODE_ERROR ));
					}
			);
		}
		
	}
	
}
