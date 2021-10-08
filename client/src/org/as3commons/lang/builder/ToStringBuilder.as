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
	
	import org.as3commons.lang.StringBuffer;
	
	/**
	 *
	 * @author Christophe Herreman
	 */
	public class ToStringBuilder {
		
		public static var defaultStyle:ToStringStyle = ToStringStyle.DEFAULT_STYLE;
		
		private var _object:Object;
		
		private var _style:ToStringStyle;
		
		private var _stringBuffer:StringBuffer;
		
		/**
		 * Creates a new ToStringBuilder.
		 *
		 * @param object the object for which to build a "toString"
		 * @param style the ToStringStyle
		 */
		public function ToStringBuilder( object:Object, style:ToStringStyle = null) {
			_object = object;
			_style = (style ? style : defaultStyle);
			_stringBuffer = new StringBuffer();
			
			_style.appendBegin(_stringBuffer, _object);
		}
		
		/**
		 *
		 */
		public function append(value:Object, fieldName:String = null):ToStringBuilder {
			_style.append(_stringBuffer, _object, value, fieldName);
			
			return this;
		}
		
		/**
		 *
		 */
		public function toString():String {
			_style.appendEnd(_stringBuffer);
			return _stringBuffer.toString();
		}
	}
}