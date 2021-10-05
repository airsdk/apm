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
	 * Signals that a method has been invoked at an illegal or inappropriate time. In other words, the environment
	 * or application is not in an appropriate state for the requested operation.
	 *
	 * @author Christophe Herreman
	 */
	public class IllegalStateError extends Error {
		
		/**
		 * Constructs a new <code>IllegalStateError</code>.
		 *
		 * @param message the detail message that describes the cause of the error
		 */
		public function IllegalStateError( message:String = "") {
			super(message);
		}
	}
}
