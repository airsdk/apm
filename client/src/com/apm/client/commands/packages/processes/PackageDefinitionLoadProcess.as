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
 * @created		15/6/21
 */
package com.apm.client.commands.packages.processes
{
	import com.apm.client.APMCore;
	import com.apm.client.processes.ProcessBase;
	import com.apm.data.packages.PackageDefinitionFile;
	
	import flash.filesystem.File;
	
	
	/**
	 * Loads a PackageDefinitionFile from a File reference.
	 * <br/>
	 * This process is really just for delaying the load until a point in the queue
	 * (generally when extracting a package from a zip).
	 */
	public class PackageDefinitionLoadProcess extends ProcessBase
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "PackageDefinitionLoadProcess";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _core:APMCore;
		private var _packageDefinition:PackageDefinitionFile;
		private var _file:File;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function PackageDefinitionLoadProcess( core:APMCore, packageDefinition:PackageDefinitionFile, file:File )
		{
			_core = core;
			_packageDefinition = packageDefinition;
			_file = file;
		}
		
		
		override public function start():void
		{
			_core.io.showSpinner( "Loading package definition file: " + _file.nativePath );
			if (!_file.exists)
			{
				_core.io.stopSpinner( false, "Package definition file doesn't exist: " + _file.nativePath );
				return failure();
			}
			
			_packageDefinition.load( _file );
			
			_core.io.stopSpinner( true, "Package definition file loaded" );
			complete();
		}
		
	}
	
}
