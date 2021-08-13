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
package com.apm.client.commands.packages.utils
{
	
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
		
		
		public static function isEquivalent( identifierA:String, identifierB:String ):Boolean
		{
			if (identifierA == identifierB) return true;
			return identifierWithoutVariant( identifierA ) == identifierWithoutVariant( identifierB );
		}
		
		
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
