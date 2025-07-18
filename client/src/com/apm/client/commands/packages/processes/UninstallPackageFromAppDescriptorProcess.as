/**
 * @author 		Michael Archbold (https://michaelarchbold.com)
 * @created		03/12/2021
 */
package com.apm.client.commands.packages.processes
{
	import airsdk.AIRSDKVersion;
	
	import com.apm.client.APM;
	import com.apm.client.logging.Log;
	import com.apm.client.processes.ProcessBase;
	import com.apm.data.packages.PackageDefinition;
	import com.apm.data.packages.PackageDefinitionFile;
	import com.apm.data.packages.PackageIdentifier;
	import com.apm.data.project.ApplicationDescriptor;
	import com.apm.utils.FileUtils;
	
	import flash.filesystem.File;
	
	
	/**
	 * This process removes a package from the application descriptor
	 *  -  this removes the extensionID from the extensions list
	 */
	public class UninstallPackageFromAppDescriptorProcess extends ProcessBase
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "UninstallPackageFromAppDescriptorProcess";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _packageDefinition:PackageDefinitionFile;
		private var _appDescriptorPath:String;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function UninstallPackageFromAppDescriptorProcess( packageDefinition:PackageDefinitionFile, appDescriptorPath:String )
		{
			super();
			_packageDefinition = packageDefinition;
			_appDescriptorPath = appDescriptorPath;
		}
		
		
		override public function start( completeCallback:Function = null, failureCallback:Function = null ):void
		{
			super.start( completeCallback, failureCallback );
			
			if (_packageDefinition.packageDef.type != PackageDefinition.TYPE_ANE)
			{
				Log.d( TAG, "Nothing to do, not an ANE package: " + _packageDefinition.packageDef.identifier );
				return complete();
			}
			
			APM.io.showSpinner( "Updating app descriptor : " + _appDescriptorPath );
			
			// Get AIR SDK version for app descriptor
			var airSDKVersion:AIRSDKVersion = null;
			if (APM.config.airDirectory != null)
			{
				var airDir:File = new File( APM.config.airDirectory );
				if (airDir.exists)
				{
					airSDKVersion = AIRSDKVersion.fromAIRSDKDescription(
							airDir.resolvePath( "air-sdk-description.xml" )
					);
				}
				else
				{
					Log.d( TAG, "AIR DIR doesn't exist: " + APM.config.airDirectory );
				}
			}
			
			Log.d( TAG, "AIR SDK Version: " + (airSDKVersion == null ? "null" : airSDKVersion.toString()) );
			
			var appDescriptor:ApplicationDescriptor = new ApplicationDescriptor( airSDKVersion );
			var specifiedDescriptor:File = FileUtils.getSourceForPath( _appDescriptorPath );
			
			if (specifiedDescriptor.exists)
			{
				Log.d( TAG, "Loading " + _appDescriptorPath );
				appDescriptor.load( specifiedDescriptor );
				if (!appDescriptor.isValid())
				{
					Log.l( TAG, appDescriptor.validate() );
					APM.io.stopSpinner( false, "Could not validate supplied app descriptor [" + _appDescriptorPath + "]: " + appDescriptor.validate() );
					complete();
				}
				else
				{
					appDescriptor.removeExtension(
							PackageIdentifier.identifierWithoutVariant( _packageDefinition.packageDef.identifier )
					);
					appDescriptor.save( specifiedDescriptor );
					
					APM.io.stopSpinner( true, "Updated app descriptor : " + _appDescriptorPath );
					complete();
				}
			}
			else
			{
				APM.io.stopSpinner( false, "App descriptor not found: " + _appDescriptorPath );
				complete();
			}
		}
		
		
	}
	
}
