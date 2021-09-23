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
package com.apm.client.commands.packages
{
	import com.apm.client.APM;
	import com.apm.client.commands.Command;
	import com.apm.client.commands.packages.processes.PackageContentCreateProcess;
	import com.apm.client.commands.packages.processes.PackageContentVerifyProcess;
	import com.apm.client.commands.packages.processes.PackageDependenciesVerifyProcess;
	import com.apm.client.commands.packages.processes.ViewPackageProcess;
	import com.apm.client.events.CommandEvent;
	import com.apm.client.processes.ProcessQueue;
	
	import flash.events.EventDispatcher;
	
	import flash.filesystem.File;
	
	
	public class BuildCommand extends EventDispatcher implements Command
	{
		
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "BuildCommand";
		
		public static const NAME:String = "build";
		
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _parameters:Array;
		private var _queue:ProcessQueue;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function BuildCommand()
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
			return "build a package directory into an airpackage";
		}
		
		
		public function get usage():String
		{
			return description + "\n" +
					"\n" +
					"apm build          build a package in the current directory\n" +
					"apm build <foo>    build a package in a directory named <foo>\n";
		}
		
		
		public function execute():void
		{
			var path:String = "";
			if (_parameters != null && _parameters.length > 0)
			{
				path = _parameters[0];
			}
			
			APM.io.writeLine( "Building package" );
			
			var packageDir:File = new File( APM.config.workingDir + File.separator + path );
			
			_queue.addProcess( new PackageContentVerifyProcess( packageDir ));
			_queue.addProcess( new PackageContentCreateProcess( packageDir ));
			
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
