/**
 * @author 		Michael Archbold (https://michaelarchbold.com)
 * @created		10/9/2021
 */
package com.apple.plist.entries
{
	import mx.utils.UIDUtil;

	/**
	 *
	 */
	public class PlistCommentEntry extends PlistEntry
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//

		private static const TAG:String = "PlistDictEntry";


		////////////////////////////////////////////////////////
		//  VARIABLES
		//

		private var _value:String;

		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//

		public function PlistCommentEntry()
		{
			super( generateUniqueIdentifier(), "comment" );
		}


		private function generateUniqueIdentifier():String
		{
			return "comment-" + UIDUtil.createUID();
		}


		public function get value():String
		{
			return _value;
		}


		public function set value( value:String ):void
		{
			_value = value;
		}


		override public function keyXML():XML
		{
			return new XML();
		}


		override public function valueXML():XML
		{
			return new XML( value );
		}


		override public function equals( entry:PlistEntry ):Boolean
		{
			if (super.equals( entry ))
			{
				return (value == (entry as PlistCommentEntry).value);
			}
			return false;
		}


	}


}
