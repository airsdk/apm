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
 * @created		10/9/21
 */
package com.apple.plist.entries
{
	/**
	 *
	 */
	public class PlistDictEntry extends PlistEntry
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "PlistDictEntry";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function PlistDictEntry( key:String )
		{
			super( key, "dict" );
		}
		
		
		public function keys():Array
		{
			var keys:Array = [];
			for each (var entry:PlistEntry in entries)
			{
				keys.push( entry.key );
			}
			return keys;
		}
		
		
		public function getEntry( key:String ):PlistEntry
		{
			for each (var entry:PlistEntry in entries)
			{
				if (entry.key == key)
				{
					return entry;
				}
			}
			return null;
		}
		
		
		public function removeEntry( key:String ):void
		{
			for (var i:int = entries.length - 1; i >= 0; --i)
			{
				if (entries[i].key == key)
				{
					entries.splice( i, 1 );
				}
			}
		}
		
		
		public function addEntry( entry:PlistEntry ):void
		{
			entries.push( entry );
		}
		
		
		override public function equals( entry:PlistEntry ):Boolean
		{
			if (super.equals( entry ))
			{
				var dictEntry:PlistDictEntry = entry as PlistDictEntry;
				
				if (dictEntry.keys().length != keys().length) return false;
				
				for each (var e:PlistEntry in entries)
				{
					var compEntry:PlistEntry = dictEntry.getEntry( e.key );
					if (compEntry == null) return false;
					if (!compEntry.equals( e )) return false;
				}
				
				return true;
			}
			return false;
		}
		
		
		override public function valueXML():XML
		{
			var dict:XML = <dict></dict>;
			for each (var entry:PlistEntry in entries)
			{
				dict.appendChild( entry.keyXML() );
				dict.appendChild( entry.valueXML() );
			}
			return dict;
		}
		
		
	}
	
	
}
