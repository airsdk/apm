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
package org.as3commons.lang.builder {

	import flash.utils.getQualifiedClassName;

	import org.as3commons.lang.IEquals;
	import org.as3commons.lang.ObjectUtils;

	/**
	 * <p>Assists in implementing IEquals.equals() methods.</p>
	 *
	 * <p>This class provides methods to build a good equals method for any class.</p>
	 *
	 * <p>All relevant fields should be included in the calculation of equals.</p>
	 *
	 * <p>Typical use for the code is as follows:</p>
	 * <pre>
	 * public function equals(object:Object):Boolean {
	 *   if (!object) { return false; }
	 *   if (object == this) { return true; }
	 *   if (!(object is MyClass)) {
	 *     return false;
	 *   }
	 *   MyClass that = MyClass(object);
	 *   return new EqualsBuilder()
	 *                 .append(field1, that.field1)
	 *                 .append(field2, that.field2)
	 *                 .append(field3, that.field3)
	 *                 .equals;
	 *  }
	 * </pre>
	 *
	 * @author Christophe Herreman
	 */
	public class EqualsBuilder {

		private var _equals:Boolean = true;

		/**
		 * Creates a new EqualsBuilder
		 */
		public function EqualsBuilder() {
			super();	
		}

		/**
		 * Returns if the objects tested for equality by this equalsbuilder are equal.
		 *
		 * @return true if both objects are equal, false if not
		 */
		public function get equals():Boolean {
			return _equals;
		}

		/**
		 * Test if two <code>Object</code>s are equal.
		 *
		 * @param a the left hand object
		 * @param b the right hand object
		 * @return EqualsBuilder - used to chain calls.
		 */
		public function append(a:Object, b:Object):EqualsBuilder {
			if (equals == false) {
				return this;
			}

			if (a === b) {
				return this;
			}

			if (a == null || b == null) {
				_equals = false;
				return this;
			}

			if (getQualifiedClassName(a) != getQualifiedClassName(b)) {
				_equals = false;
				return this;
			}

			if (ObjectUtils.isSimple(a)) {
				if (a is Array) {
					appendArray(a as Array, b as Array);
				} else if (a is Date) {
					appendDate(a as Date, b as Date);
				} else if ((typeof(a) == "number") && (isNaN(Number(a)) && isNaN(Number(b)))) {
					return this;
				} else {
					_equals = false;
					return this;
				}
			} else if (a is XML) {
				appendXML(XML(a), XML(b));
			} else if (a is IEquals) {
				appendEquals(IEquals(a), IEquals(b));
			} else {
				appendObject(a, b);
			}

			return this;
		}

		private function appendObject(a:Object, b:Object):EqualsBuilder {
			if (!_equals) {
				return this;
			}

			if (ObjectUtils.getNumProperties(a) != ObjectUtils.getNumProperties(b)) {
				_equals = false;
				return this;
			}

			for (var key:* in a) {
				append(a[key], b[key]);
			}

			return this;
		}

		private function appendArray(a:Array, b:Array):EqualsBuilder {
			if (!_equals) {
				return this;
			}

			if (a.length != b.length) {
				_equals = false;
				return this;
			}

			var numItems:uint = a.length;

			for (var i:uint = 0; i < numItems && _equals; i++) {
				append(a[i], b[i]);
			}

			return this;
		}

		private function appendDate(a:Date, b:Date):EqualsBuilder {
			if (!_equals) {
				return this;
			}

			if (a.getTime() != b.getTime()) {
				_equals = false;
			}

			return this;
		}

		private function appendXML(a:XML, b:XML):EqualsBuilder {
			if (!_equals) {
				return this;
			}

			if (a === b) {
				return this;
			}

			if (a.toXMLString() != b.toXMLString()) {
				_equals = false;
				return this;
			}

			return this;
		}

		private function appendEquals(a:IEquals, b:IEquals):EqualsBuilder {
			if (!_equals) {
				return this;
			}

			if (!a.equals(b)) {
				_equals = false;
			}

			return this;
		}
	}
}