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
	import com.apm.data.common.Platform;
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

		private static const TAG:String = "IOSEntitlementsMergeProcess";


		////////////////////////////////////////////////////////
		//  VARIABLES
		//

		private var _appDescriptor:ApplicationDescriptor;
		private var _platform:String;
		private var _subqueue:ProcessQueue;


		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//

		public function IOSEntitlementsMergeProcess( appDescriptor:ApplicationDescriptor, platform:String = Platform.IOS )
		{
			_appDescriptor = appDescriptor;
			_platform = platform;
		}


		override public function start( completeCallback:Function = null, failureCallback:Function = null ):void
		{
			super.start( completeCallback, failureCallback );

			if (!FileUtils.tmpDirectory.exists) FileUtils.tmpDirectory.createDirectory();
			var entitlementsFile:File = FileUtils.tmpDirectory.resolvePath( _platform + "Entitlements.xml" );

			// Check if there's a file in the config dir or create an empty entitlements file for merging
			var entitlementsProjectFile:File = new File( APM.config.configDirectory ).resolvePath( _platform + "/Entitlements.xml" );
			if (entitlementsProjectFile.exists)
			{
				APM.io.writeLine( "Merging with supplied entitlements: " + entitlementsProjectFile.nativePath.substr( APM.config.workingDirectory.length + 1 ) );

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

			APM.io.showSpinner( _platform + " entitlements merging" );

			var packageEntitlements:Array = findPackageEntitlements( _platform );
			_subqueue = new ProcessQueue();
			for each (var packageEntitlementsFile:File in packageEntitlements)
			{
				Log.d( TAG, packageEntitlementsFile.nativePath );
				_subqueue.addProcess( new IOSPlistMergeProcess( packageEntitlementsFile, entitlementsFile ) );
			}

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
								 if (_platform == Platform.IOS)
								 {
									 _appDescriptor.iosEntitlements = entitlementsPlist.toXML().dict.children().toXMLString();
								 }
								 else if (_platform == Platform.MACOS)
								 {
									 _appDescriptor.macosEntitlements = entitlementsPlist.toXML().dict.children().toXMLString();
								 }

								 APM.io.stopSpinner( true, _platform + " entitlements merge complete" );
								 complete();
							 },
			                 function ( error:String ):void
							 {
								 APM.io.stopSpinner( false, _platform + " entitlements merge failed: " + error );
								 failure( error );
							 }
			);

		}


		private function findPackageEntitlements( platform:String ):Array
		{
			var entitlements:Array = FileUtils.getFilesMatchingPath(
					"platforms/" + platform + "/Entitlements.xml",
					new File( APM.config.packagesDirectory )
			);
			return entitlements;
		}


	}

}
