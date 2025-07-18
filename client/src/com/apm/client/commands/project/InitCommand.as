/**
 * @author 		Michael Archbold (https://michaelarchbold.com)
 * @created		18/5/2021
 */
package com.apm.client.commands.project
{
	import com.apm.client.APM;
	import com.apm.client.commands.Command;
	import com.apm.client.commands.project.processes.ProjectDefinitionCreateProcess;
	import com.apm.client.commands.project.processes.ProjectDefinitionImportProcess;
	import com.apm.client.events.CommandEvent;
	import com.apm.client.logging.Log;
	import com.apm.client.processes.ProcessQueue;
	import com.apm.utils.FileUtils;
	
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	
	
	public class InitCommand extends EventDispatcher implements Command
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
		
		
		public function get requiresProject():Boolean
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
				   "apm init                             initialise a new apm project file for your application\n" +
				   "apm init <path/app-descriptor.xml>   initialise a new apm project file from an existing application descriptor\n"
		}
		
		
		public function execute():void
		{
			Log.d( TAG, "execute(): " + (_parameters.length > 0 ? _parameters[ 0 ] : "...") + "\n" );
			try
			{
				var importAppDescriptor:File = null;
				if (_parameters.length > 0)
				{
					var path:String = _parameters[ 0 ];
					importAppDescriptor = FileUtils.getSourceForPath( path );
				}
				
				if (importAppDescriptor != null && importAppDescriptor.exists)
				{
					// Load the app descriptor and create a project file from the contents
					_queue.addProcess( new ProjectDefinitionImportProcess( importAppDescriptor ) );
				}
				else
				{
					_queue.addProcess( new ProjectDefinitionCreateProcess() );
				}
				
				_queue.start(
						function ():void
						{
							dispatchEvent( new CommandEvent( CommandEvent.COMPLETE, APM.CODE_OK ) );
						},
						function ( error:String ):void
						{
							APM.io.writeError( NAME, error );
							dispatchEvent( new CommandEvent( CommandEvent.COMPLETE, APM.CODE_ERROR ) );
						}
				);
			}
			catch (e:Error)
			{
				APM.io.error( e );
				dispatchEvent( new CommandEvent( CommandEvent.COMPLETE, APM.CODE_ERROR ) );
			}
		}
		
		
	}
	
	
}
