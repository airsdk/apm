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
	import com.adobe.formatters.DateFormatter;
	import com.apm.SemVer;
	import com.apm.client.APMCore;
	import com.apm.client.commands.packages.utils.PackageFileUtils;
	import com.apm.client.processes.ProcessBase;
	import com.apm.data.packages.PackageDefinition;
	import com.apm.data.packages.PackageDefinitionFile;
	import com.apm.data.packages.PackageLicense;
	
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	
	/**
	 * Creates a package structure in the specified path.
	 * <br/>
	 * The process will ask for critical values to populate the package definition file.
	 */
	public class PackageDefinitionCreateProcess extends ProcessBase
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
		
		public function PackageDefinitionCreateProcess( core:APMCore, path:String )
		{
			_core = core;
			_path = path;
		}
		
		
		override public function start( completeCallback:Function = null, failureCallback:Function = null ):void
		{
			super.start( completeCallback, failureCallback );
			var directory:File = new File( _core.config.workingDir + File.separator + _path );
			if (!directory.exists) directory.createDirectory();
			
			
			_core.io.writeLine( "Creating new package definition file" );
			
			var f:PackageDefinitionFile = new PackageDefinitionFile();
			
			//
			//	Walk through any questions
			
			f.packageDef.name = _core.io.question( "Package Name", "My Package" );
			f.packageDef.identifier = _core.io.question( "Package Identifier", "com.my.package" );
			f.packageDef.type = _core.io.question( "Type [swc/ane/src]", "ane" );
			
			if (f.packageDef.type != PackageDefinition.TYPE_ANE && f.packageDef.type != PackageDefinition.TYPE_SWC && f.packageDef.type != PackageDefinition.TYPE_SRC)
			{
				_core.io.writeError( "INVALID TYPE", "Type must be one of 'ane', 'swc' or 'src'" );
				return failure();
			}
			
			f.version.version = SemVer.fromString(
					_core.io.question( "Package Version", "1.0.0" )
			);
			
			if (f.version.version == null)
			{
				_core.io.writeError( "INVALID VERSION", "Version must follow semantic versioning" );
				return failure();
			}
			
			
			// TODO:: Other questions ?
			
			
			
			//
			//	Some defaults
			
			f.packageDef.description = f.packageDef.name;
			f.packageDef.license = new PackageLicense();
			var df:DateFormatter = new DateFormatter( "YYYY-MM-DDT00:00:00.000Z")
			f.packageDef.publishedAt =
			f.version.publishedAt = df.format( new Date() );
			
			
			//
			// Write package to file
			
			f.save( directory.resolvePath( PackageDefinitionFile.DEFAULT_FILENAME ) );
			
			
			//
			//	Create README.md
			
			var readmeFile:File = directory.resolvePath( "README.md" );
			var readmeInitialContent:String =
						"## " + f.packageDef.name + "\n" +
						"\n" +
						"v" + f.version.version.toString() + "\n" +
						"--- \n" +
						f.packageDef.description + "\n\n"
			;
			
			writeContentToFile( readmeFile, readmeInitialContent );
			
			
			var changeLogFile:File = directory.resolvePath( "CHANGELOG.md" );
			writeContentToFile( changeLogFile, "" );

			
			var libDir:File = directory.resolvePath( PackageFileUtils.AIRPACKAGE_SWC_DIR );
			var aneDir:File = directory.resolvePath( PackageFileUtils.AIRPACKAGE_ANE_DIR );
			var srcDir:File = directory.resolvePath( PackageFileUtils.AIRPACKAGE_SRC_DIR );
			
			if (!libDir.exists) libDir.createDirectory();
			if (!aneDir.exists) aneDir.createDirectory();
			if (!srcDir.exists) srcDir.createDirectory();
			
			
			var assetsDir:File = directory.resolvePath( PackageFileUtils.AIRPACKAGE_ASSETS );
			if (!assetsDir.exists) assetsDir.createDirectory();
			
			assetsDir.resolvePath("common").createDirectory();
			assetsDir.resolvePath("android").createDirectory();
			assetsDir.resolvePath("ios").createDirectory();
			assetsDir.resolvePath("macos").createDirectory();
			assetsDir.resolvePath("windows").createDirectory();
			
			complete();
		}
		
		
		private function writeContentToFile( file:File, content:String ):void
		{
			var fs:FileStream = new FileStream();
			fs.open( file, FileMode.WRITE );
			fs.writeUTFBytes( content );
			fs.close();
		}
		
		
		
	}
	
}
