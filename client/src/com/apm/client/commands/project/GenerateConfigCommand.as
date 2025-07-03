/**
 * @author 		Michael Archbold (https://michaelarchbold.com)
 * @created		20/8/2021
 */
package com.apm.client.commands.project
{
	import com.apm.client.APM;
	import com.apm.client.commands.Command;
	import com.apm.client.commands.project.processes.AndroidManifestMergeProcess;
	import com.apm.client.commands.project.processes.ApplicationDescriptorGenerationProcess;
	import com.apm.client.commands.project.processes.GenerateConfigAndroidProcess;
	import com.apm.client.commands.project.processes.GenerateConfigIOSProcess;
	import com.apm.client.commands.project.processes.IOSAdditionsMergeProcess;
	import com.apm.client.commands.project.processes.IOSEntitlementsMergeProcess;
	import com.apm.client.commands.project.processes.ValidatePackageCacheProcess;
	import com.apm.client.commands.project.processes.ValidateProjectParametersProcess;
	import com.apm.client.events.CommandEvent;
	import com.apm.client.logging.Log;
	import com.apm.client.processes.ProcessQueue;
	import com.apm.data.project.ApplicationDescriptor;
	import com.apm.data.project.ProjectDefinition;
	import airsdk.AIRSDKVersion;
	import airsdk.AIRSDKVersion;

	import com.apm.data.common.Platform;

	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	
	
	public class GenerateConfigCommand extends EventDispatcher implements Command
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "GenerateConfigCommand";
		
		
		public static const NAME:String = "generate/config";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _parameters:Array;
		private var _queue:ProcessQueue;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function GenerateConfigCommand()
		{
			super();
			_parameters = [];
			_queue = new ProcessQueue();
		}
		
		
		public function setParameters( parameters:Array ):void
		{
			if (parameters != null)
				_parameters = parameters;
		}
		
		
		public function get name():String
		{
			return NAME;
		}
		
		
		public function get category():String
		{
			return "";
		}
		
		
		public function get description():String
		{
			return "generates the default configuration files for setting advanced properties into the platform specific application descriptor section";
		}
		
		
		public function get usage():String
		{
			return description + "\n" +
					"\n" +
					"apm generate config             generates default configuration files for all platforms\n" +
					"apm generate config <platform>  generates default configuration files for the specified platform [android, ios]\n"
					;
		}
		
		
		public function get requiresNetwork():Boolean
		{
			return false;
		}
		
		
		public function get requiresProject():Boolean
		{
			return true;
		}
		
		
		public function execute():void
		{
			Log.d( TAG, "execute(): " + (_parameters.length > 0 ? _parameters[ 0 ] : "...") + "\n" );

			var platform:String = (_parameters.length > 0) ? _parameters[0] : null;
			if (platform != null)
			{
				switch (platform)
				{
					case "android":
					{
						_queue.addProcess( new GenerateConfigAndroidProcess() );
						break;
					}
					case "ios":
					{
						_queue.addProcess( new GenerateConfigIOSProcess() );
						break;
					}
				}
			}
			else
			{
				for each (var p:Platform in APM.config.projectDefinition.platforms)
				{
					switch (p.name)
					{
						case Platform.ANDROID:
							_queue.addProcess( new GenerateConfigAndroidProcess() );
							break;

						case Platform.IOS:
							_queue.addProcess( new GenerateConfigIOSProcess() );
							break;
					}
				}
			}

			_queue.start(
					function ():void {
						dispatchEvent( new CommandEvent( CommandEvent.COMPLETE, APM.CODE_OK ) );
					},
					function ( error:String ):void {
						APM.io.writeError( NAME, error );
						dispatchEvent( new CommandEvent( CommandEvent.COMPLETE, APM.CODE_ERROR ) );
					} );
		}
		
	}
	
}
