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
 * @created		28/5/21
 */
package com.apm.client.commands.airsdk.processes
{
	import com.apm.client.APMCore;
	import com.apm.client.config.RunConfig;
	import com.apm.client.logging.Log;
	import com.apm.client.processes.Process;
	import com.apm.client.processes.events.ProcessEvent;
	import com.apm.remote.airsdk.AIRSDKAPI;
	import com.apm.remote.airsdk.AIRSDKBuild;
	
	import flash.events.Event;
	
	import flash.events.EventDispatcher;
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
	
	import org.as3commons.zip.IZipFile;
	
	import org.as3commons.zip.Zip;
	
	
	public class ExtractAIRSDKProcess extends EventDispatcher implements Process
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "ExtractAIRSDKProcess";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		
		private var _core:APMCore;
		private var _build:AIRSDKBuild;
		private var _source:File;
		private var _installPath:String;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function ExtractAIRSDKProcess( core:APMCore, build:AIRSDKBuild, source:File, installPath:String )
		{
			_core = core;
			_build = build;
			_source = source;
			_installPath = installPath;
		}
		
		
		public function start():void
		{
			Log.d( TAG, "start()" );
			
			_core.io.showProgressBar( "Extracting AIR SDK v" + _build.version );
			
			try
			{
				var destination:File = new File( _installPath );
				// TODO:: Check destination exists?
				if (_source.exists)
				{
					var bytesLoaded:uint = 0;
					var sourceBytes:ByteArray = new ByteArray();
					
					var sourceStream:FileStream = new FileStream();
					sourceStream.open( _source, FileMode.READ );
					sourceStream.readBytes( sourceBytes );
					sourceStream.close();
					
					var zip:Zip = new Zip();
					zip.loadBytes( sourceBytes );
					
					for (var i:uint = 0; i < zip.getFileCount(); i++)
					{
						var zipFile:IZipFile = zip.getFileAt(i);
						var extracted:File = destination.resolvePath(zipFile.filename);
						extracted.parent.createDirectory();
						
						if (zipFile.filename.charAt( zipFile.filename.length - 1 ) != "/")
						{
							if (!extracted.isDirectory)
							{
								var fs:FileStream = new FileStream();
								fs.open( extracted, FileMode.WRITE );
								fs.writeBytes( zipFile.content );
								fs.close();
							}
						}
						
						bytesLoaded += zipFile.sizeCompressed;
						
						_core.io.updateProgressBar( bytesLoaded / sourceBytes.length, "Extracting AIR SDK v" + _build.version );
					}
					_core.io.completeProgressBar( true, "extracted" );
				}
			}
			catch (e:Error)
			{
				_core.io.completeProgressBar( false, e.message );
			}
			dispatchEvent( new ProcessEvent( ProcessEvent.COMPLETE ) )
		}
		
		
		
		
	}
	
}
