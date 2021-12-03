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
	import com.apm.data.project.ProjectParameter;
	import com.apm.utils.FileUtils;
	import com.apple.plist.Plist;
	
	import flash.filesystem.File;
	
	
	public class IOSAdditionsMergeProcess extends ProcessBase
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
		
		public function IOSAdditionsMergeProcess( appDescriptor:ApplicationDescriptor )
		{
			_appDescriptor = appDescriptor;
		}
		
		
		override public function start( completeCallback:Function = null, failureCallback:Function = null ):void
		{
			super.start( completeCallback, failureCallback );
			
			if (!FileUtils.tmpDirectory.exists) FileUtils.tmpDirectory.createDirectory();
			var infoAdditionsFile:File = FileUtils.tmpDirectory.resolvePath( "InfoAdditions.xml" );
			
			// Check if there's a file in the config dir or create an empty info additions file for merging
			var infoAdditionsProjectFile:File = new File( APM.config.configDirectory ).resolvePath( "ios/InfoAdditions.xml" );
			if (infoAdditionsProjectFile.exists)
			{
				APM.io.writeLine( "Merging with supplied info additions: " + infoAdditionsProjectFile.nativePath.substr( APM.config.workingDirectory.length + 1 ) );
				
				// Read content and inject any config parameters
				var infoAdditionsProjectContent:String = FileUtils.readFileContentAsString( infoAdditionsProjectFile );
				for each (var param:ProjectParameter in APM.config.projectDefinition.getConfiguration( APM.config.buildType ))
				{
					var regex:RegExp = new RegExp( "\\$\\{" + param.name + "\\}", "g" );
					infoAdditionsProjectContent = infoAdditionsProjectContent.replace( regex, param.value );
				}
				infoAdditionsProjectContent = infoAdditionsProjectContent.replace( /\$\{applicationId\}/g, APM.config.projectDefinition.applicationId );
				
				FileUtils.writeStringAsFileContent( infoAdditionsFile, infoAdditionsProjectContent );
			}
			else
			{
				new Plist().save( infoAdditionsFile ); // Just writes empty plist file
			}
			
			
			APM.io.showSpinner( "iOS additions merging" );
			
			var packageInfoAdditions:Array = findPackageInfoAdditions();
			
			_subqueue = new ProcessQueue();
			for each (var packageInfoAdditionsFile:File in packageInfoAdditions)
			{
				Log.d( TAG, packageInfoAdditionsFile.nativePath );
				_subqueue.addProcess( new IOSPlistMergeProcess( packageInfoAdditionsFile, infoAdditionsFile ) );
			}
			
			_subqueue.start( function ():void {
				
								 _appDescriptor.iosInfoAdditions = new XML( FileUtils.readFileContentAsString( infoAdditionsFile ) ).dict.children().toXMLString();
				
								 APM.io.stopSpinner( true, "iOS additions merge complete" );
								 complete();
							 },
							 function ( error:String ):void {
								 APM.io.stopSpinner( false, "iOS additions merge failed: " + error );
								 failure( error );
							 }
			);

		}
		
		
		private function findPackageInfoAdditions():Array
		{
			var infoAdditions:Array = FileUtils.getFilesByName(
					"InfoAdditions.xml",
					new File( APM.config.packagesDirectory )
			);
			return infoAdditions;
		}
		
		
	}
	
}
