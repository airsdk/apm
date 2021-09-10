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
	import com.apple.plist.PlistUtils;
	
	
	/**
	 *
	 */
	public class PlistArrayEntry extends PlistEntry
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "PlistStringEntry";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function PlistArrayEntry( key:String )
		{
			super( key, "array" );
		}
		
		
		public function addEntry( entry:PlistEntry ):void
		{
			// Check if entry already exists
			for (var i:int = entries.length - 1; i >= 0; --i)
			{
				var e:PlistEntry = entries[ i ];
				if (entry.equals( e ))
				{
					entries[ i ] = PlistUtils.mergeEntry( entry, e );
					return;
				}
			}
			entries.push( entry );
		}
		
		
		override public function equals( entry:PlistEntry ):Boolean
		{
			if (super.equals( entry ))
			{
				var arrayEntry:PlistArrayEntry = entry as PlistArrayEntry;
				
				if (arrayEntry.entries.length != entries.length) return false;
				
				for each (var e:PlistEntry in entries)
				{
					var foundMatch:Boolean = false;
					for each (var ae:PlistEntry in arrayEntry.entries)
					{
						foundMatch ||= ae.equals( e );
					}
					if (!foundMatch) return false;
				}
				
				return true;
			}
			return false;
		}
		
		
		override public function valueXML():XML
		{
			var array:XML = <array></array>;
			for each (var entry:PlistEntry in entries)
			{
				array.appendChild( entry.valueXML() );
			}
			return array;
		}
		
	}
	
	
}
