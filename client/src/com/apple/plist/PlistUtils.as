/**
 * @author 		Michael Archbold (https://michaelarchbold.com)
 * @created		10/9/2021
 */
package com.apple.plist
{
	import com.apple.plist.entries.PlistArrayEntry;
	import com.apple.plist.entries.PlistBooleanEntry;
	import com.apple.plist.entries.PlistDictEntry;
	import com.apple.plist.entries.PlistEntry;
	import com.apple.plist.entries.PlistStringEntry;

	/**
	 *
	 */
	public class PlistUtils
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//

		private static const TAG:String = "Plist";


		////////////////////////////////////////////////////////
		//  VARIABLES
		//


		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//


		/**
		 * Combines the values in the two plist files and produces a new merged.
		 * <br/>
		 * Duplicate values are merged
		 *
		 * @param plistA	First plist file
		 * @param plistB	Second plist file
		 *
		 * @return	plist file with entries from both plist files merged
		 */
		public static function merge( plistA:Plist, plistB:Plist ):Plist
		{
			var out:Plist = new Plist();
			var keys:Array = uniqueJoin( plistA.keys(), plistB.keys() );
			for each (var key:String in keys)
			{
				var entryA:PlistEntry = plistA.getEntry( key );
				var entryB:PlistEntry = plistB.getEntry( key );

				out.addEntry( mergeEntry( entryA, entryB ) );
			}

			return out;
		}


		private static function uniqueJoin( a:Array, b:Array ):Array
		{
			var result:Array = a.concat();
			for each (var bo:* in b)
			{
				var isDuplicate:Boolean = false;
				for each (var ao:* in a)
				{
					isDuplicate ||= (bo == ao);
				}
				if (!isDuplicate)
				{
					result.push( bo );
				}
			}
			return result;
		}


		public static function mergeEntry( entryA:PlistEntry, entryB:PlistEntry ):PlistEntry
		{
			if (entryA == null) return entryB;
			if (entryB == null) return entryA;

			if (entryA.type != entryB.type)
				throw new Error( "cannot merge differing entry types for key: " + entryA.key );

			switch (entryA.type)
			{
				case "string":
				{
					var entryAString:PlistStringEntry = entryA as PlistStringEntry;
					var entryBString:PlistStringEntry = entryB as PlistStringEntry;

					// Custom handling of some fields
					if (entryA.key == "MinimumOSVersion")
					{
						var numericA:Number = Number( entryAString.value );
						var numericB:Number = Number( entryBString.value );

						if (numericA > numericB) return entryA;
						else return entryB;
					}

					// Return the first entry
					return entryA;
				}

				case "bool":
				{
					// Return the value that is "true" or return the first entry
					var entryABool:PlistBooleanEntry = entryA as PlistBooleanEntry;
					var entryBBool:PlistBooleanEntry = entryB as PlistBooleanEntry;

					if (entryABool.value) return entryABool;
					if (entryBBool.value) return entryBBool;
					return entryABool;
				}

				case "dict":
				{
					// Iterate over each key and merge values
					var entryADict:PlistDictEntry = entryA as PlistDictEntry;
					var entryBDict:PlistDictEntry = entryB as PlistDictEntry;

					var mergedDictEntry:PlistDictEntry = new PlistDictEntry( entryADict.key );

					var keys:Array = uniqueJoin( entryADict.keys(), entryBDict.keys() );

					for each (var key:String in keys)
					{
						var entryFromEntryADict:PlistEntry = entryADict.getEntry( key );
						var entryFromEntryBDict:PlistEntry = entryBDict.getEntry( key );

						mergedDictEntry.addEntry(
								mergeEntry(
										entryFromEntryADict,
										entryFromEntryBDict
								)
						);
					}

					return mergedDictEntry;
				}

				case "array":
				{
					// Ensure each value is unique - can have multiple of the same type
					var entryAArray:PlistArrayEntry = entryA as PlistArrayEntry;
					var entryBArray:PlistArrayEntry = entryB as PlistArrayEntry;

					var mergedArrayEntry:PlistArrayEntry = new PlistArrayEntry( entryAArray.key );

					for each (var entryInA:PlistEntry in entryAArray.entries)
					{
						mergedArrayEntry.addEntry( entryInA );
					}

					for each (var entryInB:PlistEntry in entryBArray.entries)
					{
						mergedArrayEntry.addEntry( entryInB );
					}

					return mergedArrayEntry;
				}
			}

			return entryA;
		}


	}

}
