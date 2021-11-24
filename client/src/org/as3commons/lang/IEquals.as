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
	 * This interface should be implemented by all objects that wish to offer an "equals" method.
	 *
	 * @author Christophe Herreman
	 */
	public interface IEquals {
		
		/**
		 * Indicates whether some other object is equal to this one.
		 *
		 * @param other the object to compare to this object for equality
		 */
		function equals(other:Object):Boolean;
	
	}
}