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
	import flash.events.IEventDispatcher;
	import flash.net.URLRequest;
	import flash.utils.ByteArray;
	import flash.utils.IDataOutput;

	/**
	 *
	 * @author Roland Zwaga
	 */
	public interface IZip extends IEventDispatcher {
		function get active():Boolean;

		function addFile(name:String, content:ByteArray=null, doCompress:Boolean=true):ZipFile;
		function addFileAt(index:uint, name:String, content:ByteArray=null, doCompress:Boolean=true):ZipFile;
		function addFileFromString(name:String, content:String, charset:String="utf-8", doCompress:Boolean=true):ZipFile;
		function addFileFromStringAt(index:uint, name:String, content:String, charset:String="utf-8", doCompress:Boolean=true):ZipFile;
		function close():void;
		function getFileAt(index:uint):IZipFile;
		function getFileByName(name:String):IZipFile;
		function getFileCount():uint;
		function load(request:URLRequest):void;
		function loadBytes(bytes:ByteArray):void;
		function removeFileAt(index:uint):IZipFile;
		function serialize(stream:IDataOutput, includeAdler32:Boolean=false):void;
	}
}
