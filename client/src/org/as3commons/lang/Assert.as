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

	import flash.utils.Dictionary;
	import flash.utils.getQualifiedClassName;

	/**
	 * Assertion utility class that assists in validating arguments.
	 * Useful for identifying programmer errors early and clearly at runtime.
	 *
	 * @author Christophe Herreman
	 */
	public final class Assert {

		/**
		 * Asserts a boolean expression to be <code>true</code>.
		 * <pre class="code">Assert.isTrue(value, "The expression must be true");</pre>
		 * @param expression a boolean expression
		 * @param message the error message to use if the assertion fails
		 * @throws org.as3commons.lang.IllegalArgumentError if the expression is not <code>true</code>
		 */
		public static function isTrue(expression:Boolean, message:String = ""):void {
			if (!expression) {
				if (message == null || message.length == 0) {
					message = "[Assertion failed] - this expression must be true";
				}
				throw new IllegalArgumentError(message);
			}
		}

		/**
		 * Compares an instance of a class with an abstract class definition, if
		 * they are of the exact type, the assertion fails.
		 *
		 * @param instance an instance of a class
		 * @param abstractClass an abstract class definition
		 * @param message the error message to use if the assertion fails
		 * @throws org.as3commons.lang.IllegalArgumentError if the assertion fails
		 */
		public static function notAbstract(instance:Object, abstractClass:Class, message:String = ""):void {
			var instanceName:String = getQualifiedClassName(instance);
			var abstractName:String = getQualifiedClassName(abstractClass);

			if (instanceName == abstractName) {
				if (message == null || message.length == 0) {
					message = "[Assertion failed] - instance is an instance of an abstract class";
				}
				throw new IllegalArgumentError(message);
			}
		}

		/**
		 * Assert that an object is <code>null</code>.
		 * <pre class="code">Assert.isNull(value, "The value must be null");</pre>
		 * @param object the object to check
		 * @param message the error message to use if the assertion fails
		 * @throws org.as3commons.lang.IllegalArgumentError if the object is not <code>null</code>
		 */
		public static function notNull(object:Object, message:String = ""):void {
			if (object == null) {
				if (message == null || message.length == 0) {
					message = "[Assertion failed] - this argument is required; it must not null";
				}
				throw new IllegalArgumentError(message);
			}
		}

		/**
		 * Assert that an object is an instance of a certain type..
		 * <pre class="code">Assert.instanceOf(value, type, "The value must be an instance of 'type'");</pre>
		 * @param object the object to check
		 * @param message the error message to use if the assertion fails
		 * @throws org.as3commons.lang.IllegalArgumentError if the object is not an instance of the given type
		 */
		public static function instanceOf(object:*, type:Class, message:String = ""):void {
			if (!(object is type)) {
				if (message == null || message.length == 0) {
					message = "[Assertion failed] - this argument is not of type '" + type + "'";
				}
				throw new IllegalArgumentError(message);
			}
		}

		/**
		 * Asserts that a class is a subclass of another class.
		 */
		public static function subclassOf(clazz:Class, parentClass:Class, message:String = ""):void {
			if (!ClassUtils.isSubclassOf(clazz, parentClass)) {
				if (message == null || message.length == 0) {
					message = "[Assertion failed] - this argument is not a subclass of '" + parentClass + "'";
				}
				throw new IllegalArgumentError(message);
			}
		}

		/**
		 * Assert that an object implements a certain interface.
		 */
		public static function implementationOf(object:*, interfaze:Class, message:String = ""):void {
			if (!ClassUtils.isImplementationOf(ClassUtils.forInstance(object), interfaze)) {
				if (message == null || message.length == 0) {
					message = "[Assertion failed] - this argument does not implement the interface '" + interfaze + "'";
				}
				throw new IllegalArgumentError(message);
			}
		}

		/**
		 * Assert a boolean expression to be true. If false, an IllegalStateError is thrown.
		 * @param expression a boolean expression
		 * @param the error message if the assertion fails
		 */
		public static function state(expression:Boolean, message:String = ""):void {
			if (!expression) {
				if (message == null || message.length == 0) {
					message = "[Assertion failed] - this state invariant must be true";
				}
				throw new IllegalStateError(message);
			}
		}

		/**
		 * Assert that the given String has valid text content; that is, it must not
		 * be <code>null</code> and must contain at least one non-whitespace character.
		 *
		 * @param text the String to check
		 * @param message the exception message to use if the assertion fails
		 * @see StringUtils#hasText
		 */
		public static function hasText(string:String, message:String = ""):void {
			if (StringUtils.isBlank(string)) {
				if (message == null || message.length == 0) {
					message = "[Assertion failed] - this String argument must have text; it must not be <code>null</code>, empty, or blank";
				}
				throw new IllegalArgumentError(message);
			}
		}

		/**
		 * Assert that the given Dictionary contains only keys of the given type.
		 */
		public static function dictionaryKeysOfType(dictionary:Dictionary, type:Class, message:String = ""):void {
			for (var key:Object in dictionary) {
				if (!(key is type)) {
					if (message == null || message.length == 0) {
						message = "[Assertion failed] - this Dictionary argument must have keys of type '" + type + "'";
					}
					throw new IllegalArgumentError(message);
				}
			}
		}

		/**
		 * Assert that the array contains the passed in item.
		 */
		public static function arrayContains(array:Array, item:*, message:String = ""):void {
			if (array.indexOf(item) == -1) {
				if (message == null || message.length == 0) {
					message = "[Assertion failed] - this Array argument does not contain the item '" + item + "'";
				}
				throw new IllegalArgumentError(message);
			}
		}

		/**
		 * Assert that all items in the array are of the given type.
		 *
		 * @param array the array to check
		 * @param type the type of the array items
		 * @param message the error message to use if the assertion fails
		 */
		public static function arrayItemsOfType(array:Array, type:Class, message:String = ""):void {
			for each (var item:* in array) {
				if (!(item is type)) {
					if (message == null || message.length == 0) {
						message = "[Assertion failed] - this Array must have items of type '" + type + "'";
					}
					throw new IllegalArgumentError(message);
				}
			}
		}
	}
}
