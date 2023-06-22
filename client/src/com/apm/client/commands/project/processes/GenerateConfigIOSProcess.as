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
	 * Generates an InfoAdditions.xml and Entitlements.xml file in the configuration directory
	 * for the current project.
	 */
	public class GenerateConfigIOSProcess extends ProcessBase
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "GenerateConfigIOSProcess";
		
		[Embed(source="data/InfoAdditionsDefault.xml",mimeType="application/octet-stream")]
		private var InfoAdditionsDefault:Class;
		
		[Embed(source="data/EntitlementsDefault.xml",mimeType="application/octet-stream")]
		private var EntitlementsDefault:Class;
		
		private var INFO_ADDITIONS_DEFAULT:String = (new InfoAdditionsDefault() as ByteArray).toString();
		
		private var ENTITLEMENTS_DEFAULT:String = (new EntitlementsDefault() as ByteArray).toString();
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function GenerateConfigIOSProcess()
		{
		}
		
		
		override public function start( completeCallback:Function = null, failureCallback:Function = null ):void
		{
			super.start( completeCallback, failureCallback );
			
			Log.d( TAG, "Generating default iOS configuration" );
			
			var configInfoAdditions:File = new File( APM.config.configDirectory ).resolvePath( "ios/InfoAdditions.xml" );
			if (configInfoAdditions.exists)
			{
				APM.io.writeResult( false, "Config InfoAdditions.xml already exists" );
			}
			else
			{
				writeContentToFile( INFO_ADDITIONS_DEFAULT, configInfoAdditions );
				APM.io.writeResult( true, "Generated: " + configInfoAdditions.nativePath );
			}
			
			var configEntitlements:File = new File( APM.config.configDirectory ).resolvePath( "ios/Entitlements.xml" );
			if (configEntitlements.exists)
			{
				APM.io.writeResult( false, "Config Entitlements.xml already exists" );
			}
			else
			{
				writeContentToFile( ENTITLEMENTS_DEFAULT, configEntitlements );
				APM.io.writeResult( true, "Generated: " + configEntitlements.nativePath );
			}
			
			complete();
		}
		
		
		private function writeContentToFile( content:String, file:File ):void
		{
			var fs:FileStream = new FileStream();
			fs.open( file, FileMode.WRITE );
			fs.writeUTFBytes( content );
			fs.close();
		}
		
		
	}
	
}
