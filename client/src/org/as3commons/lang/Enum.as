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

	import flash.utils.getQualifiedClassName;

	import org.as3commons.lang.builder.EqualsBuilder;

	/**
	 * Base class for enumerations.
	 *
	 * <p>An enumeration has a name as a unique identifier and it is passed as a constructor argument. This argument
	 * is made optional and a setter is provided to allow server side Enum mapping, since this requires a no-args
	 * constructor.</p>
	 *
	 * <p>Comparing 2 enum instances with the equals() method will return true if the enums are of the same type and
	 * have the same name.</p>
	 *
	 * <p>Note: for enum mapping with BlazeDS, check the EnumProxy java class at http://bugs.adobe.com/jira/browse/BLZ-17</p>
	 *
	 * @author Christophe Herreman
	 */
	public class Enum implements IEquals {

		/**
		 * A map with the enum values of all Enum types in memory.
		 * As its keys, the fully qualified name of the enum class is used.
		 * As its values, another map is used to map the individual enum values,
		 * from name to enum instance.
		 *
		 * Example:
		 *
		 * 	{
		 * 		"com.domain.Color":
		 * 			{
		 * 				"RED": Color.RED,
		 * 				"GREEN": Color.GREEN,
		 * 				"BLUE": Color.BLUE
		 * 			},
		 * 		"com.domain.Day":
		 * 			{
		 * 				"MONDAY": Day.MONDAY,
		 * 				"TUESDAY": Day.TUESDAY,
		 * 				"WEDNESDAY": Day.WEDNESDAY
		 * 			}
		 *	}
		 */
		private static var _values:Object /* <String, Object> */ = {};

		/**
		 * A map with the value arrays of the Enum types in memory.
		 * As its keys, the fully qualified name of the enum class is used.
		 * As its values, an array with the enum values of a Enum class is used.
		 *
		 * Example:
		 *
		 * 	{
		 * 		"com.domain.Color": [Color.RED, Color.GREEN, Color.BLUE]
		 * 	}
		 */
		private static var _valueArrays:Object /* <String, Array> */ = {};

		private var _name:String;

		private var _index:int = -1;

		private var _declaringClassName:String;

		/**
		 * Creates a new Enum object.
		 *
		 * <p>A new enum value is allowed to receive a empty string or null as its name. This is to
		 * make it possible to deserialize external data (from a remote object for instance) in which
		 * an Enum instance will be created without name and the name will be set via the name setter.
		 * The name can only be set to a non-null or non-empty value only once though.</b>
		 *
		 * @param name the name of the enum value
		 */
		public function Enum( name:String = "") {
			this.name = name;
		}

		/**
		 * Returns the values of the enumeration of the given Class.
		 *
		 * @param clazz the class for which to return all enum values
		 * @return an array of Enum objects or Enum subtype objects
		 */
		public static function getValues(clazz:Class):Array {
			Assert.subclassOf(clazz, Enum, "Can not get enum values for class [" + clazz + "] because it is not a subclass of Enum.");

			var className:String = getQualifiedClassName(clazz);

			Assert.notNull(_valueArrays[className], "Enum values for the class '" + clazz + "' do not exist");

			return _valueArrays[className];
		}

		/**
		 * Returns the enum entry for the given class by its name.
		 *
		 * @param clazz the class that defines the enumeration
		 * @param name the name of the enum entry to get
		 */
		public static function getEnum(clazz:Class, name:String):Enum {
			Assert.notNull(clazz, "The class must not be null");
			Assert.hasText(name, "The name must have text");

			var className:String = ClassUtils.getFullyQualifiedName(clazz);

			Assert.notNull(_values[className], "Enum values for the class '" + clazz + "' do not exist");
			Assert.notNull(_values[className][name], "An enum for type '" + clazz + "' and name '" + name + "' was not found.");

			return _values[className][name];
		}

		/**
		 * Returns the index of the given enum, based on equality using the equals method.
		 *
		 * @return the index of the enum
		 */
		public static function getIndex(enum:Enum):int {
			Assert.notNull(enum, "The enum must not be null");

			var className:String = getQualifiedClassName(enum);
			var values:Array = _valueArrays[className];

			Assert.notNull(values, "Enum values for the class name '" + className + "' do not exist");

			for each (var e:Enum in values) {
				if (e.equals(enum)) {
					return e.index;
				}
			}

			return -1;
		}

		/**
		 * Returns the name of this enum.
		 */
		final public function get name():String {
			return _name;
		}

		/**
		 * Sets the name for this enum.
		 */
		final public function set name(value:String):void {
			Assert.state(name == null || name.length == 0, "The name of an enum value can only be set once.");

			_name = StringUtils.trim(value);

			initializeEnum(name);
		}

		/**
		 *
		 */
		final public function get index():int {
			return _index;
		}

		/**
		 * Returns the class name of this enum.
		 */
		final public function get declaringClassName():String {
			if (!_declaringClassName) {
				_declaringClassName = getQualifiedClassName(this);
			}
			return _declaringClassName;
		}

		/**
		 * Checks if this enum is equal to the other passed in enum.
		 *
		 * To be equal, the 2 enums should be of the same type and should have the same name.
		 *
		 * @param other the other enum with which to compare
		 * @return true if this enum is equal to the other; false otherwise
		 */
		public function equals(other:Object):Boolean {
			if (this == other) {
				return true;
			}

			if (!(other is Enum)) {
				return false;
			}

			// types do not match?
			/*if (!(other is ClassUtils.forInstance(this))) {
			   return false;
			 }*/

			var that:Enum = Enum(other);
			return new EqualsBuilder().append(declaringClassName, that.declaringClassName).append(name, that.name).equals;
		}

		/**
		 * Returns a string representation of this enum.
		 */
		public function toString():String {
			var clazz:Class = ClassUtils.forInstance(this);
			var className:String = ClassUtils.getName(clazz);
			return ("[" + className + "(" + name + ")]");
		}

		/**
		 * Initiliazes the enum value.
		 */
		private function initializeEnum(name:String):void {
			// add the enum value if we have a valid name
			// this will only happen once for each unique enum value that is not null or empty
			if (!StringUtils.isEmpty(name)) {
				// create the lookup maps to store the enum values for this class
				if (!_values[declaringClassName]) {
					_values[declaringClassName] = {};
					_valueArrays[declaringClassName] = [];
				}

				var equalityIndex:int = Enum.getIndex(this);

				// if this is a new enum, set its index to the number of same enum types
				// and add it to the lookup maps
				if (equalityIndex == -1) {
					// set the index on the enum
					_index = _valueArrays[declaringClassName].length;

					// add the enum to the values array
					_values[declaringClassName][name] = this;
					_valueArrays[declaringClassName].push(this);
				} else {
					// this enum is already created, set its index to the one found
					_index = equalityIndex;
				}
			}
		}


	}
}