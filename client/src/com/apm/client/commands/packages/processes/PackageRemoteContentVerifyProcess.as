/**
 * @author 		Michael Archbold (https://michaelarchbold.com)
 * @created		15/6/2021
 */
package com.apm.client.commands.packages.processes
{
	import com.apm.client.APM;
	import com.apm.client.commands.packages.utils.PackageRequestUtils;
	import com.apm.client.logging.Log;
	import com.apm.client.processes.ProcessBase;
	import com.apm.data.packages.PackageDefinitionFile;
	import com.apm.data.packages.PackageDependency;
	
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	
	
	/**
	 * Verifies the remote content for a package, checking the package is available at the
	 * specified url and that all the linked dependencies are available in the package repository.
	 */
	public class PackageRemoteContentVerifyProcess extends ProcessBase
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "PackageRemoteContentVerifyProcess";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _packageDefinition:PackageDefinitionFile;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function PackageRemoteContentVerifyProcess( packageDefinition:PackageDefinitionFile )
		{
			_packageDefinition = packageDefinition;
		}
		
		
		override public function start( completeCallback:Function = null, failureCallback:Function = null ):void
		{
			super.start( completeCallback, failureCallback );
			APM.io.showSpinner( "Checking remote content: " + _packageDefinition.version.sourceUrl );
			
			for each (var dep:PackageDependency in _packageDefinition.dependencies)
			{
				_queue.addProcessToStart( new PackageDependenciesVerifyProcess( dep ) );
			}
			
			// Check content available
			checkRemoteContent( _packageDefinition.version.sourceUrl, function ( success:Boolean, message:String ):void {
				APM.io.stopSpinner( success, success ? "Package content verified" : message );
				
				if (success) complete();
				else failure();
			} );
		}
		
		
		private var _callback:Function;
		private var _loader:URLLoader;
		
		
		private function checkRemoteContent( url:String, callback:Function ):void
		{
			_callback = callback;
			
			_loader = new URLLoader();
			_loader.dataFormat = URLLoaderDataFormat.BINARY;
			_loader.addEventListener( Event.COMPLETE, loader_completeHandler );
			_loader.addEventListener( ProgressEvent.PROGRESS, loader_progressHandler );
			_loader.addEventListener( IOErrorEvent.IO_ERROR, loader_errorHandler );
			_loader.addEventListener( HTTPStatusEvent.HTTP_STATUS, loader_statusHandler );
			_loader.addEventListener( SecurityErrorEvent.SECURITY_ERROR, loader_securityErrorHandler );
			
			PackageRequestUtils.generateURLRequestForPackage(
					url,
					APM.config.user.githubToken,
					function ( req:URLRequest ):void {
						Log.d( TAG, "load( " + req.url + " )" );
						_loader.load( req );
					} );
		}
		
		
		private function loader_progressHandler( event:ProgressEvent ):void
		{
//			Log.d( TAG, "loader_progressHandler()" );
		}
		
		
		private function loader_completeHandler( event:Event ):void
		{
//			Log.d( TAG, "loader_completeHandler()" );
		}
		
		
		private function loader_errorHandler( event:IOErrorEvent ):void
		{
			Log.d( TAG, "loader_errorHandler( " + event.text + " )" );
		}
		
		
		private function loader_statusHandler( event:HTTPStatusEvent ):void
		{
			Log.d( TAG, "loader_statusHandler(): " + event.status );
			_loader.close();
			
			if (event.status == 200) _callback( true, "" );
			else _callback( false, "source url returned status: " + event.status );
		}
		
		
		private function loader_securityErrorHandler( event:SecurityErrorEvent ):void
		{
			Log.d( TAG, "loader_errorHandler( " + event.text + " )" );
			_callback( false, event.text );
		}
		
		
	}
	
}
