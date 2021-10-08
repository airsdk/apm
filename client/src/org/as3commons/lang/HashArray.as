/*
 * Copyright 2007-2011 the original author or authors.
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

	public class HashArray {

		//These are all the properties and method names of Object, these are illegal names to be used as a key in a Dictionary:
		private static const illegalKeys:Array = ['hasOwnProperty', 'isPrototypeOf', 'propertyIsEnumerable', 'setPropertyIsEnumerable', 'toLocaleString', 'toString', 'valueOf', 'prototype', 'constructor'];

		private var _list:Array;
		private var _lookup:Dictionary;
		private var _lookUpPropertyName:String;
		private var _allowDuplicates:Boolean = false;

		public function HashArray( lookUpPropertyName:String, allowDuplicates:Boolean = false, items:Array = null) {
			super();
			init(lookUpPropertyName, allowDuplicates, items);
		}

		protected function init(lookUpPropertyName:String, allowDuplicates:Boolean, items:Array):void {
			_lookup = new Dictionary();
			_lookUpPropertyName = makeValidKey(lookUpPropertyName);
			_allowDuplicates = allowDuplicates;
			_list = [];
			add(items);
		}

		public function get allowDuplicates():Boolean {
			return _allowDuplicates;
		}

		public function set allowDuplicates(value:Boolean):void {
			_allowDuplicates = value;
		}

		public function get length():uint {
			return _list.length;
		}

		public function rehash():void {
			_lookup = new Dictionary();
			var len:uint = _list.length;
			var val:*;
			for (var i:uint; i < len; i++) {
				val = _list[i];
				if (val != null) {
					addToLookup(val)
				}
			}
		}

		protected function removeFromLookup(item:*):void {
			var value:* = _lookup[item[_lookUpPropertyName]];
			if ((value is Array) && (_allowDuplicates)) {
				var arr:Array = (value as Array);
				var idx:int = ArrayUtils.removeFirstOccurance(arr, item);
				if (arr.length < 1) {
					delete _lookup[item[_lookUpPropertyName]];
				}
			} else {
				delete _lookup[item[_lookUpPropertyName]];
			}
		}

		protected function addToLookup(newItem:*):void {
			var validKey:* = makeValidKey(newItem[_lookUpPropertyName]);
			if (_allowDuplicates) {
				var items:* = _lookup[validKey];
				var arr:Array;
				if (items == null) {
					_lookup[validKey] = [newItem];
				} else if (items is Array) {
					arr = (items as Array);
					arr[arr.length] = newItem;
				} else {
					arr = [];
					arr[arr.length] = items;
					arr[arr.length] = newItem;
					_lookup[validKey] = arr;
				}
			} else {
				var oldItem:* = _lookup[validKey];
				if (oldItem != null) {
					ArrayUtils.removeFirstOccurance(_list, oldItem);
				}
				_lookup[validKey] = newItem;
			}
		}

		protected function makeValidKey(propertyValue:*):* {
			if (!(propertyValue is String)) {
				return propertyValue;
			} else if (illegalKeys.indexOf(String(propertyValue)) > -1) {
				return String(propertyValue) + '_';
			}
			return propertyValue;
		}

		public function get(lookupPropertyValue:String):* {
			lookupPropertyValue = makeValidKey(lookupPropertyValue);
			return _lookup[lookupPropertyValue];
		}

		public function pop():* {
			var value:* = _list.pop();
			removeFromLookup(value);
			return value;
		}

		public function push(... parameters):uint {
			var len:uint = parameters.length;
			var args:Array;
			if (len == 1 && parameters[0] is Array) {
				args = parameters[0] as Array;
				len = args.length;
			} else {
				args = parameters;
			}
			var idx:int = 0;
			for (var i:uint = 0; i < len; i++) {
				var arg:* = args[i];
				addToLookup(arg);
				idx = _list.push(arg);
			}
			return idx;
		}

		protected function add(items:Array):void {
			if (items != null) {
				var len:uint = items.length;
				for (var i:uint = 0; i < len; i++) {
					pushOne(items[i]);
				}
			}
		}

		protected function pushOne(item:*):void {
			addToLookup(item);
			_list.push(item);
		}

		public function shift():* {
			var item:* = _list.shift();
			removeFromLookup(item);
			return item;
		}

		public function getArray():Array {
			return _list.concat();
		}

		public function splice(... parameters):* {
			var result:* = _list.splice(parameters);
			rehash();
			return result;
		}
	}
}