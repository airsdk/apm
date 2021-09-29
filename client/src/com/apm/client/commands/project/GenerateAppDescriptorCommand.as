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
	import com.apm.client.APM;
	import com.apm.client.commands.Command;
	import com.apm.client.commands.project.processes.AndroidManifestMergeProcess;
	import com.apm.client.commands.project.processes.ApplicationDescriptorGenerationProcess;
	import com.apm.client.commands.project.processes.IOSAdditionsMergeProcess;
	import com.apm.client.commands.project.processes.IOSEntitlementsMergeProcess;
	import com.apm.client.commands.project.processes.ValidatePackageCacheProcess;
	import com.apm.client.events.CommandEvent;
	import com.apm.client.logging.Log;
	import com.apm.client.processes.ProcessQueue;
	import com.apm.data.project.ApplicationDescriptor;
	import com.apm.data.project.ProjectDefinition;
	import com.apm.remote.airsdk.AIRSDKVersion;
	
	import flash.events.EventDispatcher;
	
	
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
		private var _queue:ProcessQueue;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function GenerateAppDescriptorCommand()
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
			return "generate an application descriptor with all package required additions";
		}
		
		
		public function get usage():String
		{
			return description + "\n" +
					"\n" +
					"apm generate app-descriptor             generates an application descriptor for your application with all required package additions\n" +
					"apm generate app-descriptor [out.xml]   generates an application descriptor updating the specified out.xml file\n"
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
			
			// TODO:: Get AIR SDK version for app descriptor
			var airSDKVersion:AIRSDKVersion = new AIRSDKVersion( "33.1.1.556" );
			var appDescriptor:ApplicationDescriptor = new ApplicationDescriptor( airSDKVersion );
			
			var outputPath:String = defaultOutputPath();
			if (_parameters.length > 0)
			{
				outputPath = _parameters[ 0 ];
			}
			
			_queue.addProcess( new ValidatePackageCacheProcess() );
			_queue.addProcess( new AndroidManifestMergeProcess( appDescriptor ) );
			_queue.addProcess( new IOSAdditionsMergeProcess( appDescriptor ) );
			_queue.addProcess( new IOSEntitlementsMergeProcess( appDescriptor ) );
			_queue.addProcess( new ApplicationDescriptorGenerationProcess( appDescriptor, outputPath ) );
			
			_queue.start(
					function ():void {
						dispatchEvent( new CommandEvent( CommandEvent.COMPLETE, APM.CODE_OK ) );
					},
					function ( error:String ):void {
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
			else
			{
				return "src/" + proj.applicationName.replace( / /g, "" ) + "-app.xml";
			}
		}
		
		
	}
}
