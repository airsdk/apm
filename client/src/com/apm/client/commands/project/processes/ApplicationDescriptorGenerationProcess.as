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
	import com.apm.data.project.ApplicationDescriptor;
	import com.apm.data.project.ApplicationDescriptor;
	import com.apm.remote.airsdk.AIRSDKVersion;
	import com.apm.utils.FileUtils;
	
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
				
				if (!FileUtils.tmpDirectory.exists) FileUtils.tmpDirectory.createDirectory();
			
				var specifiedDescriptor:File = new File( APM.config.workingDir ).resolvePath( _outputPath );
				var configDescriptor:File = new File( APM.config.workingDir ).resolvePath( "config/application-descriptor.xml" );
				var templateDescriptor:File = FileUtils.tmpDirectory.resolvePath( "application-descriptor.xml" );
				
				if (specifiedDescriptor.exists)
				{
					_appDescriptor.load( specifiedDescriptor );
				}
				else if (configDescriptor.exists)
				{
					_appDescriptor.load( configDescriptor );
				}
				else
				{
					if (!templateDescriptor.exists)
					{
						writeApplicationTemplate( templateDescriptor );
					}
					_appDescriptor.load( templateDescriptor );
				}
			
				_appDescriptor.updateFromProjectDefinition( APM.config.projectDefinition );
				_appDescriptor.updateAndroidAdditions();
				_appDescriptor.updateIOSAdditions();
				_appDescriptor.save( specifiedDescriptor );
				
				APM.io.stopSpinner( true, "App descriptor generated: " + specifiedDescriptor.nativePath );
				complete();
			}
			catch (e:Error)
			{
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
