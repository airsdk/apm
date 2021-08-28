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
	import com.apm.client.APM;
	import com.apm.utils.FileUtils;
	import com.apm.utils.PackageFileUtils;
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
		
		private var _packageDir:File;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function PackageContentVerifyProcess( packageDir:File )
		{
			_packageDir = packageDir;
		}
		
		
		override public function start( completeCallback:Function = null, failureCallback:Function = null ):void
		{
			super.start( completeCallback, failureCallback );
			if (!_packageDir.exists || !_packageDir.isDirectory)
			{
				return fail( _packageDir.name, "Specified package directory does not exist" );
			}

			var packageDefinitionFile:File = _packageDir.resolvePath( PackageDefinitionFile.DEFAULT_FILENAME );
			if (!packageDefinitionFile.exists)
			{
				return fail( PackageDefinitionFile.DEFAULT_FILENAME, "Package definition file does not exist" );
			}
			
			var f:PackageDefinitionFile = new PackageDefinitionFile().load( packageDefinitionFile );
			
			APM.io.writeLine( "- identifier:  " + f.packageDef.identifier );
			APM.io.writeLine( "- name:        " + f.packageDef.name );
			APM.io.writeLine( "- description: " + f.packageDef.description );
			APM.io.writeLine( "- type:        " + f.packageDef.type );
			APM.io.writeLine( "- tags:        " + f.packageDef.tags.join(",") );
			APM.io.writeLine( "- version:     " + (f.version == null ? "null" : f.version.toString()) );
			APM.io.writeLine( "- sourceUrl:   " + f.version.sourceUrl );
			
			
			
			APM.io.showSpinner(  "Verifying package content" );

			if (f.packageDef.identifier.length <= 5)
			{
				return fail( PackageDefinitionFile.DEFAULT_FILENAME, "identifier should be at least 5 characters" );
			}
			if (f.packageDef.description.length == 0)
			{
				return fail( PackageDefinitionFile.DEFAULT_FILENAME, "You must provide a package description" );
			}
			if (f.packageDef.name.length == 0)
			{
				return fail( PackageDefinitionFile.DEFAULT_FILENAME, "You must provide a package name" );
			}
			if (f.packageDef.type != PackageDefinition.TYPE_ANE && f.packageDef.type != PackageDefinition.TYPE_SWC && f.packageDef.type != PackageDefinition.TYPE_SRC)
			{
				return fail( PackageDefinitionFile.DEFAULT_FILENAME, "type must be one of 'ane', 'swc' or 'src'" );
			}
			if (f.version.version == null)
			{
				return fail( PackageDefinitionFile.DEFAULT_FILENAME, "Version must follow semantic versioning" );
			}
			if (f.version.sourceUrl.length == 0)
			{
				return fail( PackageDefinitionFile.DEFAULT_FILENAME, "You must provide a source url for your package version" );
			}
			
			var readmeFile:File = _packageDir.resolvePath( "README.md" );
			if (!readmeFile.exists)
			{
				return fail( "README", "Package readme file does not exist" );
			}
			
			
			// Ensure has some appropriate content
			switch (f.packageDef.type)
			{
				case PackageDefinition.TYPE_ANE:
					var aneDir:File = _packageDir.resolvePath( PackageFileUtils.AIRPACKAGE_ANE_DIR );
					if (!aneDir.exists || FileUtils.countFilesByType( aneDir, "ane") == 0)
					{
						return fail( "CONTENT", "No 'ane' file found in the '" + PackageFileUtils.AIRPACKAGE_ANE_DIR + "' directory" );
					}
					break;
				case PackageDefinition.TYPE_SWC:
					var libDir:File = _packageDir.resolvePath( PackageFileUtils.AIRPACKAGE_SWC_DIR );
					if (!libDir.exists || FileUtils.countFilesByType( libDir, "swc") == 0)
					{
						return fail( "CONTENT", "No 'swc' file found in the '" + PackageFileUtils.AIRPACKAGE_SWC_DIR + "' directory" );
					}
					break;
				case PackageDefinition.TYPE_SRC:
					var srcDir:File = _packageDir.resolvePath( PackageFileUtils.AIRPACKAGE_SRC_DIR );
					if (!srcDir.exists || FileUtils.countFilesByType( srcDir, "as") == 0)
					{
						return fail( "CONTENT", "No 'as' files found in the '" + PackageFileUtils.AIRPACKAGE_SRC_DIR + "' directory" );
					}
					break;
			}
			
//			var changeLogFile:File = _packageDir.resolvePath( "CHANGELOG.md" );
//			var licenseFile:File = _packageDir.resolvePath( "LICENSE.md" );
			
			// TODO:: Other checks
			
			APM.io.stopSpinner(  true,"Package content verified" );
			complete();
		}
		
		
		private function fail( tag:String, message:String ):void
		{
			APM.io.stopSpinner(  false,"Invalid" );
			APM.io.writeError( tag, message );
			return failure( message );
		}
		
		
	}
	
}
