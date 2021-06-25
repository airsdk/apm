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
	import com.apm.SemVer;
	import com.apm.client.APMCore;
	import com.apm.client.commands.packages.utils.FileUtils;
	import com.apm.client.processes.ProcessBase;
	import com.apm.data.packages.PackageDefinition;
	import com.apm.data.packages.PackageDefinitionFile;
	import com.apm.data.packages.PackageVersion;
	import com.apm.data.project.ProjectDefinition;
	
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	
	/**
	 * Verifies the content for a package structure in the specified path.
	 * <br/>
	 * The process will check the content for the package is valid and fail if not.
	 */
	public class PackageContentVerifyProcess extends ProcessBase
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "PackageDefinitionCreateProcess";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _core:APMCore;
		private var _path:String;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function PackageContentVerifyProcess( core:APMCore, path:String )
		{
			_core = core;
			_path = path;
		}
		
		
		override public function start():void
		{
			_core.io.showSpinner(  "Verifying package content" );
			
			var directory:File = new File( _core.config.workingDir + File.separator + _path );
			if (!directory.exists)
			{
				return failure( "Specified package directory does not exist" );
			}

			var packageDefinitionFile:File = directory.resolvePath( PackageDefinitionFile.DEFAULT_FILENAME );
			if (!packageDefinitionFile.exists)
			{
				_core.io.writeError( PackageDefinitionFile.DEFAULT_FILENAME, "Package definition file does not exist" );
				return failure();
			}
			
			var f:PackageDefinitionFile = new PackageDefinitionFile().load( packageDefinitionFile );
			if (f.packageDef.identifier.length <= 5)
			{
				_core.io.writeError( PackageDefinitionFile.DEFAULT_FILENAME, "identifier should be at least 5 characters" );
				return failure();
			}
			if (f.packageDef.description.length == 0)
			{
				_core.io.writeError( PackageDefinitionFile.DEFAULT_FILENAME, "You must provide a package description" );
				return failure();
			}
			if (f.packageDef.description.length == 0)
			{
				_core.io.writeError( PackageDefinitionFile.DEFAULT_FILENAME, "You must provide a package name" );
				return failure();
			}
			if (f.packageDef.type != "swc" && f.packageDef.type != "ane" && f.packageDef.type != "src")
			{
				_core.io.writeError( PackageDefinitionFile.DEFAULT_FILENAME, "type must be one of 'ane', 'swc' or 'src'" );
				return failure();
			}
			if (f.version.version == null)
			{
				_core.io.writeError( PackageDefinitionFile.DEFAULT_FILENAME, "Version must follow semantic versioning" );
				return failure();
			}
			
			var readmeFile:File = directory.resolvePath( "README.md" );
			if (!readmeFile.exists)
			{
				_core.io.writeError( "README", "Package readme file does not exist" );
				return failure();
			}
			
			
			// Ensure has some appropriate content
			switch (f.packageDef.type)
			{
				case "ane":
					var aneDir:File = directory.resolvePath( "ane" );
					if (!aneDir.exists || FileUtils.countFilesByType( aneDir, "ane") == 0)
					{
						_core.io.writeError( "CONTENT", "No 'ane' file found in the 'ane' directory" );
						return failure();
					}
					break;
				case "swc":
					var libDir:File = directory.resolvePath( "lib" );
					if (!libDir.exists || FileUtils.countFilesByType( libDir, "swc") == 0)
					{
						_core.io.writeError( "CONTENT", "No 'swc' file found in the 'lib' directory" );
						return failure();
					}
					break;
				case "src":
					var srcDir:File = directory.resolvePath( "src" );
					if (!srcDir.exists || FileUtils.countFilesByType( srcDir, "as") == 0)
					{
						_core.io.writeError( "CONTENT", "No 'as' files found in the 'src' directory" );
						return failure();
					}
					break;
			}
			
			
			var changeLogFile:File = directory.resolvePath( "CHANGELOG.md" );
			var licenseFile:File = directory.resolvePath( "LICENSE.md" );
			
			
			// TODO:: Other checks
			
			_core.io.stopSpinner(  true,"Package content verified" );
			
			complete();
		}
		
		
		
		
		
		
	}
	
}
