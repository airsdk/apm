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
 * Concrete implementation of the <code>IIterator</code> interface for inspecting
 * the values of an <code>Object</code> or one of its subclasses.
 * 
 * @author Andrew Lewisohn
 */
internal final class ObjectIterator implements IIterator {
	
	//--------------------------------------------------------------------------
	//
	//  Class variables
	//
	//--------------------------------------------------------------------------
	
	private static var descriptions:Object = {};
	
	//--------------------------------------------------------------------------
	//
	//  Class methods
	//
	//--------------------------------------------------------------------------
	
	public static function getDescription(name:String):XMLList {
		return descriptions[name];
	}
	
	public static function setDescription(name:String, keys:XMLList):void {
		descriptions[name] = keys;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------
	
	/**
	 * The current index of the iterator.
	 */
	private var index:int;
	
	/**
	 * An Array or XMLList of Keys.
	 */
	private var keys:Object;
	
	/**
	 * The target object.
	 */
	private var target:Object;
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------
	
	/**
	 * Constructor.
	 * 
	 * @param object The target object
	 * @param keys A list of read/write keys (can be an <code>Array</code>, or 
	 * 	<code>XMLList</code>
	 */
	public function ObjectIterator( object:Object, keys:Object) {
		super();
		
		if(keys is XMLList || keys is Array) {
			this.target = object;
			this.keys = keys;
			index = 0;
		} else {
			throw new IllegalArgumentError("Argument 'keys' must be of one of the following types: [Array, XMLList]");
		}
	}	
	
	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @private
	 * Storage for the targetClassName property.
	 */
	private var _targetClassName:String;
	
	/**
	 * The qualified class name of the object being enumerated.
	 */
	public function get targetClassName():String {
		if(_targetClassName == null) {
			_targetClassName = ObjectUtils.getFullyQualifiedClassName(target);
		}
		return _targetClassName;
	}
	
	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------
	
	/**
	 * @inheritDoc
	 */
	public function first():void {
		index = 0;
	}
	
	/**
	 * @inheritDoc
	 */
	public function last():void {
		index = (keys is Array) 
			? keys.length
			: keys.length();
	}
	
	/**
	 * @inheritDoc
	 */
	public function next():Object {
		var key:String = keys[index]; 
		index++;
		
		if(key == null) {
			return false;
		}
		
		return target[key];
	}
}
}