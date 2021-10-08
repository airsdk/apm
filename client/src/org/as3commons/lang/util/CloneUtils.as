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
package org.as3commons.lang.util {
	import flash.utils.Dictionary;

	import org.as3commons.lang.Assert;
	import org.as3commons.lang.ICloneable;

	/**
	 * Helper functions for working with <code>ICloneable</code> implementations.
	 * @author Roland Zwaga
	 */
	public final class CloneUtils {

		/**
		 * Loops over the specified <code>Array</code> of <code>ICloneables</code> and returns a
		 * new <code>Array</code> populated with the <code>ICloneable.clone()</code> results.
		 * @param cloneables The specified <code>Array</code> of <code>ICloneables</code>.
		 * @return The specified new <code>Array</code> of <code>ICloneable.clone()</code> results.
		 */
		public static function cloneList(cloneables:Array):Array {
			Assert.notNull(cloneables, "cloneables argument must not be null");
			var clone:Array = [];
			for each (var cloneable:ICloneable in cloneables) {
				clone[clone.length] = cloneable.clone();
			}
			return clone;
		}

		/**
		 *
		 * @param dictionary
		 * @return
		 */
		public static function cloneDictionary(dictionary:Dictionary):Dictionary {
			var clone:Dictionary = new Dictionary();
			for (var keyValue:* in dictionary) {
				var value:* = dictionary[keyValue];
				var key:* = (keyValue is ICloneable) ? ICloneable(keyValue) : keyValue;
				clone[key] = (value is ICloneable) ? ICloneable(value) : value;
			}
			return clone;
		}

	}
}