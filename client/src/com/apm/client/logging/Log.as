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
package com.apm.client.logging
{
	import com.apm.client.IO;
	
	
	public class Log
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "Log";
		
		
		public static const LEVEL_NORMAL:int = 0;
		public static const LEVEL_DEBUG:int = 1;
		public static const LEVEL_VERBOSE:int = 2;
		
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		
		////////////////////////////////////////////////////////
		//	SINGLETON INSTANCE
		//
		
		private static var _instance:Log;
		private static var _shouldCreateInstance:Boolean = false;
		
		
		/**
		 * The singleton instance of the Extension class.
		 */
		public static function get instance():Log
		{
			createInstance();
			return _instance;
		}
		
		
		/**
		 * @private
		 * Creates the actual singleton instance
		 */
		private static function createInstance():void
		{
			if (_instance == null)
			{
				_shouldCreateInstance = true;
				_instance = new Log();
				_shouldCreateInstance = false;
			}
		}
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function Log()
		{
			if (_shouldCreateInstance)
			{
			}
			else
			{
				throw new Error( "Use Log.instance to access this functionality" );
			}
		}
		
		
		private static var _logLevel:int = LEVEL_NORMAL;
		
		
		/**
		 * Set the log output level
		 * @param level
		 */
		public static function setLogLevel( level:int ):void
		{
			_logLevel = level;
			l( TAG, "setLogLevel( " + logLevelDescription(level) + " ) ")
		}
		
		
		/**
		 * Returns a descriptive name of the logging level
		 * @param level
		 * @return
		 */
		public static function logLevelDescription( level:int ):String
		{
			switch (level)
			{
				case LEVEL_NORMAL:
					return "normal";
				
				case LEVEL_DEBUG:
					return "debug";
				
				case LEVEL_VERBOSE:
					return "verbose";
			}
			return "unknown";
		}
		
		
		/**
		 * Regular level logging
		 *
		 * @param tag
		 * @param message
		 */
		public static function l( tag:String, message:String ):void
		{
			IO.out( tag + "::" + message + "\n" );
		}
		
		
		/**
		 * Debug level logging
		 * @param tag
		 * @param message
		 */
		public static function d( tag:String, message:String ):void
		{
			if (_logLevel >= LEVEL_DEBUG)
				IO.out( "D::" + tag + "::" + message + "\n" );
		}
		
		
		/**
		 * Verbose logging output
		 * @param tag
		 * @param message
		 */
		public static function v( tag:String, message:String ):void
		{
			if (_logLevel >= LEVEL_VERBOSE)
				IO.out( "D::" + tag + "::" + message + "\n" );
		}
		
		
	}
}
