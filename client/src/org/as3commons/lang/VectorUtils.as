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
package org.as3commons.lang
{
	/**
	 * Contains utility methods for working with Vector objects.
	 *
	 * @author Michael Archbold
	 */
	public class VectorUtils
	{


		/**
		 * Checks if the given vector contains the specified item.
		 *
		 * @param vector
		 * @param item
		 *
		 * @return true if the vector contains the item, false otherwise
		 */
		public static function contains( vector:Vector.<IEquals>, item:IEquals ):Boolean
		{
			for (var i:int = 0; i < vector.length; i++)
			{
				if (item.equals( vector[i] ))
				{
					return true;
				}
			}
			return false;
		}


		/**
		 * Returns a new vector containing the items that are present in both input vectors.
		 * The result will contain unique items only.
		 *
		 * @param vector1 The first vector to compare
		 * @param vector2 The second vector to compare
		 * @return A new Vector containing the intersection of the two vectors
		 */
		public static function intersection( vector1:Vector.<IEquals>, vector2:Vector.<IEquals> ):Vector.<*>
		{
			var intersection:Vector.<*> = new Vector.<*>();
			for (var i:int = 0; i < vector1.length; i++)
			{
				for (var j:int = 0; j < vector2.length; j++)
				{
					if (vector1[i].equals( vector2[j] ))
					{
						intersection.push( vector1[i] );
						break; // No need to check further in vector2
					}
				}
			}
			return filterUnique( intersection );
		}


		/**
		 * Merges multiple vectors into one
		 *
		 * @param vectors The vectors to merge
		 * @return A new Vector containing items from all provided vectors
		 */
		public static function merge( ...vectors ):Vector.<*>
		{
			var merged:Vector.<*> = new Vector.<*>();
			for (var c:int = 0; c < vectors.length; c++)
			{
				if (vectors[c] != null)
				{
					merged = merged.concat( Vector.<*>(vectors[c]) );
				}
			}
			return merged;
		}

		/**
		 * Merges multiple vectors into one, removing duplicates.
		 *
		 * @param vectors The vectors to merge
		 * @return A new Vector containing unique items from all provided vectors
		 */
		public static function mergeUnique( ...vectors ):Vector.<*>
		{
			var merged:Vector.<*> = new Vector.<*>();
			for (var c:int = 0; c < vectors.length; c++)
			{
				if (vectors[c] != null)
				{
					merged = merged.concat( Vector.<*>(vectors[c]) );
				}
			}
			return filterUnique( merged );
		}


		/**
		 * Filters the given vector and returns a new vector with only unique items.
		 *
		 * @param vector The vector to filter
		 * @return A new vector containing only unique items from the original vector
		 */
		public static function filterUnique( vector:Vector.<*> ):Vector.<*>
		{
			var unique:Vector.<*> = new Vector.<*>().concat( vector );
			for (var i:int = unique.length - 1; i >= 0; --i)
			{
				for (var j:int = i - 1; j >= 0; --j)
				{
					if (unique[i] == unique[j])
					{
						unique.splice( i, 1 );
						break;
					}
				}
			}
			return unique;
		}

	}
}
