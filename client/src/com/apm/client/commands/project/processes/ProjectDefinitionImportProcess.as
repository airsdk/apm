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
 * @created		29/9/21
 */
package com.apm.client.commands.project.processes
{
	import com.apm.client.APM;
	import com.apm.client.logging.Log;
	import com.apm.client.processes.ProcessBase;
	import com.apm.client.processes.ProcessQueue;
	import com.apm.data.packages.PackageDependency;
	import com.apm.data.packages.PackageVersion;
	import com.apm.data.project.ApplicationDescriptor;
	import com.apm.data.project.ProjectDefinition;
	
	import flash.filesystem.File;
	import flash.html.script.Package;
	
	
	/**
	 * This process loads an application descriptor and attempts to
	 * construct a project definition file from it.
	 */
	public class ProjectDefinitionImportProcess extends ProcessBase
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "ProjectDefinitionImportProcess";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _importAppDescriptor:File;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function ProjectDefinitionImportProcess( importAppDescriptor:File )
		{
			super();
			_importAppDescriptor = importAppDescriptor;
		}
		
		
		override public function start( completeCallback:Function = null, failureCallback:Function = null ):void
		{
			super.start( completeCallback, failureCallback );
			try
			{
				if (APM.config.projectDefinition != null)
				{
					APM.io.writeLine( "Already have a config file " );
					
					var response:String = APM.io.question( "Overwrite? Y/n", "n" )
					if (response.toLowerCase() != "y")
					{
						complete();
						return;
					}
				}
				
				APM.io.writeLine( "Creating new project definition file from application descriptor: " + _importAppDescriptor.name );
				
				var appDescriptor:ApplicationDescriptor = new ApplicationDescriptor();
				appDescriptor.load( _importAppDescriptor );
				
				if (!appDescriptor.isValid())
				{
					failure( "Invalid application descriptor: " + appDescriptor.validate() );
					return;
				}
				
				
				//
				//	Create project properties from descriptor
				
				var project:ProjectDefinition = new ProjectDefinition();
				
				project.applicationId = appDescriptor.xml.id.toString();
				project.applicationName = appDescriptor.xml.name.toString();
				project.applicationFilename = appDescriptor.xml.filename.toString();
				project.version = appDescriptor.xml.versionNumber.toString();
				project.versionLabel = appDescriptor.xml.versionLabel.toString();
				
				var subqueue:ProcessQueue = new ProcessQueue();
				
				var packageList:Vector.<PackageVersion> = new <PackageVersion>[];
				
				// Search for package matching extensionIDs
				for each (var extensionIDNode:XML in appDescriptor.xml.extensions.extensionID)
				{
					var extensionID:String = extensionIDNode.toString();
					subqueue.addProcess( new ProjectDefinitionImportGetExtensionProcess( extensionID, packageList ) );
				}
				
				subqueue.addCallback(
						function ():void
						{
							// Process assembled list of packages
							APM.io.writeLine( "Processing identified packages" );
							for each (var packageVersion:PackageVersion in packageList)
							{
								if (shouldAddPackageToProject( packageVersion, packageList ))
								{
									APM.io.writeResult( true, "ADDING   : Package: " + packageVersion.packageDef.toString() );
									project.addPackageDependency( packageVersion );
								}
								else
								{
									APM.io.writeResult( false, "SKIPPING : Dependency: " + packageVersion.packageDef.toString() );
								}
							}
							
							var projectFile:File = new File( APM.config.workingDirectory + File.separator + ProjectDefinition.DEFAULT_FILENAME );
							project.save( projectFile );
						} );
				subqueue.start( complete, failure );
				
			}
			catch (e:Error)
			{
				Log.e( TAG, e );
				failure( e.message );
			}
		}
		
		
		/**
		 * Checks to see if the "package to check" is a dependency of one of the other packages in the list
		 *
		 * @param packageVersionToCheck	The package to check
		 * @param packageList			The list of packages gathered from the app descriptor
		 *
		 * @return true if the package should be added to the project, i.e. is not a dependency of any other package
		 */
		private static function shouldAddPackageToProject( packageVersionToCheck:PackageVersion, packageList:Vector.<PackageVersion> ):Boolean
		{
			if (isDependencyExtension( packageVersionToCheck.packageDef.identifier ) )
			{
				return false;
			}

			// Check all other packages to see if packageVersionToCheck is a dependency
			for each (var packageVersion:PackageVersion in packageList)
			{
				for each (var dependency:PackageDependency in packageVersion.dependencies)
				{
					if (dependency.identifier == packageVersionToCheck.packageDef.identifier)
					{
						// TODO:: Probably shouldn't skip all dependencies?
						//  eg firebase components depend on core firebase which probably should be added?
						return false;
					}
				}
			}
			return true;
		}
		
		
		/**
		 * Returns true if this package identifier is a common dependency
		 * that shouldn't be directly added to the project. eg androidx.core
		 * <br/>
		 * This is to quickly strip out packages that aren't needed
		 *
		 * @param identifier	The identifier of the package
		 *
		 * @return <code>true</code> if the extension is a common dependency
		 */
		private static function isDependencyExtension( identifier:String ):Boolean
		{
			if (identifier.indexOf("androidx") == 0) return true;
			if (identifier.indexOf("com.distriqt.playservices") == 0) return true;
			if (COMMON_DEPENDENCY_IDENTIFIERS.indexOf( identifier ) >= 0) return true;
			return false;
		}
		
		private static var COMMON_DEPENDENCY_IDENTIFIERS:Array = [
			"com.distriqt.Core",
			"com.distriqt.Bolts",
//			"com.android.installreferrer",
			"com.google.android.datatransport",
			"com.google.android.material",
			"com.google.code.gson",
			"com.google.dagger",
			"com.google.guava",
			"com.google.protobuflite",
			"com.jetbrains.kotlin",
			"io.grpc",
			"io.reactivex",
			"com.google.android.play",
			"com.google.firebase.core",
			"com.huawei.hms.adsidentifier",
			"com.huawei.hms.adslite",
			"com.huawei.hms.base",
			"com.huawei.hms.game",
			"com.distriqt.square.okhttp",
			"com.distriqt.square.okhttp3",
			"com.distriqt.square.picasso"
		];
		
		
	}
	
}
