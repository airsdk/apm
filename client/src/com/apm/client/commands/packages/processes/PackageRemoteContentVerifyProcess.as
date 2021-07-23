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
 * @created		15/6/21
 */
package com.apm.client.commands.packages.processes
{
	import com.apm.client.APMCore;
	import com.apm.client.commands.packages.utils.PackageRequestUtils;
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
		
		private var _core:APMCore;
		private var _packageDefinition:PackageDefinitionFile;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function PackageRemoteContentVerifyProcess( core:APMCore, packageDefinition:PackageDefinitionFile )
		{
			_core = core;
			_packageDefinition = packageDefinition;
		}
		
		
		override public function start():void
		{
			_core.io.showSpinner( "Checking remote content: " + _packageDefinition.version.sourceUrl );
			
			for each (var dep:PackageDependency in _packageDefinition.dependencies)
			{
				_queue.addProcessToStart( new PackageDependenciesVerifyProcess( _core, dep ) );
			}
			
			// Check content available
			checkRemoteContent( _packageDefinition.version.sourceUrl, function ( success:Boolean, message:String ):void {
				_core.io.stopSpinner( success, success ? "Package content verified" : message );
				
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
					_core,
					function ( req:URLRequest ):void {
						_loader.load( req );
					} );
		}
		
		
		private function loader_progressHandler( event:ProgressEvent ):void
		{
		}
		
		
		private function loader_completeHandler( event:Event ):void
		{
		}
		
		
		private function loader_errorHandler( event:IOErrorEvent ):void
		{
		}
		
		
		private function loader_statusHandler( event:HTTPStatusEvent ):void
		{
			_loader.close();
			
			if (event.status == 200) _callback( true, "" );
			else _callback( false, "source url returned " + event.status );
		}
		
		
		private function loader_securityErrorHandler( event:SecurityErrorEvent ):void
		{
			_callback( false, event.text );
		}
		
		
	}
	
}
