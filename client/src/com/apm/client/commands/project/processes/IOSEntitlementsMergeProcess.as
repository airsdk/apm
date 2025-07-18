/**
 * @author 		Michael Archbold (https://michaelarchbold.com)
 * @created		23/8/2021
 */
package com.apm.client.commands.project.processes
{
	import com.apm.client.APM;
	import com.apm.client.logging.Log;
	import com.apm.client.processes.ProcessBase;
	import com.apm.client.processes.ProcessQueue;
	import com.apm.data.project.ApplicationDescriptor;
	import com.apm.data.project.ProjectParameter;
	import com.apm.utils.FileUtils;
	import com.apple.plist.Plist;
	import com.apple.plist.entries.PlistBooleanEntry;
	
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
			var entitlementsProjectFile:File = new File( APM.config.configDirectory ).resolvePath( "ios/Entitlements.xml" );
			if (entitlementsProjectFile.exists)
			{
				APM.io.writeLine( "Merging with supplied info additions: " + entitlementsProjectFile.nativePath.substr( APM.config.workingDirectory.length + 1 ) );
				
				// Read content and inject any config parameters
				var entitlementsProjectContent:String = FileUtils.readFileContentAsString( entitlementsProjectFile );
				for each (var param:ProjectParameter in APM.config.projectDefinition.getConfiguration( APM.config.buildType ))
				{
					var regex:RegExp = new RegExp( "\\$\\{" + param.name + "\\}", "g" );
					entitlementsProjectContent = entitlementsProjectContent.replace( regex, param.value );
				}
				entitlementsProjectContent = entitlementsProjectContent.replace(
						/\$\{applicationId\}/g,
						APM.config.projectDefinition.getApplicationId( APM.config.buildType )
				);
				
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
			
			_subqueue.start( function ():void
							 {
								 // Adjustment to remove beta-reports-active when its false
								 var entitlementsPlist:Plist = new Plist().load( entitlementsFile );
								 var betaReportsActiveEntry:PlistBooleanEntry = entitlementsPlist.getEntry( "beta-reports-active" ) as PlistBooleanEntry;
								 if (betaReportsActiveEntry != null)
								 {
									 if (!betaReportsActiveEntry.value)
									 {
										 entitlementsPlist.removeEntry( betaReportsActiveEntry.key );
									 }
								 }
				
								 _appDescriptor.iosEntitlements = entitlementsPlist.toXML().dict.children().toXMLString();
				
								 APM.io.stopSpinner( true, "iOS entitlements merge complete" );
								 complete();
							 },
							 function ( error:String ):void
							 {
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
