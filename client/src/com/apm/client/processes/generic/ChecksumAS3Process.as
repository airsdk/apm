/**
 * @author 		Michael Archbold (https://michaelarchbold.com)
 * @created		13/8/2021
 */
package com.apm.client.processes.generic
{
	import by.blooddy.crypto.SHA256;
	import by.blooddy.crypto.events.ProcessEvent;
	
	import com.apm.client.APM;
	
	import com.apm.client.logging.Log;
	
	import com.apm.client.processes.ProcessBase;
	
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	
	
	public class ChecksumAS3Process extends ProcessBase
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "ChecksumAS3Process";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		protected var _core:APM;
		protected var _file:File;
		private var _hash:SHA256;
		private var _data:ByteArray;

		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function ChecksumAS3Process( core:APM, file:File )
		{
			_core = core;
			_file = file;
		}
		
		
		override public function start( completeCallback:Function = null, failureCallback:Function = null ):void
		{
			super.start( completeCallback, failureCallback );
			Log.d( TAG, "start: " + _file.name );
			_data = new ByteArray();
			
			var fs:FileStream = new FileStream();
			fs.open( _file, FileMode.READ );
			fs.readBytes( _data );
			fs.close();
			
			try
			{
				_hash = new SHA256();
				_hash.addEventListener( ProcessEvent.COMPLETE, hashCompleteHandler );
				_hash.addEventListener( ProcessEvent.ERROR, hashErrorHandler );
				_hash.hashBytes( _data );
			}
			catch (e:Error)
			{
			}
		}
		
		
		private function hashCompleteHandler( event:ProcessEvent ):void
		{
			var result:String = event.data;
			
			_data.clear();
			_data = null;
			
			complete( result );
		}
		
		
		private function hashErrorHandler( event:ProcessEvent ):void
		{
			var error:Error = event.data;
			failure( error.message );
		}
		
		
	}
}
