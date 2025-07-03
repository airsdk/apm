/**
 * @author 		Michael Archbold (https://michaelarchbold.com)
 * @created		22/6/2021
 */
package com.apm.utils
{
	import by.blooddy.crypto.SHA256;
	
	import com.apm.client.processes.generic.ChecksumProcess;
	
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.utils.ByteArray;
	
	
	public class Checksum
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "Checksum";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function Checksum()
		{
		}
		
		
		public static function sha256Checksum( f:File, callback:Function=null ):String
		{
			if (callback == null)
			{
				var data:ByteArray = new ByteArray();
				
				var fs:FileStream = new FileStream();
				fs.open( f, FileMode.READ );
				fs.readBytes( data );
				fs.close();
				
				try
				{
					return SHA256.hashBytes( data );
				}
				catch (e:Error)
				{
				}
			}
			else
			{
				var process:ChecksumProcess = new ChecksumProcess( f );
				process.start(
						function( data:Object ):void
						{
							callback( data );
						},
						function( error:String ):void
						{
							callback( null );
						});
			}
			return null;
		}
		
		
	}
	
}
