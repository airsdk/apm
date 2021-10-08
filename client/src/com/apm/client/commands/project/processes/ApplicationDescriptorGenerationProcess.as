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
 * @created		23/8/21
 */
package com.apm.client.commands.project.processes
{
	import com.apm.SemVer;
	import com.apm.client.APM;
	import com.apm.client.logging.Log;
	import com.apm.client.processes.ProcessBase;
	import com.apm.data.packages.PackageDefinition;
	import com.apm.data.packages.PackageDefinitionFile;
	import com.apm.data.packages.PackageIdentifier;
	import com.apm.data.project.ApplicationDescriptor;
	import com.apm.data.project.ApplicationDescriptor;
	import airsdk.AIRSDKVersion;
	import com.apm.utils.FileUtils;
	import com.apm.utils.PackageCacheUtils;
	
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.xml.XMLNode;
	
	
	public class ApplicationDescriptorGenerationProcess extends ProcessBase
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "ApplicationDescriptorGenerationProcess";
		
		
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _appDescriptor:ApplicationDescriptor;
		private var _outputPath:String;
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function ApplicationDescriptorGenerationProcess( appDescriptor:ApplicationDescriptor, outputPath:String )
		{
			_appDescriptor = appDescriptor;
			_outputPath = outputPath;
		}
		
		
		override public function start( completeCallback:Function = null, failureCallback:Function = null ):void
		{
			super.start( completeCallback, failureCallback );
			try
			{
				APM.io.showSpinner( "Updating app descriptor" );

				//
				//	LOAD TEMPLATE
				
				var configDescriptorPath:String = "config/application-descriptor.xml";
				
				var configDescriptor:File = new File( APM.config.workingDirectory ).resolvePath( configDescriptorPath );
				var specifiedDescriptor:File = new File( APM.config.workingDirectory ).resolvePath( _outputPath );
				
				if (configDescriptor.exists)
				{
					Log.d( TAG, "Loading " + configDescriptorPath );
					_appDescriptor.load( configDescriptor );
					if (!_appDescriptor.isValid())
					{
						Log.l( TAG, _appDescriptor.validate() );
					}
				}
				else if (specifiedDescriptor.exists)
				{
					Log.d( TAG, "Loading " + _outputPath );
					_appDescriptor.load( specifiedDescriptor );
					if (!_appDescriptor.isValid())
					{
						Log.l( TAG, _appDescriptor.validate() );
					}
				}
				
				// Check if the loaded descriptor is valid, otherwise use the template
				if (!_appDescriptor.isValid())
				{
					Log.d( TAG, "Loading application descriptor template" );
					_appDescriptor.loadString( ApplicationDescriptor.APPLICATION_DESCRIPTOR_TEMPLATE );
				}
				
				_appDescriptor.updateFromProjectDefinition( APM.config.projectDefinition );
				_appDescriptor.updateAndroidAdditions();
				_appDescriptor.updateIOSAdditions();
				
				for each (var packageDefinition:PackageDefinitionFile in PackageCacheUtils.getCachedPackages())
				{
					if (packageDefinition.packageDef.type == PackageDefinition.TYPE_ANE)
					{
						_appDescriptor.addExtension(
								PackageIdentifier.identifierWithoutVariant( packageDefinition.packageDef.identifier )
						);
					}
				}
			
				_appDescriptor.save( specifiedDescriptor );
				
				APM.io.stopSpinner( true, "App descriptor generated: " + specifiedDescriptor.nativePath );
				complete();
			}
			catch (e:Error)
			{
				Log.e( TAG, e );
				APM.io.stopSpinner( false, "Error: " + e.message );
				failure( e.message );
			}
		}
		
		
		private function writeApplicationTemplate( file:File ):void
		{
			var fs:FileStream = new FileStream();
			fs.open( file, FileMode.WRITE );
			fs.writeUTFBytes( ApplicationDescriptor.APPLICATION_DESCRIPTOR_TEMPLATE.toString() );
			fs.close();
		}
		
		
	}
	
}
