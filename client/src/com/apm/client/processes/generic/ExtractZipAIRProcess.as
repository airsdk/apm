/**
 * @author 		Michael Archbold (https://michaelarchbold.com)
 * @created		2/6/2026
 */
package com.apm.client.processes.generic
{
	import com.apm.client.APM;
	import com.apm.client.logging.Log;
	import com.apm.client.processes.ProcessBase;

	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.ProgressEvent;
	import flash.filesystem.File;
	import flash.utils.getDefinitionByName;

	public class ExtractZipAIRProcess extends ProcessBase
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//

		private static const TAG:String = "ExtractZipAIRProcess";


		////////////////////////////////////////////////////////
		//  VARIABLES
		//

		protected var _zipFile:File;
		protected var _outputDir:File;
		protected var _showOutputs:Boolean;
		protected var _deleteDirectory:Boolean;

		private var _zip:Object;
		private var _zipDispatcher:IEventDispatcher;
		private var _message:String;


		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//


		public function ExtractZipAIRProcess( zipFile:File, outputDir:File, showOutputs:Boolean = true, deleteDirectory:Boolean = true )
		{
			_zipFile = zipFile;
			_outputDir = outputDir;
			_showOutputs = showOutputs;
			_deleteDirectory = deleteDirectory;
		}


		public static function isAvailable():Boolean
		{
			try
			{
				var zipArchiveClass:Class = getDefinitionByName( "air.utils.ZipArchive" ) as Class;
				return zipArchiveClass != null;
			}
			catch (e:Error)
			{
				return false;
			}
		}


		override public function start( completeCallback:Function = null, failureCallback:Function = null ):void
		{
			super.start( completeCallback, failureCallback );

			_message = "extracting " + _zipFile.nativePath;
			if (_showOutputs)
				APM.io.showProgressBar( _message );

			try
			{
				if (!_zipFile.exists)
				{
					if (_showOutputs)
						APM.io.completeProgressBar( false, "zip file not found" );
					return failure( "zip file not found" );
				}

				if (_outputDir.exists && _deleteDirectory) _outputDir.deleteDirectory( true );
				_outputDir.createDirectory();

				var zipArchiveClass:Class = getDefinitionByName( "air.utils.ZipArchive" ) as Class;
				if (zipArchiveClass == null)
					throw new Error( "AIR ZipArchive API not available" );

				_zip = zipArchiveClass["load"]( _zipFile );
				_zipDispatcher = _zip as IEventDispatcher;
				if (_zipDispatcher == null)
					throw new Error( "AIR ZipArchive did not return an event dispatcher" );

				_zipDispatcher.addEventListener( ProgressEvent.PROGRESS, onProgress );
				_zipDispatcher.addEventListener( Event.COMPLETE, onComplete );
				_zip["extractFilesAsync"]( _outputDir );
			}
			catch (e:Error)
			{
				cleanup();
				Log.e( TAG, e );
				if (_showOutputs)
					APM.io.completeProgressBar( false, e.message );
				failure( e.message );
			}
		}


		private function onProgress( event:ProgressEvent ):void
		{
			if (_showOutputs)
			{
				if (event.bytesTotal > 0)
					APM.io.updateProgressBar( event.bytesLoaded / event.bytesTotal, _message );
				else
					APM.io.updateProgressBar( 0, _message );
			}
		}


		private function onComplete( event:Event ):void
		{
			Log.d( TAG, "extracted " + _zipFile.nativePath + " to " + _outputDir.nativePath );
			cleanup();
			if (_showOutputs)
				APM.io.completeProgressBar( true, "extracted" );
			complete();
		}


		private function cleanup():void
		{
			if (_zipDispatcher != null)
			{
				_zipDispatcher.removeEventListener( ProgressEvent.PROGRESS, onProgress );
				_zipDispatcher.removeEventListener( Event.COMPLETE, onComplete );
				_zipDispatcher = null;
			}
			_zip = null;
		}

	}
}
