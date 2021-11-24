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

	import flash.events.TimerEvent;
	import flash.system.ApplicationDomain;
	import flash.utils.Timer;
	import flash.utils.describeType;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getQualifiedSuperclassName;

	/**
	 * Provides utilities for working with <code>Class</code> objects.
	 *
	 * @author Christophe Herreman
	 * @author Erik Westra
	 */
	public final class ClassUtils {

		private static const PACKAGE_CLASS_SEPARATOR:String = "::";

		/**
		 * Returns a <code>Class</code> object that corresponds with the given
		 * instance. If no correspoding class was found, a
		 * <code>ClassNotFoundError</code> will be thrown.
		 *
		 * @param instance the instance from which to return the class
		 * @param applicationDomain the optional applicationdomain where the instance's class resides
		 *
		 * @return the <code>Class</code> that corresponds with the given instance
		 *
		 * @see org.springextensions.actionscript.errors.ClassNotFoundError
		 */
		public static function forInstance(instance:*, applicationDomain:ApplicationDomain = null):Class {
			applicationDomain = (applicationDomain == null) ? ApplicationDomain.currentDomain : applicationDomain;
			var className:String = getQualifiedClassName(instance);
			return forName(className, applicationDomain);
		}

		/**
		 * Returns a <code>Class</code> object that corresponds with the given
		 * name. If no correspoding class was found in the applicationdomain tree, a
		 * <code>ClassNotFoundError</code> will be thrown.
		 *
		 * @param name the name from which to return the class
		 * @param applicationDomain the optional applicationdomain where the instance's class resides
		 *
		 * @return the <code>Class</code> that corresponds with the given name
		 *
		 * @see org.springextensions.actionscript.errors.ClassNotFoundError
		 */
		public static function forName(name:String, applicationDomain:ApplicationDomain = null):Class {
			applicationDomain = (applicationDomain == null) ? ApplicationDomain.currentDomain : applicationDomain;
			var result:Class;

			if (!applicationDomain) {
				applicationDomain = ApplicationDomain.currentDomain;
			}

			while (!applicationDomain.hasDefinition(name)) {
				if (applicationDomain.parentDomain) {
					applicationDomain = applicationDomain.parentDomain;
				} else {
					break;
				}
			}

			try {
				result = applicationDomain.getDefinition(name) as Class;
			} catch (e:ReferenceError) {
				throw new ClassNotFoundError("A class with the name '" + name + "' could not be found.");
			}
			return result;
		}

		/**
		 * Returns the name of the given class.
		 *
		 * @param clazz the class to get the name from
		 *
		 * @return the name of the class
		 */
		public static function getName(clazz:Class):String {
			return getNameFromFullyQualifiedName(getFullyQualifiedName(clazz));
		}

		/**
		 * Returns the name of the class or interface, based on the given fully
		 * qualified class or interface name.
		 *
		 * @param fullyQualifiedName the fully qualified name of the class or interface
		 *
		 * @return the name of the class or interface
		 */
		public static function getNameFromFullyQualifiedName(fullyQualifiedName:String):String {
			var result:String = "";
			var startIndex:int = fullyQualifiedName.indexOf(PACKAGE_CLASS_SEPARATOR);

			if (startIndex == -1) {
				result = fullyQualifiedName;
			} else {
				result = fullyQualifiedName.substring(startIndex + PACKAGE_CLASS_SEPARATOR.length, fullyQualifiedName.length);
			}
			return result;
		}

		/**
		 * Returns the fully qualified name of the given class.
		 *
		 * @param clazz the class to get the name from
		 * @param replaceColons whether the double colons "::" should be replaced by a dot "."
		 *             the default is false
		 *
		 * @return the fully qualified name of the class
		 */
		public static function getFullyQualifiedName(clazz:Class, replaceColons:Boolean = false):String {
			var result:String = getQualifiedClassName(clazz);

			if (replaceColons) {
				result = convertFullyQualifiedName(result);
			}
			return result;
		}

		/**
		 * Determines if the class or interface represented by the clazz1 parameter is either the same as, or is
		 * a superclass or superinterface of the clazz2 parameter. It returns true if so; otherwise it returns false.
		 *
		 * @return the boolean value indicating whether objects of the type clazz2 can be assigned to objects of clazz1
		 */
		public static function isAssignableFrom(clazz1:Class, clazz2:Class, applicationDomain:ApplicationDomain = null):Boolean {
			applicationDomain = (applicationDomain == null) ? ApplicationDomain.currentDomain : applicationDomain;
			return (clazz1 === clazz2) || isSubclassOf(clazz2, clazz1, applicationDomain) || isImplementationOf(clazz2, clazz1, applicationDomain);
		}

		/**
		 * Determines if the namespace of the class is private.
		 *
		 * @return A boolean value indicating the visibility of the class.
		 */
		public static function isPrivateClass(object:*):Boolean {
			var ns:String;
			var className:String;

			if (object is Class) {
				className = getQualifiedClassName(object);
				ns = className.substr(0, className.indexOf("::"));
			} else if (object is String) {
				className = object.toString();
				var index:int = className.indexOf("::");

				if (index > 0) {
					ns = className.substr(0, index);
				} else {
					ns = className;
				}
			}

			return (ns.indexOf(".as$") > -1);
		}

		/**
		 * Returns whether the passed in Class object is a subclass of the
		 * passed in parent Class. To check if an interface extends another interface, use the isImplementationOf()
		 * method instead.
		 */
		public static function isSubclassOf(clazz:Class, parentClass:Class, applicationDomain:ApplicationDomain = null):Boolean {
			applicationDomain = (applicationDomain == null) ? ApplicationDomain.currentDomain : applicationDomain;
			var classDescription:XML = getFromObject(clazz, applicationDomain);
			var parentName:String = getQualifiedClassName(parentClass);
			return (classDescription.factory.extendsClass.(@type == parentName).length() != 0);
		}

		/**
		 * Returns the class that the passed in clazz extends. If no super class
		 * was found, in case of Object, null is returned.
		 *
		 * @param clazz the class to get the super class from
		 *
		 * @returns the super class or null if no parent class was found
		 */
		public static function getSuperClass(clazz:Class, applicationDomain:ApplicationDomain = null):Class {
			applicationDomain = (applicationDomain == null) ? ApplicationDomain.currentDomain : applicationDomain;
			var result:Class;
			var classDescription:XML = getFromObject(clazz, applicationDomain);
			var superClasses:XMLList = classDescription.factory.extendsClass;

			if (superClasses.length() > 0) {
				result = ClassUtils.forName(superClasses[0].@type);
			}
			return result;
		}

		/**
		 * Returns the name of the given class' superclass.
		 *
		 * @param clazz the class to get the name of its superclass' from
		 *
		 * @return the name of the class' superclass
		 */
		public static function getSuperClassName(clazz:Class):String {
			var fullyQualifiedName:String = getFullyQualifiedSuperClassName(clazz);
			var index:int = fullyQualifiedName.indexOf(PACKAGE_CLASS_SEPARATOR) + PACKAGE_CLASS_SEPARATOR.length;
			return fullyQualifiedName.substring(index, fullyQualifiedName.length);
		}

		/**
		 * Returns the fully qualified name of the given class' superclass.
		 *
		 * @param clazz the class to get its superclass' name from
		 * @param replaceColons whether the double colons "::" should be replaced by a dot "."
		 *             the default is false
		 *
		 * @return the fully qualified name of the class' superclass
		 */
		public static function getFullyQualifiedSuperClassName(clazz:Class, replaceColons:Boolean = false):String {
			var result:String = getQualifiedSuperclassName(clazz);

			if (replaceColons) {
				result = convertFullyQualifiedName(result);
			}
			return result;
		}

		/**
		 * Returns whether the passed in <code>Class</code> object implements
		 * the given interface.
		 *
		 * @param clazz the class to check for an implemented interface
		 * @param interfaze the interface that the clazz argument should implement
		 *
		 * @return true if the clazz object implements the given interface; false if not
		 */
		public static function isImplementationOf(clazz:Class, interfaze:Class, applicationDomain:ApplicationDomain = null):Boolean {
			applicationDomain = (applicationDomain == null) ? ApplicationDomain.currentDomain : applicationDomain;
			var result:Boolean;

			if (clazz == null) {
				result = false;
			} else {
				var classDescription:XML = getFromObject(clazz, applicationDomain);
				result = (classDescription.factory.implementsInterface.(@type == getQualifiedClassName(interfaze)).length() != 0);
			}
			return result;
		}

		/**
		 * Returns whether the passed in <code>Class</code> object contains all of the functions specified
		 * by the given interface, regardless of whether or not the class formally implements the interface.
		 *
		 * @param clazz the class to check for an implemented interface
		 * @param interfaze the interface that the clazz argument should implement
		 *
		 * @return true if the clazz object implements the methods of the given interface; false if not
		 */
		public static function isInformalImplementationOf(clazz:Class, interfaze:Class, applicationDomain:ApplicationDomain = null):Boolean {
			applicationDomain = (applicationDomain == null) ? ApplicationDomain.currentDomain : applicationDomain;
			var result:Boolean = true;

			if (clazz == null) {
				result = false;
			} else {
				var classDescription:XML = getFromObject(clazz, applicationDomain);
				var interfaceDescription:XML = getFromObject(interfaze, applicationDomain);

				// Test whether the interface's accessors have equivalent matches in the class
				var interfaceAccessors:XMLList = interfaceDescription.factory.accessor;
				for each (var interfaceAccessor:XML in interfaceAccessors) {
					var accessorMatchesInClass:XMLList = classDescription.factory.accessor.(@name == interfaceAccessor.@name && @access == interfaceAccessor.@access && @type == interfaceAccessor.@type)
					if (accessorMatchesInClass.length() < 1) {
						result = false;
						break;
					}
				}

				// Test whether the interface's methods and their parameters are found in the class
				var interfaceMethods:XMLList = interfaceDescription.factory.method;
				for each (var interfaceMethod:XML in interfaceMethods) {
					var methodMatchesInClass:XMLList = classDescription.factory.method.(@name == interfaceMethod.@name && @returnType == interfaceMethod.@returnType);
					if (methodMatchesInClass.length() < 1) {
						result = false;
						break;
					}
					var interfaceMethodParameters:XMLList = interfaceMethod.parameter;
					var classMethodParameters:XMLList = methodMatchesInClass.parameter;
					if (interfaceMethodParameters.length() != classMethodParameters.length()) {
						result = false;
					}
					for each (var interfaceParameter:XML in interfaceMethodParameters) {
						var parameterMatchesInClass:XMLList = methodMatchesInClass.parameter.(@index == interfaceParameter.@index && @type == interfaceParameter.@type && @optional == interfaceParameter.@optional);
						if (parameterMatchesInClass.length() < 1) {
							result = false;
							break;
						}
					}
				}

			}

			return result;
		}

		/**
		 * Returns whether the passed in Class object is an interface.
		 *
		 * @param clazz the class to check
		 * @return true if the clazz is an interface; false if not
		 */
		public static function isInterface(clazz:Class):Boolean {
			return (clazz === Object) ? false : (describeType(clazz).factory.extendsClass.length() == 0);
		}

		/**
		 * Returns an array of all interface names that the given class implements.
		 */
		public static function getImplementedInterfaceNames(clazz:Class):Array {
			var result:Array = getFullyQualifiedImplementedInterfaceNames(clazz);

			for (var i:int = 0; i < result.length; i++) {
				result[i] = getNameFromFullyQualifiedName(result[i]);
			}
			return result;
		}

		/**
		 * Returns an array of all fully qualified interface names that the
		 * given class implements.
		 */
		public static function getFullyQualifiedImplementedInterfaceNames(clazz:Class, replaceColons:Boolean = false, applicationDomain:ApplicationDomain = null):Array {
			applicationDomain = (applicationDomain == null) ? ApplicationDomain.currentDomain : applicationDomain;
			var result:Array = [];
			var classDescription:XML = getFromObject(clazz, applicationDomain);
			var interfacesDescription:XMLList = classDescription.factory.implementsInterface;

			if (interfacesDescription) {
				var numInterfaces:int = interfacesDescription.length();

				for (var i:int = 0; i < numInterfaces; i++) {
					var fullyQualifiedInterfaceName:String = interfacesDescription[i].@type.toString();

					if (replaceColons) {
						fullyQualifiedInterfaceName = convertFullyQualifiedName(fullyQualifiedInterfaceName);
					}
					result[result.length] = fullyQualifiedInterfaceName;
				}
			}
			return result;
		}

		/**
		 * Returns an array of all interface names that the given class implements.
		 */
		public static function getImplementedInterfaces(clazz:Class, applicationDomain:ApplicationDomain = null):Array {
			applicationDomain = (applicationDomain == null) ? ApplicationDomain.currentDomain : applicationDomain;
			var result:Array = getFullyQualifiedImplementedInterfaceNames(clazz);

			for (var i:int = 0; i < result.length; i++) {
				result[i] = ClassUtils.forName(result[i], applicationDomain);
			}
			return result;
		}

		/**
		 * Creates an instance of the given class and passes the arguments to
		 * the constructor.
		 *
		 * TODO find a generic solution for this. Currently we support constructors
		 * with a maximum of 10 arguments.
		 *
		 * @param clazz the class from which an instance will be created
		 * @param args the arguments that need to be passed to the constructor
		 */
		public static function newInstance(clazz:Class, args:Array = null):* {
			var result:*;
			var a:Array = (args == null) ? [] : args;

			switch (a.length) {
				case 1:
					result = new clazz(a[0]);
					break;
				case 2:
					result = new clazz(a[0], a[1]);
					break;
				case 3:
					result = new clazz(a[0], a[1], a[2]);
					break;
				case 4:
					result = new clazz(a[0], a[1], a[2], a[3]);
					break;
				case 5:
					result = new clazz(a[0], a[1], a[2], a[3], a[4]);
					break;
				case 6:
					result = new clazz(a[0], a[1], a[2], a[3], a[4], a[5]);
					break;
				case 7:
					result = new clazz(a[0], a[1], a[2], a[3], a[4], a[5], a[6]);
					break;
				case 8:
					result = new clazz(a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7]);
					break;
				case 9:
					result = new clazz(a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7], a[8]);
					break;
				case 10:
					result = new clazz(a[0], a[1], a[2], a[3], a[4], a[5], a[6], a[7], a[8], a[9]);
					break;
				default:
					result = new clazz();
			}

			return result;
		}

		/**
		 * Converts the double colon (::) in a fully qualified class name to a dot (.)
		 */
		public static function convertFullyQualifiedName(className:String):String {
			return className.replace(PACKAGE_CLASS_SEPARATOR, ".");
		}

		// --------------------------------------------------------------------
		//
		// describeType cache implementation
		//
		// --------------------------------------------------------------------

		/**
		 * The default value for the interval to clear the describe type cache.
		 */
		public static const CLEAR_CACHE_INTERVAL:uint = 60000;
		private static const AS3VEC_SUFFIX:String = '__AS3__.vec';
		private static const LESS_THAN:String = '<';

		/**
		 * The interval (in miliseconds) at which the cache will be cleared. Note that this value is only used
		 * on the first call to getFromObject.
		 *
		 * @default 60000 (one minute)
		 */
		public static var clearCacheInterval:uint = CLEAR_CACHE_INTERVAL;

		private static var _describeTypeCache:Object = {};

		private static var _timer:Timer;

		/**
		 * Clears the describe type cache. This method is called automatically at regular intervals
		 * defined by the clearCacheInterval property.
		 */
		public static function clearDescribeTypeCache():void {
			_describeTypeCache = {};

			if (_timer && _timer.running) {
				_timer.stop();
			}
		}

		/**
		 *
		 * @param fullName
		 * @param applicationDomain
		 * @return
		 */
		public static function getClassParameterFromFullyQualifiedName(fullName:String, applicationDomain:ApplicationDomain = null):Class {
			applicationDomain = (applicationDomain != null) ? applicationDomain : ApplicationDomain.currentDomain;
			if (StringUtils.startsWith(fullName, AS3VEC_SUFFIX)) {
				var startIdx:int = fullName.indexOf(LESS_THAN) + 1;
				var len:int = (fullName.length - startIdx) - 1;
				var className:String = fullName.substr(startIdx, len);
				return forName(className, applicationDomain);
			} else {
				return null;
			}
		}

		/**
		 * Timer handler. Clear the cache.
		 */
		private static function timerHandler(e:TimerEvent):void {
			clearDescribeTypeCache();
		}

		/**
		 * Will return the metadata for the given object or class. If metadata has already been requested for
		 * this type, it will be retrieved from cache. Note that the metadata will allways be that of the class,
		 * even if you pass an instance.
		 * <p />
		 * In order to get instance specific metadata, use the 'factory' property.
		 * <p />
		 * The reason we do not allow retrieval of instance metadata is because then we would need to cache the
		 * metadata double. Metadata takes up a significant amount of memory.
		 *
		 * @param object  The object from which you want to grab the metadata
		 *
		 * @return The class metadata of the given object.
		 */
		private static function getFromObject(object:Object, applicationDomain:ApplicationDomain):XML {
			Assert.notNull(object, "The object argument must not be null");
			var className:String = getQualifiedClassName(object);
			var metadata:XML;

			if (_describeTypeCache.hasOwnProperty(className)) {
				metadata = _describeTypeCache[className];
			} else {
				if (!_timer) {
					// Only run the timer once to prevent unneeded overhead. This also prevents
					// this class from falling for the bug described here:
					// http://www.gskinner.com/blog/archives/2008/04/failure_to_unlo.html
					_timer = new Timer(clearCacheInterval, 1);
					_timer.addEventListener(TimerEvent.TIMER, timerHandler);
				}

				if (!(object is Class)) {
					if (object.hasOwnProperty("constructor")) {
						object = object.constructor;
					} else {
						object = forName(className, applicationDomain);
					}
				}

				metadata = describeType(object);

				_describeTypeCache[className] = metadata;

				// Only run the timer if it is not already running.
				if (!_timer.running) {
					_timer.start();
				}
			}

			return metadata;
		}

		/**
		 * Will retrieve the metadata for the given class. Note that in order to access properties and
		 * methods you need to grab the 'factory' part of the metadata.
		 *
		 * @param className    The name of the class that you want to retrieve metadata from. The className
		 *             may be in the following forms: package.Class or package::Class
		 */
		private static function getFromString(className:String, applicationDomain:ApplicationDomain = null):XML {
			applicationDomain = (applicationDomain == null) ? ApplicationDomain.currentDomain : applicationDomain;
			var classDefinition:Class = forName(className, applicationDomain);

			// Calling getFromObject seems double, as it results in the getObjectMethod getting
			// the class name using getQualifiedClassName. It however saves us a check on the
			// given className which might be in two forms.

			// getQualifiedClassName(getDefinitionByName(className)) is faster than converting the
			// string using conventional methods.
			return getFromObject(classDefinition, applicationDomain);
		}

	}
}
