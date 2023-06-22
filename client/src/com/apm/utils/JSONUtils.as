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
 * @created		28/6/2021
 */
package com.apm.utils
{
	
	public class JSONUtils
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "JSONUtils";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function JSONUtils()
		{
		}
		
		
		public static function addMissingKeys( data:Object, keyOrder:Array ):Array
		{
			for (var key:String in data)
			{
				var hasKeyInOrder:Boolean = false;
				for each (var keyInOrder:String in keyOrder)
				{
					if (keyInOrder == key)
					{
						hasKeyInOrder = true;
						break;
					}
				}
				if (!hasKeyInOrder) keyOrder.push( key );
				
				if (data[key] is Array)
				{
					for each (var o:Object in data[key])
					{
						addMissingKeys( o, keyOrder );
					}
				}
				else if (data[key] is Object)
				{
					addMissingKeys( data[key], keyOrder );
				}
			}
			return keyOrder;
		}
		
		
		public static function getMissingKeys( data:Object, keyOrder:Array, missingKeys:Array=null ):Array
		{
			if (missingKeys == null) missingKeys = [];
			for (var key:String in data)
			{
				var hasKey:Boolean = false;
				for each (var keyInOrder:String in keyOrder)
				{
					if (keyInOrder == key)
					{
						hasKey = true;
						break;
					}
				}
				for each (var missingKey:String in missingKeys)
				{
					if (missingKey == key)
					{
						hasKey = true;
						break;
					}
				}
				if (!hasKey) missingKeys.push( key );
				
				if (data[key] is Array)
				{
					for each (var o:Object in data[key])
					{
						getMissingKeys( o, keyOrder, missingKeys );
					}
				}
				else if (data[key] is Object)
				{
					getMissingKeys( data[key], keyOrder, missingKeys );
				}
			}
			return missingKeys;
		}
		
	}
}
