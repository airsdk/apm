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

	import flash.xml.XMLNode;
	import flash.xml.XMLNodeType;

	/**
	 * Contains utilities for working with XML objects.
	 *
	 * @author Christophe Herreman
	 */
	public final class XMLUtils {

		public static const ELEMENT_NODE_KIND:String = "element";

		public static const TEXT_NODE_KIND:String = "text";

		public static const COMMENT_NODE_KIND:String = "comment";

		public static const ATTRIBUTE_NODE_KIND:String = "attribute";

		public static const PROCESSING_INSTRUCTION_NODE_KIND:String = "processing-instruction";

		/**
		 * Creates a CDATA section for the given data string.
		 * Use this method if you need to create a CDATA section with a binding
		 * expression in a literal XML declaration
		 *
		 * @param data the data string to create a CDATA section from.
		 * @return a CDATA section for the data
		 */
		public static function cdata(data:String):XML {
			var result:XML = new XML("<![CDATA[" + data + "]]>");
			return result;
		}

		/**
		 * Returns if the given xml node is an element node.
		 */
		public static function isElementNode(xml:XML):Boolean {
			Assert.notNull(xml, "The xml must not be null");
			return (ELEMENT_NODE_KIND == xml.nodeKind());
		}

		/**
		 * Returns if the given xml node is a text node.
		 */
		public static function isTextNode(xml:XML):Boolean {
			Assert.notNull(xml, "The xml must not be null");
			return (TEXT_NODE_KIND == xml.nodeKind());
		}

		/**
		 * Returns if the given xml node is a comment node.
		 */
		public static function isCommentNode(xml:XML):Boolean {
			Assert.notNull(xml, "The xml must not be null");
			return (COMMENT_NODE_KIND == xml.nodeKind());
		}

		/**
		 * Returns if the given xml node is a processing instruction node.
		 */
		public static function isProcessingInstructionNode(xml:XML):Boolean {
			Assert.notNull(xml, "The xml must not be null");
			return (PROCESSING_INSTRUCTION_NODE_KIND == xml.nodeKind());
		}

		/**
		 * Returns if the given xml node is an attribute node.
		 */
		public static function isAttributeNode(xml:XML):Boolean {
			Assert.notNull(xml, "The xml must not be null");
			return (ATTRIBUTE_NODE_KIND == xml.nodeKind());
		}

		/**
		 * Converts an attribute to a node.
		 *
		 * @param xml the xml node that contains the attribute
		 * @param attribute the name of the attribute that will be converted to a node
		 * @return the passed in xml node with the specified attribute converted to a node
		 */
		public static function convertAttributeToNode(xml:XML, attribute:String):XML {
			var attributes:XMLList = xml.attribute(attribute);

			if (attributes) {
				if (attributes[0] != undefined) {
					var node:XMLNode = new XMLNode(XMLNodeType.ELEMENT_NODE, attribute);
					var value:XMLNode = new XMLNode(XMLNodeType.TEXT_NODE, attributes[0].toString());
					node.appendChild(value);
					var newNode:XML = new XML(node.toString());
					xml.appendChild(newNode);
					delete attributes[0];
				}
			}
			return xml;
		}

	}
}
