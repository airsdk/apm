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
		
		private var _sourceFile : File;
		
		
		private var _githubToken : String = "";
		public function get githubToken():String { return _githubToken; }
		public function set githubToken(value:String):void { _githubToken = value; save(); }
		
		private var _publisherToken : String = "";
		public function get publisherToken():String { return _publisherToken; }
		public function set publisherToken(value:String):void { _publisherToken = value; save(); }
		
		private var _hasAcceptedLicense : Boolean = false;
		public function get hasAcceptedLicense():Boolean { return _hasAcceptedLicense; }
		public function set hasAcceptedLicense(value:Boolean):void { _hasAcceptedLicense = value; save(); }
		
		
		
		
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
				var data:Object = JSON.parse( content );
				if (data.hasOwnProperty("github_token"))
				{
					_githubToken = data["github_token"];
				}
				if (data.hasOwnProperty("publisher_token"))
				{
					_publisherToken = data["publisher_token"];
				}
				if (data.hasOwnProperty("has_accepted_license"))
				{
					_hasAcceptedLicense = data["has_accepted_license"];
				}
			}
			catch (e:Error)
			{
			}
		}
		
		
		public function toObject():Object
		{
			var data:Object = {};
			if (_githubToken != null && _githubToken.length > 0)
			{
				data["github_token"] = _githubToken;
			}
			if (_publisherToken != null && _publisherToken.length > 0)
			{
				data["publisher_token"] = _publisherToken;
			}
			data["has_accepted_license"] = _hasAcceptedLicense;
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
