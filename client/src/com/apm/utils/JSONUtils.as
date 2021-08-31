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
 * @created		28/6/21
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
				if (!hasKeyInOrder) keyOrder.push( key );
			}
			return keyOrder;
		}
		
	}
}
