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
		
		
		private static const APPLICATION_DESCRIPTOR_TEMPLATE:XML = <application xmlns="http://ns.adobe.com/air/application/31.0">
	<id></id>
	<versionNumber>0.0.0</versionNumber>
	<filename>Main</filename>
	<name>Main</name>
	<initialWindow>
		<content>[]</content>
        <visible>true</visible>
		<fullScreen>false</fullScreen>
        <autoOrients>false</autoOrients>
		<renderMode>direct</renderMode>
	</initialWindow>
	<android>
		<manifestAdditions><![CDATA[
		]]></manifestAdditions>
		<containsVideo>true</containsVideo>
	</android>
</application>;
		
		
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
			
			var manifest:XML = new XML( _appDescriptor.androidManifest );
			var manifestAdditionsContent:String = stripManifestTag( manifest );
			var manifestAdditions:XML = new XML(
					"<manifestAdditions><![CDATA["+
					"<manifest android:installLocation=\"auto\" >\n" +
					manifestAdditionsContent + "\n" +
					"</manifest>\n" +
					"]]></manifestAdditions>"
			);
			
			
			
			try
			{
				
				//
				//	LOAD TEMPLATE
				
				if (!FileUtils.tmpDirectory.exists) FileUtils.tmpDirectory.createDirectory();
			
				var specifiedDescriptor:File = new File( );
				var configDescriptor:File = new File( APM.config.workingDir ).resolvePath( "config/application-descriptor.xml" );
				var templateDescriptor:File = FileUtils.tmpDirectory.resolvePath( "application-descriptor.xml" );
				
				if (configDescriptor.exists)
				{
					_appDescriptor.load( configDescriptor );
				}
				else
				{
					if (!templateDescriptor.exists)
					{
						writeEmptyApplicationTemplate( templateDescriptor );
					}
					_appDescriptor.load( templateDescriptor );
				}
			
				_appDescriptor.xml.id = "air.com.distriqt.test";
				_appDescriptor.xml.android.manifestAdditions = manifestAdditions;
				
				Log.d( TAG, _appDescriptor.toString() );

			}
			catch (e:Error)
			{
				trace( e );
				failure( e.message );
			}

			complete();
		}
		
		
		
		private function stripManifestTag( manifest:XML ):String
		{
			var outputLines:Array = [];
			var manifestLines:Array = manifest.toXMLString().split("\n");
			for (var i:int = 0; i < manifestLines.length; i++)
			{
				var line:String = manifestLines[i];
				if (line.indexOf( "<manifest" ) >= 0) continue;
				if (line.indexOf( "</manifest>" ) >= 0) continue;
				outputLines.push( line );
			}
			return outputLines.join("\n");
		}
		
		
		
		private function writeEmptyApplicationTemplate( file:File ):void
		{
			var fs:FileStream = new FileStream();
			fs.open( file, FileMode.WRITE );
			fs.writeUTFBytes( APPLICATION_DESCRIPTOR_TEMPLATE.toString() );
			fs.close();
		}
		
		
	}
	
}
