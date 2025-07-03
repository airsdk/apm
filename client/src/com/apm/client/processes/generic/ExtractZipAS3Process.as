/**
 * @author 		Michael Archbold (https://michaelarchbold.com)
 * @created		28/5/2021
 */
package com.apm.client.processes.generic
{
	import com.apm.client.APM;
	import com.apm.client.logging.Log;
	import com.apm.client.processes.ProcessBase;
	
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	
	import org.as3commons.zip.IZipFile;
	import org.as3commons.zip.Zip;
	
	
	public class ExtractZipAS3Process extends ProcessBase
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "ExtractZipAS3Process";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		protected var _zipFile:File;
		protected var _outputDir:File;
		protected var _showOutputs:Boolean;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function ExtractZipAS3Process( zipFile:File, outputDir:File, showOutputs:Boolean=true )
		{
			_zipFile = zipFile;
			_outputDir = outputDir;
			_showOutputs = showOutputs;
		}
		
		
		override public function start( completeCallback:Function=null, failureCallback:Function=null ):void
		{
			super.start( completeCallback, failureCallback );
			
			var message:String = "extracting " + _zipFile.nativePath;
			
			if (_showOutputs)
				APM.io.showProgressBar( message );
			
			try
			{
				if (_zipFile.exists)
				{
					if (_outputDir.exists) _outputDir.deleteDirectory( true );
					_outputDir.createDirectory();
					
					var bytesLoaded:uint = 0;
					var sourceBytes:ByteArray = new ByteArray();
					
					var sourceStream:FileStream = new FileStream();
					sourceStream.open( _zipFile, FileMode.READ );
					sourceStream.readBytes( sourceBytes );
					sourceStream.close();
					
					var zip:Zip = new Zip();
					zip.loadBytes( sourceBytes );
					
					for (var i:uint = 0; i < zip.getFileCount(); i++)
					{
						var zipFile:IZipFile = zip.getFileAt( i );
						var extracted:File = _outputDir.resolvePath( zipFile.filename );
						
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
						
						if (_showOutputs)
							APM.io.updateProgressBar( bytesLoaded / sourceBytes.length, message );
					}
					if (_showOutputs)
						APM.io.completeProgressBar( true, "extracted" );
				}
				else
				{
					return failure( "zip file not found" );
				}
			}
			catch (e:Error)
			{
				Log.e( TAG, e );
				if (_showOutputs)
					APM.io.completeProgressBar( false, e.message );
			}
			complete();
		}
		
		
	}
	
}
