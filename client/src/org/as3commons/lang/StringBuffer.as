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

	/**
	 * @author Christophe Herreman
	 */
	public final class StringBuffer {

		private var _string:Array;

		/**
		 * Creates a new StringBuffer.
		 */
		public function StringBuffer( string:String = "") {
			_string = (string ? [string] : []);
		}

		public function append(value:Object):StringBuffer {
			_string[_string.length] = value;
			return this;
		}

		public function removeEnd(value:Object):StringBuffer {
			_string = [StringUtils.removeEnd(toString(), value.toString())];
			return this;
		}

		public function toString():String {
			return _string.join('');
		}
	}
}