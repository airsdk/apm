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
	 * Contains user specific settings for APMConsoleApp across all projects.
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
		
		public static const DEFAULT_FILENAME:String = ".apm_config";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _sourceFile:File;
		
		private var _githubToken:String = "";
		private var _publisherToken:String = "";
		private var _hasAcceptedLicense:Boolean = false;
		private var _disableTerminalControlSequences:Boolean = false;
		
		
		public function get githubToken():String { return _githubToken; }
		
		
		public function set githubToken( value:String ):void
		{
			_githubToken = value;
			save();
		}
		
		
		public function get publisherToken():String { return _publisherToken; }
		
		
		public function set publisherToken( value:String ):void
		{
			_publisherToken = value;
			save();
		}
		
		
		public function get hasAcceptedLicense():Boolean { return _hasAcceptedLicense; }
		
		
		public function set hasAcceptedLicense( value:Boolean ):void
		{
			_hasAcceptedLicense = value;
			save();
		}
		
		
		public function get disableTerminalControlSequences():Boolean { return _disableTerminalControlSequences; }
		
		
		public function set disableTerminalControlSequences( value:Boolean ):void
		{
			_disableTerminalControlSequences = value;
			save();
		}
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function UserSettings()
		{
		}
		
		
		public function getParamNames():Array
		{
			return ["publisher_token", "github_token", "disable_terminal_control_sequences"];
		}
		
		
		public function getParamValue( name:String ):String
		{
			switch (name)
			{
				case "publisher_token":
				{
					return publisherToken;
				}
				case "github_token":
				{
					return githubToken;
				}
				case "disable_terminal_control_sequences":
				{
					return disableTerminalControlSequences ? "true" : "false";
				}
			}
			return null;
		}
		
		
		public function setParamValue( name:String, value:String ):void
		{
			switch (name)
			{
				case "publisher_token":
				{
					publisherToken = value;
					break;
				}
				case "github_token":
				{
					githubToken = value;
					break;
				}
				case "disable_terminal_control_sequences":
				{
					disableTerminalControlSequences = (value == "true" || value == "1");
					break;
				}
			}
		}
		
		
		public function parse( content:String ):void
		{
			try
			{
				var data:Object = JSON.parse( content );
				if (data.hasOwnProperty( "github_token" ))
				{
					_githubToken = data[ "github_token" ];
				}
				if (data.hasOwnProperty( "publisher_token" ))
				{
					_publisherToken = data[ "publisher_token" ];
				}
				if (data.hasOwnProperty( "has_accepted_license" ))
				{
					_hasAcceptedLicense = data[ "has_accepted_license" ];
				}
				if (data.hasOwnProperty( "disable_terminal_control_sequences" ))
				{
					_disableTerminalControlSequences = data[ "disable_terminal_control_sequences" ];
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
				data[ "github_token" ] = _githubToken;
			}
			if (_publisherToken != null && _publisherToken.length > 0)
			{
				data[ "publisher_token" ] = _publisherToken;
			}
			data[ "has_accepted_license" ] = _hasAcceptedLicense;
			
			if (_disableTerminalControlSequences)
			{
				data[ "disable_terminal_control_sequences" ] = _disableTerminalControlSequences;
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
			_sourceFile = f;
			
			if (f == null || !f.exists)
			{
				throw new Error( "User settings file doesn't exist" );
			}
			
			var fs:FileStream = new FileStream();
			fs.open( f, FileMode.READ );
			var content:String = fs.readUTFBytes( fs.bytesAvailable );
			fs.close();
			
			parse( content );
			
			return this;
		}
		
		
	}
	
}
