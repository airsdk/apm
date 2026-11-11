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
		private var _platform:String;
		private var _subqueue:ProcessQueue;


		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//

		public function IOSAdditionsMergeProcess( appDescriptor:ApplicationDescriptor, platform:String = Platform.IOS )
		{
			_appDescriptor = appDescriptor;
			_platform = platform;
		}


		override public function start( completeCallback:Function = null, failureCallback:Function = null ):void
		{
			super.start( completeCallback, failureCallback );

			if (!FileUtils.tmpDirectory.exists) FileUtils.tmpDirectory.createDirectory();
			var infoAdditionsFile:File = FileUtils.tmpDirectory.resolvePath( _platform + "InfoAdditions.xml" );

			// Check if there's a file in the config dir or create an empty info additions file for merging
			var infoAdditionsProjectFile:File = new File( APM.config.configDirectory ).resolvePath( _platform + "/InfoAdditions.xml" );
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
				infoAdditionsProjectContent = infoAdditionsProjectContent.replace(
						/\$\{applicationId\}/g,
						APM.config.projectDefinition.getApplicationId( APM.config.buildType )
				);

				FileUtils.writeStringAsFileContent( infoAdditionsFile, infoAdditionsProjectContent );
			}
			else
			{
				new Plist().save( infoAdditionsFile ); // Just writes empty plist file
			}

			APM.io.showSpinner( _platform + " additions merging" );

			var packageInfoAdditions:Array = findPackageInfoAdditions( _platform );
			_subqueue = new ProcessQueue();
			for each (var packageInfoAdditionsFile:File in packageInfoAdditions)
			{
				Log.d( TAG, packageInfoAdditionsFile.nativePath );
				_subqueue.addProcess( new IOSPlistMergeProcess( packageInfoAdditionsFile, infoAdditionsFile ) );
			}

			_subqueue.start( function ():void
							 {
								 if (_platform == Platform.IOS)
								 {
									 _appDescriptor.iosInfoAdditions = new XML( FileUtils.readFileContentAsString( infoAdditionsFile ) ).dict.children().toXMLString();
								 }
								 else if (_platform == Platform.MACOS)
								 {
									 _appDescriptor.macosInfoAdditions = new XML( FileUtils.readFileContentAsString( infoAdditionsFile ) ).dict.children().toXMLString();
								 }
								 APM.io.stopSpinner( true, _platform + " additions merge complete" );
								 complete();
							 },
			                 function ( error:String ):void
							 {
								 APM.io.stopSpinner( false, _platform + " additions merge failed: " + error );
								 failure( error );
							 }
			);

		}


		private function findPackageInfoAdditions( platform:String ):Array
		{
			var infoAdditions:Array = FileUtils.getFilesMatchingPath(
					"platforms/" + platform + "/InfoAdditions.xml",
					new File( APM.config.packagesDirectory )
			);
			return infoAdditions;
		}


	}

}
