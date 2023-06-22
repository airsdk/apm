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
 * @created		29/9/2021
 */
package com.apm.client.commands.project.processes
{
	import com.apm.client.APM;
	import com.apm.client.logging.Log;
	import com.apm.client.processes.ProcessBase;
	
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	
	
	/**
	 * Generates a AndroidManifest.xml file in the configuration directory
	 * for the current project.
	 */
	public class GenerateConfigAndroidProcess extends ProcessBase
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "GenerateConfigAndroidProcess";
		
		[Embed(source="data/AndroidManifestDefault.xml",mimeType="application/octet-stream")]
		private var AndroidManifestDefault:Class;
		
		private var ANDROID_MANIFEST_DEFAULT:String = (new AndroidManifestDefault() as ByteArray).toString();
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function GenerateConfigAndroidProcess()
		{
		}
		
		
		override public function start( completeCallback:Function = null, failureCallback:Function = null ):void
		{
			super.start( completeCallback, failureCallback );
			
			Log.d( TAG, "Generating default AndroidManifest.xml configuration" );
			
			var configManifest:File = new File( APM.config.configDirectory ).resolvePath( "android/AndroidManifest.xml" );
			if (configManifest.exists)
			{
				APM.io.writeResult( false, "Config AndroidManifest.xml already exists" );
			}
			else
			{
				writeDefaultManifest( configManifest );
				APM.io.writeResult( true, "Generated: " + configManifest.nativePath );
			}
			complete();
		}
		
		
		private function writeDefaultManifest( file:File ):void
		{
			var fs:FileStream = new FileStream();
			fs.open( file, FileMode.WRITE );
			fs.writeUTFBytes( ANDROID_MANIFEST_DEFAULT );
			fs.close();
		}
		
		
	}
	
}
