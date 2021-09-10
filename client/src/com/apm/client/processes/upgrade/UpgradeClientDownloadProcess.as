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
 * @created		8/9/21
 */
package com.apm.client.processes.upgrade
{
	import com.apm.SemVer;
	import com.apm.client.Consts;
	import com.apm.client.processes.ProcessBase;
	
	import flash.events.Event;
	import flash.events.HTTPStatusEvent;
	import flash.events.IOErrorEvent;
	import flash.events.ProgressEvent;
	import flash.events.SecurityErrorEvent;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.URLLoader;
	import flash.net.URLLoaderDataFormat;
	import flash.net.URLRequest;
	import flash.net.URLRequestHeader;
	import flash.net.URLRequestMethod;
	import flash.utils.ByteArray;
	
	
	public class UpgradeClientDownloadProcess extends ProcessBase
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "UpgradeClientDownloadProcess";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _url:String;
		private var _destination:File;
		
		private var _loader:URLLoader;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function UpgradeClientDownloadProcess( url:String, destination:File )
		{
			_url = url;
			_destination = destination;
		}
		
		
		override public function start( completeCallback:Function = null, failureCallback:Function = null ):void
		{
			super.start( completeCallback, failureCallback );
			
			_loader = new URLLoader();
			_loader.dataFormat = URLLoaderDataFormat.BINARY;
			_loader.addEventListener( Event.COMPLETE, loader_completeHandler );
			_loader.addEventListener( ProgressEvent.PROGRESS, loader_progressHandler );
			_loader.addEventListener( IOErrorEvent.IO_ERROR, loader_errorHandler );
			_loader.addEventListener( HTTPStatusEvent.HTTP_STATUS, loader_statusHandler );
			_loader.addEventListener( SecurityErrorEvent.SECURITY_ERROR, loader_securityErrorHandler );
			
			var headers:Array = [
				new URLRequestHeader( "User-Agent", "apm v" + new SemVer( Consts.VERSION ).toString() ),
				new URLRequestHeader( "Accept", "application/octet-stream" )
			];
			
			var req:URLRequest = new URLRequest( _url );
			req.method = URLRequestMethod.GET;
			req.requestHeaders = headers;
			
			_loader.load( req );
			
		}
		
		
		private function loader_progressHandler( event:ProgressEvent ):void
		{
		}
		
		
		private function loader_completeHandler( event:Event ):void
		{
			var data:ByteArray = event.target.data;
			
			var fileStream:FileStream = new FileStream();
			fileStream.addEventListener( Event.CLOSE, function ( event:Event ):void {
				event.currentTarget.removeEventListener( event.type, arguments.callee );
				complete();
			} );
			
			fileStream.openAsync( _destination, FileMode.WRITE );
			fileStream.writeBytes( data, 0, data.length );
			fileStream.close();
		}
		
		
		private function loader_errorHandler( event:IOErrorEvent ):void
		{
			var message:String = "There was an issue accessing the update";
			failure( message );
		}
		
		
		private function loader_statusHandler( event:HTTPStatusEvent ):void
		{
//			Log.d( TAG, "loader_statusHandler(): " + event.status );
		}
		
		
		private function loader_securityErrorHandler( event:SecurityErrorEvent ):void
		{
			failure( event.text );
		}
		
		
	}
}
