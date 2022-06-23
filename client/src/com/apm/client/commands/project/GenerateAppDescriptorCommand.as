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
 * @created		20/8/21
 */
package com.apm.client.commands.project
{
	import airsdk.AIRSDKVersion;
	
	import com.apm.client.APM;
	import com.apm.client.commands.Command;
	import com.apm.client.commands.project.processes.AndroidManifestMergeProcess;
	import com.apm.client.commands.project.processes.ApplicationDescriptorGenerationProcess;
	import com.apm.client.commands.project.processes.IOSAdditionsMergeProcess;
	import com.apm.client.commands.project.processes.IOSEntitlementsMergeProcess;
	import com.apm.client.commands.project.processes.ValidatePackageCacheProcess;
	import com.apm.client.commands.project.processes.ValidateProjectParametersProcess;
	import com.apm.client.events.CommandEvent;
	import com.apm.client.logging.Log;
	import com.apm.client.processes.ProcessQueue;
	import com.apm.data.project.ApplicationDescriptor;
	import com.apm.data.project.ProjectDefinition;
	
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	
	
	public class GenerateAppDescriptorCommand extends EventDispatcher implements Command
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "GenerateAppDescriptorCommand";
		
		
		public static const NAME:String = "generate/app-descriptor";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _parameters:Array;
		private var _options:Array;
		private var _queue:ProcessQueue;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function GenerateAppDescriptorCommand()
		{
			super();
			_parameters = [];
			_options = [];
			_queue = new ProcessQueue();
		}
		
		
		public function setParameters( parameters:Array ):void
		{
			if (parameters != null)
			{
				_parameters = [];
				_options = [];
				for each (var p:String in parameters)
				{
					if (p.substr( 0, 2 ) == "--")
					{
						_options.push( p );
					}
					else
					{
						_parameters.push( p );
					}
				}
			}
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
			return "generate an application descriptor with all package required additions";
		}
		
		
		public function get usage():String
		{
			return description + "\n" +
					"\n" +
					"apm generate app-descriptor             generates an application descriptor to 'src/APPNAME-app.xml'\n" +
					"apm generate app-descriptor [out.xml]   generates an application descriptor updating the specified out.xml file\n" +
					"\n" +
					"options: \n" +
					"  --exclude-android    excludes generation of the android manifest additions\n" +
					"  --exclude-ios        excludes generation of the iOS info additions and entitlements\n"
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
			Log.d( TAG, "execute(): " + (_parameters.length > 0 ? _parameters.join( "," ) : "...") + "\n" );
			
			var excludeAndroid:Boolean = false;
			var excludeIOS:Boolean = false;
			for each (var option:String in _options)
			{
				switch (option)
				{
					case "--exclude-android":
					{
						excludeAndroid = true;
						break;
					}
					case "--exclude-ios":
					{
						excludeIOS = true;
						break;
					}
				}
			}
			
			// Get AIR SDK version for app descriptor
			var airSDKVersion:AIRSDKVersion = null;
			if (APM.config.airDirectory != null)
			{
				var airDir:File = new File( APM.config.airDirectory );
				if (airDir.exists)
				{
					airSDKVersion = AIRSDKVersion.fromAIRSDKDescription(
							airDir.resolvePath( "air-sdk-description.xml" )
					);
				}
				else
				{
					Log.d( TAG, "AIR DIR doesn't exist: " + APM.config.airDirectory );
				}
			}
			
			Log.d( TAG, "AIR SDK Version: " + (airSDKVersion == null ? "null" : airSDKVersion.toString()) );
			
			var appDescriptor:ApplicationDescriptor = new ApplicationDescriptor( airSDKVersion );
			
			var outputPath:String = defaultOutputPath();
			if (_parameters.length > 0)
			{
				outputPath = _parameters[ 0 ];
			}
			
			_queue.addProcess( new ValidateProjectParametersProcess() );
			_queue.addProcess( new ValidatePackageCacheProcess() );
			if (!excludeAndroid)
			{
				_queue.addProcess( new AndroidManifestMergeProcess( appDescriptor ) );
			}
			if (!excludeIOS)
			{
				_queue.addProcess( new IOSAdditionsMergeProcess( appDescriptor ) );
				_queue.addProcess( new IOSEntitlementsMergeProcess( appDescriptor ) );
			}
			_queue.addProcess( new ApplicationDescriptorGenerationProcess( appDescriptor, outputPath ) );
			
			_queue.start(
					function ():void
					{
						dispatchEvent( new CommandEvent( CommandEvent.COMPLETE, APM.CODE_OK ) );
					},
					function ( error:String ):void
					{
						APM.io.writeError( NAME, error );
						dispatchEvent( new CommandEvent( CommandEvent.COMPLETE, APM.CODE_ERROR ) );
					} );
		}
		
		
		public function defaultOutputPath():String
		{
			var proj:ProjectDefinition = APM.config.projectDefinition;
			if (proj.applicationFilename != null)
			{
				return "src/" + proj.applicationFilename + "-app.xml";
			}
			else if (proj.applicationName is String)
			{
				return "src/" + proj.applicationName.replace( / /g, "" ) + "-app.xml";
			}
			else if (proj.applicationName.hasOwnProperty("en"))
			{
				return "src/" + proj.applicationName["en"].replace( / /g, "" ) + "-app.xml";
			}
			return "src/MyApplication-app.xml";
		}
		
		
	}
	
}
