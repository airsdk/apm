/**
 * @author 		Michael Archbold (https://michaelarchbold.com)
 * @created		28/5/2021
 */
package com.apm.client.logging
{
	import com.apm.client.APM;
	
	
	public class Log
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "Log";
		
		
		public static const LEVEL_NORMAL:int = 0;
		public static const LEVEL_WARN:int = 1;
		public static const LEVEL_INFO:int = 2;
		public static const LEVEL_DEBUG:int = 3;
		public static const LEVEL_VERBOSE:int = 4;
		
		
		
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
		 * Returns the current log level
		 */
		public static function get logLevel():int { return _logLevel; }
		
		
		/**
		 * Set the log output level
		 * @param level
		 */
		public static function setLogLevel( level:int ):void
		{
			_logLevel = level;
			v( TAG, "setLogLevel( " + logLevelDescription( level ) + " ) " )
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
				
				case LEVEL_WARN:
					return "warn";
				
				case LEVEL_INFO:
					return "info";
				
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
			APM.io.writeLine( tag + "::" + message );
		}
		
		
		/**
		 * Warn level logging
		 * @param tag
		 * @param message
		 */
		public static function w( tag:String, message:String ):void
		{
			if (_logLevel >= LEVEL_WARN)
			{
				APM.io.writeLine( tag + "::" + message );
			}
		}
		
		
		/**
		 * Info level logging
		 * @param tag
		 * @param message
		 */
		public static function i( tag:String, message:String ):void
		{
			if (_logLevel >= LEVEL_INFO)
			{
				APM.io.writeLine( "I::" + tag + "::" + message );
			}
		}
		
		
		
		/**
		 * Debug level logging
		 * @param tag
		 * @param message
		 */
		public static function d( tag:String, message:String ):void
		{
			if (_logLevel >= LEVEL_DEBUG)
			{
				APM.io.writeLine( "D::" + tag + "::" + message );
			}
		}
		
		
		/**
		 * Verbose logging output
		 * @param tag
		 * @param message
		 */
		public static function v( tag:String, message:String ):void
		{
			if (_logLevel >= LEVEL_VERBOSE)
			{
				APM.io.writeLine( "V::" + tag + "::" + message );
			}
		}
		
		
		/**
		 * Print error information
		 * @param tag
		 * @param error
		 */
		public static function e( tag:String, error:Error ):void
		{
			APM.io.writeLine( "E::" + tag + "::" + error.message );
			if (_logLevel >= LEVEL_DEBUG)
			{
				APM.io.writeLine( "E::" + tag + "::" + error.getStackTrace() );
			}
		}
		
	}
}
