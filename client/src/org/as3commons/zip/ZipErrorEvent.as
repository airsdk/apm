/*
* Copyright 2007-2012 the original author or authors.
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
package org.as3commons.zip
{
	import flash.events.Event;

	/**
	 * Zip dispatches ZipErrorEvent objects when it encounters
	 * errors while parsing the ZIP archive. There is only one type 
	 * of ZipErrorEvent: ZipErrorEvent.PARSE_ERROR
	 *
	 * @author Claus Wahlers
	 * @author Max Herkender
	 */		
	public class ZipErrorEvent extends Event
	{
		/**
		* A human readable description of the kind of parse error.
		*/		
		public var text:String;

		/**
		* Defines the value of the type property of a ZipErrorEvent object.
		*/		
		public static const PARSE_ERROR:String = "parseError";

		/**
		 * Constructor
		 * 
		 * @param type The type of the event. Event listeners can 
		 * access this information through the inherited type property. 
		 * There is only one type of ZipErrorEvent:
		 * ZipErrorEvent.PARSE_ERROR.
		 * 
		 * @param text A human readable description of the kind of parse 
		 * error.
		 * 
		 * @param bubbles Determines whether the Event object participates 
		 * in the bubbling stage of the event flow. Event listeners can 
		 * access this information through the inherited bubbles property.
		 * 
		 * @param cancelable Determines whether the Event object can be 
		 * canceled. Event listeners can access this information through 
		 * the inherited cancelable property.
		 */		
		public function ZipErrorEvent( type:String, text:String = "", bubbles:Boolean = false, cancelable:Boolean = false) {
			this.text = text;
			super(type, bubbles, cancelable);
		}
		
		/**
		 * Creates a copy of the ZipErrorEvent object and sets the value
		 * of each property to match that of the original.
		 * 
		 * @return A new ZipErrorEvent object with property values that
		 * match those of the original.
		 */		
		override public function clone():Event {
			return new ZipErrorEvent(type, text, bubbles, cancelable);
		}
	}
}