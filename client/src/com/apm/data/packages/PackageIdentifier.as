/**
 *        __       __               __
 *   ____/ /_ ____/ /______ _ ___  / /_
 *  / __  / / ___/ __/ ___/ / __ `/ __/
 * / /_/ / (__  ) / / /  / / /_/ / /
 * \__,_/_/____/_/ /_/  /_/\__, /_/
 *                           / /
 *                           \/
 * http://distriqt.com
 *
 * @author 		Michael (https://github.com/marchbold)
 * @created		13/8/2021
 */
package com.apm.data.packages
{


	/**
	 * Utilities for comparing package identifiers
	 */
	public class PackageIdentifier
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//

		private static const TAG:String = "PackageIdentifier";


		////////////////////////////////////////////////////////
		//  VARIABLES
		//


		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//

		public function PackageIdentifier()
		{
		}


		/**
		 * Checks whether 2 package identifiers are equivalent.
		 * <br/>
		 * This takes into account variants of packages so "com.package" and "com.package-variant" will
		 * return true as being the same package.
		 *
		 * @param identifierA	Package identifier of the first package
		 * @param identifierB	Package identifier of the second package
		 *
		 * @return <code>true</code> if the packages are considered equivalent, ie same package or variant of the package
		 */
		public static function isEquivalent( identifierA:String, identifierB:String ):Boolean
		{
			if (identifierA == null || identifierB == null) return false;
			if (identifierA.toLowerCase() == identifierB.toLowerCase()) return true;
			return identifierWithoutVariant( identifierA ).toLowerCase() ==
					identifierWithoutVariant( identifierB ).toLowerCase();
		}


		/**
		 * Removes the "variant" from a package identifier and returns the identifier
		 *
		 * @param identifier The complete package identifier
		 *
		 * @return The package identifier with no variant
		 */
		public static function identifierWithoutVariant( identifier:String ):String
		{
			if (identifier.indexOf( "-" ) > 0)
			{
				return identifier.substring( 0, identifier.indexOf( "-" ) );
			}
			return identifier;
		}


		/**
		 * Returns the "variant" from the package identifier
		 *
		 * @param identifier	The complete package identifier
		 *
		 * @return
		 */
		public static function variantFromIdentifier( identifier:String ):String
		{
			if (identifier.indexOf( "-" ) > 0)
			{
				return identifier.substring( identifier.indexOf( "-" ) + 1 );
			}
			return "";
		}


		/**
		 * Checks the identifier is valid
		 *
		 * @param identifier	The complete package identifier
		 *
		 * @return
		 */
		public static function isValid( identifier:String ):Boolean
		{
			var pattern:RegExp = /^([A-Za-z]{1}[A-Za-z\d_]*\.)*[A-Za-z][A-Za-z\d_]*$/i;

			var result:Object = pattern.exec( identifierWithoutVariant( identifier ) );
			return result != null;
		}


	}

}
