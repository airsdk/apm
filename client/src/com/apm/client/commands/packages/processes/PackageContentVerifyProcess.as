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
 * @created		15/6/2021
 */
package com.apm.client.commands.packages.processes
{
	import com.apm.client.APM;
	import com.apm.client.logging.Log;
	import com.apm.client.processes.ProcessBase;
	import com.apm.data.packages.PackageDefinition;
	import com.apm.data.packages.PackageDefinitionFile;
	import com.apm.data.packages.PackageIdentifier;
	import com.apm.data.packages.PackageIdentifier;
	import com.apm.utils.FileUtils;
	import com.apm.utils.PackageFileUtils;
	
	import flash.filesystem.File;
	
	
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
		
		private static const TAG:String = "PackageContentVerifyProcess";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _packageDir:File;
		private var _checkSourceUrl:Boolean;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		/**
		 * Constructor
		 *
		 * @param packageDir		The file or directory location of the package
		 * @param checkSourceUrl 	Whether we should check the source url - may not want to during build to allow for local packages with no source url
		 */
		public function PackageContentVerifyProcess( packageDir:File, checkSourceUrl:Boolean=true )
		{
			_packageDir = packageDir;
			_checkSourceUrl = checkSourceUrl;
		}
		
		
		override public function start( completeCallback:Function = null, failureCallback:Function = null ):void
		{
			super.start( completeCallback, failureCallback );
			try
			{
				if (_packageDir == null || !_packageDir.exists || !_packageDir.isDirectory)
				{
					return fail( _packageDir.name, "Specified package directory does not exist" );
				}
				
				var packageDefinitionFile:File = _packageDir.resolvePath( PackageDefinitionFile.DEFAULT_FILENAME );
				if (!packageDefinitionFile.exists)
				{
					return fail( PackageDefinitionFile.DEFAULT_FILENAME, "Package definition file does not exist" );
				}
				
				var f:PackageDefinitionFile = new PackageDefinitionFile().load( packageDefinitionFile );
				
				var identifier:String = PackageIdentifier.identifierWithoutVariant( f.packageDef.identifier );
				var variant:String = PackageIdentifier.variantFromIdentifier( f.packageDef.identifier );
				
				APM.io.writeLine( "- identifier:  " + identifier );
				if (variant.length > 0)
				{
					APM.io.writeLine( "- variant:     " + variant );
				}
				APM.io.writeLine( "- name:        " + f.packageDef.name );
				APM.io.writeLine( "- description: " + f.packageDef.description );
				APM.io.writeLine( "- type:        " + f.packageDef.type );
				APM.io.writeLine( "- tags:        " + f.packageDef.tags.join( "," ) );
				APM.io.writeLine( "- version:     " + f.version.toString() );
				APM.io.writeLine( "- status:      " + f.version.status );
				APM.io.writeLine( "- publishedAt: " + f.version.publishedAt );
				APM.io.writeLine( "- sourceUrl:   " + f.version.sourceUrl );
				APM.io.writeLine( "- platforms:   " + f.version.platforms.join(",") );

				
				APM.io.showSpinner( "Verifying package content" );
				
				if (identifier.length <= 5)
				{
					return fail( PackageDefinitionFile.DEFAULT_FILENAME, "identifier should be at least 5 characters" );
				}
				if (!PackageIdentifier.isValid(identifier))
				{
					return fail( PackageDefinitionFile.DEFAULT_FILENAME, "identifier invalid: contains invalid characters or format" );
				}
				if (variant.length > 0 && variant.indexOf( "-" ) >= 0)
				{
					return fail( PackageDefinitionFile.DEFAULT_FILENAME, "variant should not contain a hyphen" );
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
				if (_checkSourceUrl && f.version.sourceUrl.length == 0)
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
						if (!aneDir.exists || FileUtils.countFilesByType( aneDir, "ane" ) == 0)
						{
							return fail( "CONTENT", "No 'ane' file found in the '" + PackageFileUtils.AIRPACKAGE_ANE_DIR + "' directory" );
						}
						break;
					case PackageDefinition.TYPE_SWC:
						var libDir:File = _packageDir.resolvePath( PackageFileUtils.AIRPACKAGE_SWC_DIR );
						if (!libDir.exists || FileUtils.countFilesByType( libDir, "swc" ) == 0)
						{
							return fail( "CONTENT", "No 'swc' file found in the '" + PackageFileUtils.AIRPACKAGE_SWC_DIR + "' directory" );
						}
						break;
					case PackageDefinition.TYPE_SRC:
						var srcDir:File = _packageDir.resolvePath( PackageFileUtils.AIRPACKAGE_SRC_DIR );
						if (!srcDir.exists || FileUtils.countFilesByType( srcDir, "as" ) == 0)
						{
							return fail( "CONTENT", "No 'as' files found in the '" + PackageFileUtils.AIRPACKAGE_SRC_DIR + "' directory" );
						}
						break;
				}

				// TODO:: Other checks
				
				APM.io.stopSpinner( true, "Package content verified" );
				complete();
			}
			catch (e:Error)
			{
				Log.e( TAG, e );
				failure( e.message );
			}
		}
		
		
		private function fail( tag:String, message:String ):void
		{
			APM.io.stopSpinner( false, "Invalid" );
			APM.io.writeError( tag, message );
			return failure( message );
		}
		
		
	}
	
}
