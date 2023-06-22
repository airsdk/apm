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
 * @created		28/5/2021
 */
package com.apm.client.commands.airsdk.processes
{
	import com.apm.client.APM;
	import com.apm.client.logging.Log;
	import com.apm.client.processes.ProcessBase;
	import com.apm.remote.airsdk.AIRSDKAPI;
	import com.apm.remote.airsdk.AIRSDKBuild;
	
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
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	import flash.utils.ByteArray;
	
	
	public class DownloadAIRSDKProcess extends ProcessBase
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "DownloadAIRSDKProcess";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		
		private var _build:AIRSDKBuild;
		private var _destination:File;
		
		
		private var _loader:URLLoader;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function DownloadAIRSDKProcess( build:AIRSDKBuild, destination:File )
		{
			_build = build;
			_destination = destination;
		}
		
		
		override public function start( completeCallback:Function = null, failureCallback:Function = null ):void
		{
			super.start( completeCallback, failureCallback );
			Log.d( TAG, "start()" );
			APM.io.showProgressBar( "Downloading AIR v" + _build.version );
			if (_destination.exists)
			{
				checkExistingFile( true );
			}
			else
			{
				downloadFile();
			}
		}
		
		
		private function checkExistingFile( downloadIfCheckFails:Boolean = false ):void
		{
			var fileValid:Boolean = false;
			if (_destination.exists)
			{
				fileValid = verifyFile();
				APM.io.completeProgressBar( true, "AIR SDK already downloaded" );
			}
			
			if (!fileValid)
			{
				if (downloadIfCheckFails)
					return downloadFile();
				else
					APM.io.writeLine( "Downloaded file failed checks - retry download again later!" );
			}
			
			complete();
		}
		
		
		private function checkDownloadedFile():void
		{
			var fileValid:Boolean = false;
			if (_destination.exists)
			{
				fileValid = verifyFile();
			}
			if (fileValid)
			{
				APM.io.completeProgressBar( true, "downloaded" );
			}
			else
			{
				APM.io.completeProgressBar( false, "Downloaded file failed checks - retry download again later!" );
			}
			complete();
		}
		
		
		private function verifyFile():Boolean
		{
			// TODO: check sum ?
			return true;
		}
		
		
		private function downloadFile():void
		{
			var url:String = AIRSDKAPI.DOWNLOAD_ENDPOINT +
					(APM.config.isMacOS ? _build.urls[ "AIR_Mac" ] : _build.urls[ "AIR_Win" ]);
			
			var vars:URLVariables = new URLVariables();
			vars[ "license" ] = "accepted";
			
			var req:URLRequest = new URLRequest( url );
			req.method = URLRequestMethod.GET;
			req.data = vars;
			
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
						"Downloading AIR v" + _build.version );
			}
		}
		
		
		private function loader_completeHandler( event:Event ):void
		{
			var data:ByteArray = event.target.data;
			
			var fileStream:FileStream = new FileStream();
			fileStream.open( _destination, FileMode.WRITE );
			fileStream.writeBytes( data, 0, data.length );
			
			checkDownloadedFile();
		}
		
		
		private function loader_errorHandler( event:IOErrorEvent ):void
		{
			APM.io.completeProgressBar( false, event.text );
		}
		
		
		private function loader_statusHandler( event:HTTPStatusEvent ):void
		{
			Log.d( TAG, "loader_statusHandler(): " + event.status );
		}
		
		
		private function loader_securityErrorHandler( event:SecurityErrorEvent ):void
		{
			APM.io.completeProgressBar( false, event.text );
		}
		
		
	}
	
}
