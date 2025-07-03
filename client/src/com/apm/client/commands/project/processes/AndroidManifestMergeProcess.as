/**
 * @author 		Michael Archbold (https://michaelarchbold.com)
 * @created		23/8/2021
 */
package com.apm.client.commands.project.processes
{
	import com.apm.client.processes.ProcessBase;
	import com.apm.client.processes.ProcessQueue;
	import com.apm.data.project.ApplicationDescriptor;
	
	
	public class AndroidManifestMergeProcess extends ProcessBase
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "AndroidManifestMergeProcess";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _appDescriptor:ApplicationDescriptor;
		
		
		private var _subqueue:ProcessQueue;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function AndroidManifestMergeProcess( appDescriptor:ApplicationDescriptor )
		{
			_appDescriptor = appDescriptor;
		}
		
		
		override public function start( completeCallback:Function = null, failureCallback:Function = null ):void
		{
			super.start( completeCallback, failureCallback );
			
			_subqueue = new ProcessQueue();
			_subqueue.addProcess( new AndroidManifestMergeDependencyCheckProcess() );
			_subqueue.addProcess( new AndroidManifestMergeRunProcess( _appDescriptor ) );
			_subqueue.start( complete, failure );
			
		}
		
		
		
		
		
		
		
	}
	
}
