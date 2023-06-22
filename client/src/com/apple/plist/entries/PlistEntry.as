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
 * @created		10/9/2021
 */
package com.apple.plist.entries
{
	/**
	 *
	 */
	public class PlistEntry
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "PlistEntry";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		public var key:String;
		public var type:String;
		
		public var entries:Array;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function PlistEntry( key:String, type:String )
		{
			this.key = key;
			this.type = type;
			entries = [];
		}
		
		
		/**
		 * Compares two entries
		 *
		 * @param entry
		 *
		 * @return true if equivalent and false otherwise
		 */
		public function equals( entry:PlistEntry ):Boolean
		{
			if (type != entry.type) return false;
			if (key != entry.key) return false;
			
			return true;
		}
		
		
		public function keyXML():XML
		{
			return <key>{key}</key>;
		}
		
		
		public function valueXML():XML
		{
			return <{type}></{type}>;
		}
		
		
		/**
		 * Processes the xml nodes in a "dict" or "array" and returns an array of PlistEntry objects
		 *
		 * @param xmlDict
		 *
		 * @return	<code>Array</code> of PlistEntry objects
		 */
		protected function processEntries( xmlDict:XML ):Array
		{
			entries = [];
			var key:String = "";
			for each (var node:XML in xmlDict.children())
			{
				var nodeName:String = String( node.name() );
				switch (nodeName)
				{
					case "key":
					{
						key = node.text();
						break;
					}
					
					case "string":
					{
						var stringEntry:PlistStringEntry = new PlistStringEntry( key );
						stringEntry.value = node.text();
						entries.push( stringEntry );
						key = "";
						break;
					}
					
					case "dict":
					{
						var dictEntry:PlistDictEntry = new PlistDictEntry( key );
						dictEntry.processEntries( node );
						entries.push( dictEntry );
						key = "";
						break;
					}
					
					case "array":
					{
						var arrayEntry:PlistArrayEntry = new PlistArrayEntry( key );
						arrayEntry.processEntries( node );
						entries.push( arrayEntry );
						key = "";
						break;
					}
					
					case "true":
					case "false":
					{
						var boolEntry:PlistBooleanEntry = new PlistBooleanEntry( key );
						boolEntry.value = (nodeName == "true");
						entries.push( boolEntry );
						key = "";
						break;
					}

					case "null":
					{
						var commentEntry:PlistCommentEntry = new PlistCommentEntry();
						commentEntry.value = node.toString();
						entries.push( commentEntry );
						key = "";
						break;
					}
				}
				
			}
			return entries;
		}
		
		
	}
	
	
}
