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
package com.apm.data.user
{
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	
	/**
	 * The user settings / config file, located at HOME_DIRECTORY / .apm_config
	 * <br/>
	 *
	 * Contains user specific settings for APM across all projects.
	 * <br/>
	 *
	 * May be empty or not present.
	 */
	public class UserSettings
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "UserSettings";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		
		public var github_token : String = "";
		
		
		
		
		private var _data : Object;
		private var _sourceFile : File;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function UserSettings()
		{
		}
		
		
		public function parse( content:String ):void
		{
			try
			{
				_data = JSON.parse( content );
				
				if (_data.hasOwnProperty("github_token"))
				{
					github_token = _data.github_token;
				}
			}
			catch (e:Error)
			{
			}
		}
		
		
		public function toObject():Object
		{
			var data:Object = {};
			if (github_token != null && github_token.length > 0)
			{
				data["github_token"] = github_token;
			}
			return data;
		}
		
		
		public function stringify():String
		{
			return JSON.stringify( toObject(), null, 4 ) + "\n";
		}
		
		
		
		//
		//	IO
		//
		
		/**
		 * Saves the user settings into the specified file.
		 *
		 * @param f
		 */
		public function save( f:File = null ):void
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
		
		
		public function load( f:File ):UserSettings
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
