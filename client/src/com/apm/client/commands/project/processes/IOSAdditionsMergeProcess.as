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
	import com.apm.client.processes.ProcessBase;
	import com.apm.data.project.ApplicationDescriptor;
	
	
	public class IOSAdditionsMergeProcess extends ProcessBase
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "AndroidManifestMergeProcess";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _appDescriptor:ApplicationDescriptor;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function IOSAdditionsMergeProcess( appDescriptor:ApplicationDescriptor )
		{
			_appDescriptor = appDescriptor;
		}
		
		
		override public function start( completeCallback:Function = null, failureCallback:Function = null ):void
		{
			super.start( completeCallback, failureCallback );

			// We could consider using PListBuddy here?
			// /usr/libexec/PlistBuddy -x -c "Merge package/InfoAdditions.plist" out.plist
			// https://marcosantadev.com/manage-plist-files-plistbuddy/
			// https://medium.com/@marksiu/what-is-plistbuddy-76cb4f0c262d
			
			
			// TODO
			APM.io.showSpinner( "iOS additions merging" );
			
			var infoAdditions:XML =
						<infoAdditions>
							<key>UIDeviceFamily</key>
							<array>
								<string>1</string>
								<string>2</string>
							</array>
						</infoAdditions>;
			
			var entitlements:XML =
						<entitlements>
						</entitlements>;
			
			_appDescriptor.iosInfoAdditions = infoAdditions.children().toXMLString();
			_appDescriptor.iosEntitlements = entitlements.children().toXMLString();
			
			APM.io.stopSpinner( true, "iOS additions merge" );
			
			complete();
		}
		
	}
	
}
