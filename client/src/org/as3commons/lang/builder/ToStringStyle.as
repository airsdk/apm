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
	
	import org.as3commons.lang.ObjectUtils;
	import org.as3commons.lang.StringBuffer;
	
	/**
	 * @author Christophe Herreman
	 */
	public class ToStringStyle {
		
		public static const DEFAULT_STYLE:ToStringStyle = new ToStringStyle();
		
		public var useShortClassName:Boolean = true;
		
		public var contentBegin:String = "[";
		
		public var contentEnd:String = "]";
		
		public var fieldSeparator:String = ",";
		
		public var fieldNameValueSeparator:String = "=";
		
		/**
		 *
		 */
		public function ToStringStyle() {
		}
		
		/**
		 *
		 */
		public function appendBegin(buffer:StringBuffer, object:Object):ToStringStyle {
			appendClassName(buffer, object);
			appendContentBegin(buffer);
			return this;
		}
		
		/**
		 *
		 */
		public function append(buffer:StringBuffer, object:Object, value:Object, fieldName:String):ToStringStyle {
			if (fieldName) {
				buffer.append(fieldName + fieldNameValueSeparator + value + fieldSeparator);
			} else {
				buffer.append(value + fieldSeparator);
			}
			
			return this;
		}
		
		/**
		 *
		 */
		public function appendEnd(buffer:StringBuffer):ToStringStyle {
			// remove the last field separator
			var string:String = buffer.toString();
			
			if (buffer.toString().lastIndexOf(fieldSeparator) == (string.length - 1)) {
				buffer.removeEnd(fieldSeparator);
			}
			
			appendContentEnd(buffer);
			
			return this;
		}
		
		private function appendContentBegin(buffer:StringBuffer):ToStringStyle {
			buffer.append(contentBegin);
			return this;
		}
		
		private function appendContentEnd(buffer:StringBuffer):ToStringStyle {
			buffer.append(contentEnd);
			return this;
		}
		
		private function appendClassName(buffer:StringBuffer, object:Object):ToStringStyle {
			if (useShortClassName) {
				buffer.append(ObjectUtils.getClassName(object));
			} else {
				buffer.append(getQualifiedClassName(object));
			}
			return this;
		}
	}
}