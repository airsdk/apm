/**
 * @author 		Michael Archbold (https://michaelarchbold.com)
 * @created		27/8/2021
 */
package com.apm.client.commands.project.processes
{
	import com.apm.SemVer;
	import com.apm.client.APM;
	import com.apm.client.Consts;
	import com.apm.client.logging.Log;
	import com.apm.client.processes.ProcessBase;
	import com.apm.utils.FileUtils;
	
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
	
	
	/**
	 * Checks that the merge tool is downloaded and available
	 */
	public class AndroidManifestMergeDependencyCheckProcess extends ProcessBase
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "AndroidManifestMergeDependencyCheckProcess";
		
		private static const SOURCE_URL:String = "https://github.com/distriqt/android-manifest-merger/releases/download/v@MERGE_TOOL_VERSION@/"
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _loader:URLLoader;
		private var _mergeUtility:File;
		private var _httpStatus:int;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function AndroidManifestMergeDependencyCheckProcess()
		{
		}
		
		
		override public function start( completeCallback:Function = null, failureCallback:Function = null ):void
		{
			super.start( completeCallback, failureCallback );
			try
			{
				var filename:String = AndroidManifestMerge.mergeToolFilename;
				var toolsDirectory:String = FileUtils.toolsDirectory.nativePath;
				
				if (!FileUtils.toolsDirectory.exists) FileUtils.toolsDirectory.createDirectory();
				
				_mergeUtility = FileUtils.toolsDirectory.resolvePath( filename );
	
				if (_mergeUtility.exists)
				{
					checkDownloadedFile();
				}
				else
				{
					downloadUtility();
				}
			}
			catch (e:Error)
			{
				trace( e ) ;
				failure( e.message );
			}
			
		}
		
		
		private function checkDownloadedFile():void
		{
			complete();
		}
		
		
		private function downloadUtility():void
		{
			APM.io.showProgressBar( "Downloading manifest merge tool" );
			
			var headers:Array = [];
			headers.push( new URLRequestHeader( "User-Agent", "apm v" + new SemVer( Consts.VERSION ).toString() ) );
			headers.push( new URLRequestHeader( "Accept", "application/octet-stream" ) );
			
			
			var url:String = SOURCE_URL.replace( /@MERGE_TOOL_VERSION@/g, AndroidManifestMerge.MERGE_TOOL_VERSION )
								+ AndroidManifestMerge.mergeToolFilename;
			
			var req:URLRequest = new URLRequest( url );
			req.method = URLRequestMethod.GET;
			req.requestHeaders = headers;
			
			_loader = new URLLoader();
			_loader.dataFormat = URLLoaderDataFormat.BINARY;
			_loader.addEventListener( Event.COMPLETE, loader_completeHandler );
			_loader.addEventListener( ProgressEvent.PROGRESS, loader_progressHandler );
			_loader.addEventListener( IOErrorEvent.IO_ERROR, loader_errorHandler );
			_loader.addEventListener( HTTPStatusEvent.HTTP_STATUS, loader_statusHandler );
			_loader.addEventListener( SecurityErrorEvent.SECURITY_ERROR, loader_securityErrorHandler );
			
			_loader.load( req );
		}
		
		
		private function loader_progressHandler( event:ProgressEvent ):void
		{
			if (event.bytesTotal > 0)
			{
				APM.io.updateProgressBar(
						event.bytesLoaded / event.bytesTotal,
						"Downloading manifest merge tool" );
			}
		}
		
		
		private function loader_completeHandler( event:Event ):void
		{
			var data:ByteArray = event.target.data;

			var fileStream:FileStream = new FileStream();
			fileStream.addEventListener( Event.CLOSE, function ( event:Event ):void {
				event.currentTarget.removeEventListener( event.type, arguments.callee );
				APM.io.completeProgressBar( true, "Merge tool available" );
				checkDownloadedFile();
			} );

			fileStream.openAsync( _mergeUtility, FileMode.WRITE );
			fileStream.writeBytes( data, 0, data.length );
			fileStream.close();
			
		}
		
		
		private function loader_errorHandler( event:IOErrorEvent ):void
		{
			var message:String = "";
			switch (_httpStatus)
			{
				case 404:
				{
					message = "[" + _httpStatus + "] There was an issue accessing the merge utility";
					break;
				}
				
				default:
					message = event.text;
			}
			APM.io.completeProgressBar( false, message );
			failure( message );
		}
		
		
		private function loader_statusHandler( event:HTTPStatusEvent ):void
		{
			Log.d( TAG, "loader_statusHandler(): " + event.status );
			_httpStatus = event.status;
		}
		
		
		private function loader_securityErrorHandler( event:SecurityErrorEvent ):void
		{
			APM.io.completeProgressBar( false, event.text );
			failure();
		}
		
	}
	
}
