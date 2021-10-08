/*
 * Copyright (c) 2007-2009-2010 the original author or authors
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
package org.as3commons.lang {

	import flash.utils.Dictionary;

	/**
	 * Class that fakes a soft (or weak) reference to an object by internally using
	 * a <code>Dictionary</code> object with weak keys to hold the object reference.
	 * @author Roland Zwaga
	 */
	public final class SoftReference {
		private var _dict:Dictionary;

		/**
		 * Creates a new <code>SoftReference</code> instance.
		 * @param value Optional object instance to be used as the current <code>SoftReference</code> value.
		 */
		public function SoftReference( value:Object = null) {
			super();
			if (value != null) {
				this.value = value;
			}
		}

		/**
		 * The instance for which a soft reference is held by the current <code>SoftReference</code>.
		 */
		public function get value():Object {
			if (_dict != null) {
				for (var obj:Object in _dict) {
					return obj;
				}
			}
			return null;
		}

		/**
		 * @private
		 */
		public function set value(value:Object):void {
			_dict = new Dictionary(true);
			_dict[value] = true;
		}
	}
}