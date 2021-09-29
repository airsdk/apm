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
	import com.apm.client.APM;
	import com.apm.client.logging.Log;
	import com.apm.client.processes.ProcessBase;
	import com.apm.client.processes.ProcessQueue;
	import com.apm.data.project.ApplicationDescriptor;
	import com.apm.utils.FileUtils;
	import com.apple.plist.Plist;
	
	import flash.filesystem.File;
	
	
	public class IOSEntitlementsMergeProcess extends ProcessBase
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "IOSAdditionsMergeProcess";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _appDescriptor:ApplicationDescriptor;
		private var _subqueue:ProcessQueue;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function IOSEntitlementsMergeProcess( appDescriptor:ApplicationDescriptor )
		{
			_appDescriptor = appDescriptor;
		}
		
		
		override public function start( completeCallback:Function = null, failureCallback:Function = null ):void
		{
			super.start( completeCallback, failureCallback );
			
			if (!FileUtils.tmpDirectory.exists) FileUtils.tmpDirectory.createDirectory();
			var entitlementsFile:File = FileUtils.tmpDirectory.resolvePath( "Entitlements.xml" );
			
			// Check if there's a file in the config dir or create an empty info additions file for merging
			var entitlementsProjectFile:File = new File( APM.config.workingDirectory ).resolvePath( "config/ios/Entitlements.xml" );
			if (entitlementsProjectFile.exists)
			{
				APM.io.writeLine( "Merging with supplied info additions: config/ios/Entitlements.xml" );
				
				// Read content and inject any config parameters
				var entitlementsProjectContent:String = FileUtils.readFileContentAsString( entitlementsProjectFile );
				for (var name:String in APM.config.projectDefinition.configuration)
				{
					var regex:RegExp = new RegExp( "\\$\\{" + name + "\\}", "g" );
					var value:String = APM.config.projectDefinition.getConfigurationParam( name );
					
					entitlementsProjectContent = entitlementsProjectContent.replace( regex, value );
				}
				FileUtils.writeStringAsFileContent( entitlementsFile, entitlementsProjectContent );
			}
			else
			{
				new Plist().save( entitlementsFile ); // Just writes empty plist file
			}
			
			
			
			var packageInfoAdditions:Array = findPackageEntitlements();
			_subqueue = new ProcessQueue();
			for each (var packageInfoAdditionsFile:File in packageInfoAdditions)
			{
				Log.d( TAG, packageInfoAdditionsFile.nativePath );
				_subqueue.addProcess( new IOSPlistMergeProcess( packageInfoAdditionsFile, entitlementsFile ) );
			}
			
			APM.io.showSpinner( "iOS entitlements merging" );
			
			_subqueue.start( function ():void {
				
								 _appDescriptor.iosEntitlements = new XML( FileUtils.readFileContentAsString( entitlementsFile ) ).dict.children().toXMLString();
				
								 APM.io.stopSpinner( true, "iOS entitlements merge complete" );
								 complete();
							 },
							 function ( error:String ):void {
								 APM.io.stopSpinner( false, "iOS entitlements merge failed: " + error );
								 failure( error );
							 }
			);

		}
		
		
		private function findPackageEntitlements():Array
		{
			var infoAdditions:Array = FileUtils.getFilesByName(
					"Entitlements.xml",
					new File( APM.config.packagesDirectory )
			);
			return infoAdditions;
		}
		
		
	}
	
}
