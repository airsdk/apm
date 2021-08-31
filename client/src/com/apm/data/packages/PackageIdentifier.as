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
 * @created		13/8/21
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
			if (identifierA == identifierB) return true;
			return identifierWithoutVariant( identifierA ) == identifierWithoutVariant( identifierB );
		}
		
		
		/**
		 * Removes the "variant" identifier from a package and returns the package identifier
		 *
		 * @param identifier
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
	
		
		
		
		
	}
}
