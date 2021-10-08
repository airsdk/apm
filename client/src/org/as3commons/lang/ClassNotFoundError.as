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
	 * Thrown when an application tries to retrieve a class by its name and
	 * the corresponding class could not be found.
	 *
	 * @author Christophe Herreman
	 */
	public class ClassNotFoundError extends Error {
		
		/**
		 * Creates a new <code>ClassNotFoundError</code> object.
		 */
		public function ClassNotFoundError( message:String = "") {
			super(message);
		}
	}
}
