/**
 * @author 		Michael Archbold (https://michaelarchbold.com)
 * @created		10/9/2021
 */
package com.apple.plist.entries
{
	/**
	 *
	 */
	public class PlistBooleanEntry extends PlistEntry
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "PlistStringEntry";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _value:Boolean;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function PlistBooleanEntry( key:String )
		{
			super( key, "bool" );
		}
		
		
		public function get value():Boolean
		{
			return _value;
		}
		
		
		public function set value( value:Boolean ):void
		{
			_value = value;
		}
		
		
		override public function equals( entry:PlistEntry ):Boolean
		{
			if (super.equals( entry ))
			{
				return (value == (entry as PlistBooleanEntry).value);
			}
			return false;
		}
		
		
		override public function valueXML():XML
		{
			return <{value ? "true" : "false"}/>;
		}
		
	}
	
}
