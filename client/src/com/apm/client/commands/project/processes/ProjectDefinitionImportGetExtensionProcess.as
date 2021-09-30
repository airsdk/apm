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
	import com.apm.client.events.CommandEvent;
	import com.apm.client.logging.Log;
	import com.apm.client.processes.ProcessBase;
	import com.apm.client.repositories.PackageResolver;
	import com.apm.client.repositories.RepositoryResolver;
	import com.apm.data.packages.PackageDefinition;
	import com.apm.data.packages.PackageDefinitionFile;
	import com.apm.data.packages.PackageDependency;
	import com.apm.data.packages.PackageVersion;
	import com.apm.data.project.ProjectDefinition;
	
	import flash.html.script.Package;
	
	
	/**
	 * This process is part of the project creation by importing an application descriptor.
	 * <br/>
	 *
	 * This process takes a given extension ID (from the app descriptor) and tries to identify a
	 * matching package in the repository, adding it to the package list if an appropriate one was found.
	 */
	public class ProjectDefinitionImportGetExtensionProcess extends ProcessBase
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "ProjectDefinitionImportGetExtensionProcess";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _extensionID:String;
		
		private var _packageList:Vector.<PackageVersion>;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function ProjectDefinitionImportGetExtensionProcess( extensionID:String, packageList:Vector.<PackageVersion> )
		{
			super();
			_extensionID = extensionID;
			_packageList = packageList;
		}
		
		
		override public function start( completeCallback:Function = null, failureCallback:Function = null ):void
		{
			super.start( completeCallback, failureCallback );
			try
			{
				APM.io.showSpinner( "Locating package for extensionID " + _extensionID );
				new PackageResolver().getPackageVersion(
						_extensionID,
						null,
						null,
						function ( success:Boolean, packageDef:PackageDefinition ):void
						{
							try
							{
								if (success && packageDef.versions.length > 0)
								{
									APM.io.stopSpinner( success, "FOUND   : Package " + packageDef.toString()  );
									_packageList.push( packageDef.versions[0] );
									complete();
								}
								else
								{
									APM.io.stopSpinner( false, "WARNING : Could not locate package for extensionID " + _extensionID );
									complete();
//									failure( "Could not locate package for extensionID " + _extensionID );
								}
							}
							catch (e:Error)
							{
								APM.io.stopSpinner( false, "ERROR   : Could not locate package for extensionID " + _extensionID );
								Log.e( TAG, e );
								failure( "ERROR   : Could not locate package for extensionID " + _extensionID );
							}
						}
				);
			}
			catch (e:Error)
			{
				APM.io.stopSpinner( false, "ERROR   : " + e.message );
				Log.e( TAG, e );
				failure( e.message );
			}
		}
		
		
		
		
	}
}
