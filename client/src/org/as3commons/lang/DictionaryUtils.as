/*
 * Copyright 2009-2010 the original author or authors.
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
package org.as3commons.lang {
	
	import flash.utils.Dictionary;
	
	/**
	 * Contains utilities for working with Dictionaries.
	 *
	 * @author Christophe Herreman
	 */
	public final class DictionaryUtils {
		
		/**
		 * Returns an array with the keys of the dictionary.
		 *
		 */
		public static function getKeys(dictionary:Dictionary):Array {
			return ObjectUtils.getKeys(dictionary);
		}
		
		/**
		 * Check whether the given dictionary contains the given key.
		 *
		 * @param dictionary the dictionary to check for a key
		 * @param key the key to look up in the dictionary
		 * @return <code>true</code> if the dictionary contains the given key, <code>false</code> if not
		 */
		public static function containsKey(dictionary:Dictionary, key:Object):Boolean {
			var result:Boolean = false;
			
			for (var k:*in dictionary) {
				if (key === k) {
					result = true;
					break;
				}
			}
			return result;
		}
		
		/**
		 * Check whether the given dictionary contains the given value.
		 *
		 * @param dictionary the dictionary to check for a value
		 * @param value the value to look up in the dictionary
		 * @return <code>true</code> if the dictionary contains the given value, <code>false</code> if not
		 */
		public static function containsValue(dictionary:Dictionary, value:Object):Boolean {
			var result:Boolean = false;
			
			for each (var i:*in dictionary) {
				if (i === value) {
					result = true;
					break;
				}
			}
			return result;
		}
	}
}
