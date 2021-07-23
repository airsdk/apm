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
package org.as3commons.zip {
	import flash.display.BitmapData;
	import flash.display.DisplayObject;
	import flash.events.IEventDispatcher;

	/**
	 *
	 * @author Roland Zwaga
	 */
	public interface IZipLibrary extends IEventDispatcher {
		function addZip(zip:IZip):void;
		function formatAsBitmapData(ext:String):void;
		function formatAsDisplayObject(ext:String):void;
		function getBitmapData(filename:String):BitmapData;
		function getDefinition(filename:String, definition:String):Object;
		function getDisplayObject(filename:String):DisplayObject;
	}
}
