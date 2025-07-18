/**
 * @author 		Michael Archbold (https://michaelarchbold.com)
 * @created		10/9/2021
 */
package com.apple.plist.entries
{
	/**
	 *
	 */
	public class PlistStringEntry extends PlistEntry
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "PlistStringEntry";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _value:String = "";
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function PlistStringEntry( key:String )
		{
			super( key, "string" );
		}
		
		
		public function get value():String
		{
			return _value;
		}
		
		
		public function set value( value:String ):void
		{
			_value = value;
		}
		
		
		override public function equals( entry:PlistEntry ):Boolean
		{
			if (super.equals( entry ))
			{
				return (value.toLowerCase() == (entry as PlistStringEntry).value.toLowerCase());
			}
			return false;
		}
		
		
		override public function valueXML():XML
		{
			return <{type}>{_value}</{type}>;
		}
		
		
	}
	
	
}
