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
	 * Interface to be implemented by objects that need to be compared with others for ordering.
	 *
	 * @author Christophe Herreman
	 */
	public interface IComparable {
		
		/**
		 * Compares this object with the specified object for order. Returns a negative integer, zero, or a positive
		 * integer as this object is less than, equal to, or greater than the specified object.
		 *
		 * @param other the object to be compared
		 * @return a negative integer, zero, or a positive integer as this object is less than, equal to, or greater than the specified object.
		 */
		function compareTo(other:Object):int;
	
	}
}