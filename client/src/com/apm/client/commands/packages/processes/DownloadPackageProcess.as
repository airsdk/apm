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
	import com.apm.client.APM;
	import com.apm.client.analytics.Analytics;
	import com.apm.utils.PackageFileUtils;
	import com.apm.client.commands.packages.utils.PackageRequestUtils;
	import com.apm.client.logging.Log;
	import com.apm.client.processes.ProcessBase;
	import com.apm.data.packages.PackageVersion;
	import com.apm.utils.Checksum;
	import com.apm.utils.PackageFileUtils;
	
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
	import flash.utils.ByteArray;
	
	
	public class DownloadPackageProcess extends ProcessBase
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "DownloadPackageProcess";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _package:PackageVersion;
		private var _destination:File;
		private var _loader:URLLoader;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function DownloadPackageProcess( packageVersion:PackageVersion )
		{
			super();
			_package = packageVersion;
			
			var packagesDir:File = new File( APM.config.packagesDir );
			if (!packagesDir.exists) packagesDir.createDirectory();
			
			var packageDir:File = PackageFileUtils.directoryForPackage( APM.config.packagesDir, packageVersion.packageDef.identifier );
			if (!packageDir.exists) packageDir.createDirectory();
			
			_destination = packageDir.resolvePath(
					PackageFileUtils.filenameForPackage( packageVersion )
			);
		}
		
		
		override public function start( completeCallback:Function = null, failureCallback:Function = null ):void
		{
			super.start( completeCallback, failureCallback );
			APM.io.showProgressBar( "Downloading package : " + _package.packageDef.toString() );
			if (_destination.exists)
			{
				checkExistingFile( true );
			}
			else
			{
				downloadPackage();
			}
		}
		
		
		////////////////////////////////////////////////////////
		//	FILE CHECKS
		//
		
		private function checkExistingFile( downloadIfCheckFails:Boolean = false ):void
		{
			if (_destination.exists)
			{
				verifyFile( _package.checksum, function ( fileValid:Boolean ):void {
					checkExistingFileComplete( downloadIfCheckFails, fileValid );
				} );
			}
			else
			{
				checkExistingFileComplete( downloadIfCheckFails, false );
			}
		}
		
		
		private function checkExistingFileComplete( downloadIfCheckFails:Boolean, fileValid:Boolean ):void
		{
			if (fileValid)
			{
				APM.io.completeProgressBar( fileValid, "Package already downloaded" );
				complete();
			}
			else
			{
				if (downloadIfCheckFails)
				{
					return downloadPackage();
				}
				else
				{
					APM.io.writeLine( "Downloaded file failed checks - retry install again later!" );
					return failure( "Downloaded file failed checks" );
				}
			}
		}
		
		
		private function checkDownloadedFile():void
		{
			if (_destination.exists)
			{
				verifyFile( _package.checksum, checkDownloadFileComplete );
			}
			else
			{
				checkDownloadFileComplete( false );
			}
		}
		
		
		private function checkDownloadFileComplete( fileValid:Boolean ):void
		{
			if (fileValid)
			{
				APM.io.completeProgressBar( true, "downloaded" );
				Analytics.instance.download(
						_package.packageDef.identifier,
						_package.version.toString(),
						complete );
			}
			else
			{
				APM.io.completeProgressBar( false, "Downloaded file failed checks - retry install again later!" );
				failure( "Downloaded file failed checks" );
			}
		}
		
		
		private function verifyFile( checksum:String, callback:Function ):void
		{
			// No checksum provided so don't perform check
			if (checksum == null || checksum.length == 0)
			{
				callback( true );
			}
			else
			{
				if (_destination.exists)
				{
					Checksum.sha256Checksum( _destination, function( calculatedSum:String ):void
					{
						callback( calculatedSum == checksum );
					});
				}
			}
		}
		
		
		////////////////////////////////////////////////////////
		//	DOWNLOADING
		//
		
		private function isPrivateLicense():Boolean
		{
			return (_package.packageDef.license != null && !_package.packageDef.license.isPublic);
		}
		
		
		private var _httpStatus:int = 0;
		
		
		private function downloadPackage():void
		{
			_loader = new URLLoader();
			_loader.dataFormat = URLLoaderDataFormat.BINARY;
			_loader.addEventListener( Event.COMPLETE, loader_completeHandler );
			_loader.addEventListener( ProgressEvent.PROGRESS, loader_progressHandler );
			_loader.addEventListener( IOErrorEvent.IO_ERROR, loader_errorHandler );
			_loader.addEventListener( HTTPStatusEvent.HTTP_STATUS, loader_statusHandler );
			_loader.addEventListener( SecurityErrorEvent.SECURITY_ERROR, loader_securityErrorHandler );
			
			PackageRequestUtils.generateURLRequestForPackage(
					_package.sourceUrl,
					APM.config.user.githubToken,
					function ( req:URLRequest ):void {
						_loader.load( req );
					} );
		}
		
		
		private function loader_progressHandler( event:ProgressEvent ):void
		{
			if (event.bytesTotal > 0)
			{
				APM.io.updateProgressBar(
						event.bytesLoaded / event.bytesTotal,
						"Downloading package : " + _package.packageDef.toString() );
			}
		}
		
		
		private function loader_completeHandler( event:Event ):void
		{
			var data:ByteArray = event.target.data;
			
			var fileStream:FileStream = new FileStream();
			fileStream.addEventListener( Event.CLOSE, function ( event:Event ):void {
				event.currentTarget.removeEventListener( event.type, arguments.callee );
				checkDownloadedFile();
			} );
			
			fileStream.openAsync( _destination, FileMode.WRITE );
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
					if (isPrivateLicense())
					{
						message = "[" + _httpStatus + "] There was an issue accessing the package, this is a private package so check you have a valid license and that you have correctly set your github access token";
					}
					else
					{
						message = "[" + _httpStatus + "] There was an issue accessing the package";
					}
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
