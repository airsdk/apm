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
 * @created		18/5/21
 */
package com.apm.data
{
	import com.apm.client.IO;
	
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	
	public class ProjectDefinition
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "ProjectDefinition";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _data:Object;
		
		private var _sourceFile:File;
		
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function ProjectDefinition()
		{
		}
		
		
		public function parse( content:String ):void
		{
			try
			{
				_data = JSON.parse( content );
				// TODO::
			}
			catch (e:Error)
			{
				IO.out( "Invalid project file - setting to defaults" );
			}
		}
		
		
		public function stringify():String
		{
			return JSON.stringify( toObject(), null, 4 );
		}
		
		
		public function toObject():Object
		{
			// TODO::
			return _data;
		}
		

		
		
		//
		//	IO
		//
		

		public function save( f:File=null ):void
		{
			if (f == null)
			{
				f = _sourceFile;
			}
			
			if (f == null)
			{
				throw new Error( "No output file specified" );
			}
			
			var content:String = stringify();
			
			var fs:FileStream = new FileStream();
			fs.open( f, FileMode.WRITE );
			fs.writeUTFBytes( content );
			fs.close();
		}
		
		
		public function load( f:File ):ProjectDefinition
		{
			if (!f.exists)
			{
				throw new Error( "File doesn't exist" );
			}
			
			_sourceFile = f;
			
			var fs:FileStream = new FileStream();
			fs.open( f, FileMode.READ );
			var content:String = fs.readUTFBytes( fs.bytesAvailable );
			fs.close();
			
			parse( content );
			
			return this;
		}
		
		
	}
	
}
