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
package com.apm.client.commands.project
{
	import com.apm.client.APMCore;
	import com.apm.client.commands.Command;
	import com.apm.client.commands.project.processes.ProjectDefinitionCreateProcess;
	import com.apm.client.logging.Log;
	import com.apm.client.processes.ProcessQueue;
	
	
	public class InitCommand implements Command
	{
		
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "InitCommand";
		
		
		public static const NAME:String = "init";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _parameters:Array;
		private var _queue:ProcessQueue;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function InitCommand()
		{
			super();
			_parameters = [];
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
		
		
		public function get description():String
		{
			return "initialise a new apm project file for your application";
		}
		
		
		public function get usage():String
		{
			return description + "\n" +
					"\n" +
					"apm init          initialise a new apm project file for your application\n"
		}
		
		
		public function execute( core:APMCore ):void
		{
			Log.d( TAG, "execute(): " + (_parameters.length > 0 ? _parameters[ 0 ] : "...") + "\n" );
			try
			{
				_queue.addProcess( new ProjectDefinitionCreateProcess( core ) );
				_queue.start( function ():void {
					core.exit( APMCore.CODE_OK );
				} );
			}
			catch (e:Error)
			{
				core.io.error( e );
			}
		}
		
		
	}
	
	
}
