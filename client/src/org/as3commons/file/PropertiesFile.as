/**
 * @author 		Michael Archbold (https://michaelarchbold.com)
 * @created		5/10/2021
 */
package org.as3commons.file
{
	import org.as3commons.lang.StringUtils;
	
	
	/**
	 * This class gives the ability to load "properties" files in which configuration
	 * properties are listed as a series of "VariableName=Value" lines.
	 * <br/>
	 * <listing>
	 * PropertyA=SomeValue
	 * AnotherProperty=SomeOtherValue
	 * </listing>
	 */
	public class PropertiesFile
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "PropertiesFile";
		
		private static const HASH_CHARCODE:uint = 35; //= "#";
		private static const EXCLAMATION_MARK_CHARCODE:uint = 33; //= "!";
		private static const DOUBLE_BACKWARD_SLASH:String = '\\';
		private static const NEWLINE_CHAR:String = "\n";
		private static const NEWLINE_REGEX:RegExp = /\\n/gm;
		private static const SINGLE_QUOTE_CHARCODE:uint = 39; // = "'";
		private static const COLON_CHARCODE:uint = 58; //:
		private static const EQUALS_CHARCODE:uint = 61; //=
		private static const TAB_CHARCODE:uint = 9;
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _properties:Object;
		/**
		 * Properties loaded from the file
		 */
		public function get properties():Object { return _properties; }
		
		
		public function set properties( value:Object ):void { _properties = value; }
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function PropertiesFile()
		{
		}
		
		
		public function parse( source:String ):Object
		{
			_properties = {};
			try
			{
				var lines:Array = source.split( NEWLINE_CHAR );
				
				var key:String;
				var value:String;
				var formerKey:String;
				var formerValue:String;
				var useNextLine:Boolean = false;
				
				for (var i:int = 0; i < lines.length; i++)
				{
					var line:String = StringUtils.trim( lines[ i ] );
					if (isPropertyLine( line ))
					{
						// Line break processing
						if (useNextLine)
						{
							key = formerKey;
							value = formerValue + line;
							useNextLine = false;
						}
						else
						{
							var sep:int = getSeparation( line );
							key = StringUtils.rightTrim( line.substr( 0, sep ) );
							value = line.substring( sep + 1 );
							formerKey = key;
							formerValue = value;
						}
						// Trim the content
						value = StringUtils.leftTrim( value );
						
						// Allow normal lines
						var end:String = value.substring( value.length - 1 );
						if (end == DOUBLE_BACKWARD_SLASH)
						{
							formerValue = value = value.substr( 0, value.length - 1 );
							useNextLine = true;
						}
						else
						{
							// restore newlines since these were escaped when loaded
							value = value.replace( NEWLINE_REGEX, NEWLINE_CHAR );
							
							_properties[ key ] = value;
						}
					}
				}
			}
			catch (e:Error)
			{
				trace( e );
			}
			return _properties;
		}
		
		
		public function isPropertyLine( line:String ):Boolean
		{
			return (line.charCodeAt( 0 ) != HASH_CHARCODE &&
					line.charCodeAt( 0 ) != EXCLAMATION_MARK_CHARCODE &&
					line.length != 0);
		}
		
		
		protected function getSeparation( line:String ):int
		{
			var len:int = line.length;
			for (var i:int = 0; i < len; i++)
			{
				var char:uint = line.charCodeAt( i );
				if (char == SINGLE_QUOTE_CHARCODE)
				{
					i++;
				}
				else
				{
					if (char == COLON_CHARCODE || char == EQUALS_CHARCODE || char == TAB_CHARCODE)
					{
						break;
					}
				}
			}
			return ((i == len) ? line.length : i);
		}
		
		
	}
}
