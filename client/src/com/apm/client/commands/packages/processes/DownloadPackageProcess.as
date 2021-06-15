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
	import com.apm.client.logging.Log;
	import com.apm.client.processes.ProcessBase;
	import com.apm.data.PackageDefinition;
	import com.apm.data.packages.PackageDefinition;
	
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
	import flash.utils.ByteArray;
	
	import flash.utils.setTimeout;
	
	
	public class DownloadPackageProcess extends ProcessBase
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "DownloadPackageProcess";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _core:APMCore;
		private var _packageDefinition:PackageDefinition;
		private var _destination:File;
		private var _loader:URLLoader;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function DownloadPackageProcess( core:APMCore, packageDefinition:PackageDefinition )
		{
			super();
			_core = core;
			_packageDefinition = packageDefinition;
			
			var packagesDir:File = new File( _core.config.packagesDir );
			if (!packagesDir.exists) packagesDir.createDirectory();
			
			var packageDir:File = new File( _core.config.packagesDir + File.separator + _packageDefinition.identifier );
			if (!packageDir.exists) packageDir.createDirectory();
			
			_destination = packageDir.resolvePath( _packageDefinition.identifier + "."+ _packageDefinition.type );
		}
		
		
		override public function start():void
		{
			_core.io.showProgressBar( "Downloading package : " + _packageDefinition.toString() );
			if (_destination.exists)
			{
				checkExistingFile( true );
			}
			else
			{
				downloadPackage();
			}
		}
		
		
		private function checkExistingFile( downloadIfCheckFails:Boolean = false ):void
		{
			var fileValid:Boolean = false;
			if (_destination.exists)
			{
				fileValid = verifyFile();
				_core.io.completeProgressBar( true, "Package already downloaded" );
			}
			
			if (!fileValid)
			{
				if (downloadIfCheckFails)
					return downloadPackage();
				else
					_core.io.writeLine( "Downloaded file failed checks - retry install again later!" );
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
				_core.io.completeProgressBar( true, "downloaded" );
			}
			else
			{
				_core.io.completeProgressBar( false, "Downloaded file failed checks - retry install again later!" );
			}
			complete();
		}
		
		
		private function verifyFile():Boolean
		{
			// TODO: check sum ?
			return true;
		}
		
		
		private function downloadPackage():void
		{
			var req:URLRequest = new URLRequest( _packageDefinition.versions[0].sourceUrl );
			req.method = URLRequestMethod.GET;
			
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
				_core.io.updateProgressBar(
						event.bytesLoaded / event.bytesTotal,
						"Downloading package : " + _packageDefinition.toString() );
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
			_core.io.completeProgressBar( false, event.text );
			complete();
		}
		
		private function loader_statusHandler( event:HTTPStatusEvent ):void
		{
			Log.d( TAG, "loader_statusHandler(): " + event.status );
		}
		
		private function loader_securityErrorHandler( event:SecurityErrorEvent ):void
		{
			_core.io.completeProgressBar( false, event.text );
			complete();
		}
		
		
	}
	
}
