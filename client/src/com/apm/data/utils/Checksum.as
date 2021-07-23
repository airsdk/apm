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
 * @created		22/6/21
 */
package com.apm.data.utils
{
	import by.blooddy.crypto.SHA256;
	
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
		
		
		public static function sha256Checksum( f:File ):String
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
			return "";
		}
		
		
	}
	
}
