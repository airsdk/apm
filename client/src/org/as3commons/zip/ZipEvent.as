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
	 * Zip dispatches ZipEvent objects when a file contained in the
	 * ZIP archive has finished loading and can be accessed. There is 
	 * only one type of ZipEvent: ZipErrorEvent.FILE_LOADED.
	 *
	 * @author Claus Wahlers
	 * @author Max Herkender
	 */		
	public class ZipEvent extends Event
	{
		/**
		* The file that has finished loading.
		*/		
		public var file:ZipFile;
		
		/**
		* Defines the value of the type property of a ZipEvent object.
		*/		
		public static const FILE_LOADED:String = "fileLoaded";

		/**
		 * Constructor
		 * 
		 * @param type The type of the event. Event listeners can 
		 * access this information through the inherited type property. 
		 * There is only one type of ZipEvent:
		 * ZipEvent.PARSE_ERROR.
		 * 
		 * @param file The file that has finished loading.
		 * 
		 * @param bubbles Determines whether the Event object participates 
		 * in the bubbling stage of the event flow. Event listeners can 
		 * access this information through the inherited bubbles property.
		 * 
		 * @param cancelable Determines whether the Event object can be 
		 * canceled. Event listeners can access this information through 
		 * the inherited cancelable property.
		 */		
		public function ZipEvent( type:String, file:ZipFile = null, bubbles:Boolean = false, cancelable:Boolean = false) {
			super(type, bubbles, cancelable);
			this.file = file;
		}
		
		/**
		 * Creates a copy of the ZipEvent object and sets the value
		 * of each property to match that of the original.
		 * 
		 * @return A new ZipEvent object with property values that
		 * match those of the original.
		 */		
		override public function clone():Event {
			return new ZipEvent(type, file, bubbles, cancelable);
		}
		
		/**
		 * TODO
		 * 
		 * @return String
		 */		
		override public function toString():String {
			return "[ZipEvent type=\"" + type + "\" filename=\"" + file.filename + "\" bubbles=" + bubbles + " cancelable=" + cancelable + " eventPhase=" + eventPhase + "]";
		}
	}
}