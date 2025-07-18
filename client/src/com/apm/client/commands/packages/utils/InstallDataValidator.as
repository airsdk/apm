/**
 * @author 		Michael Archbold (https://michaelarchbold.com)
 * @created		18/6/2021
 */
package com.apm.client.commands.packages.utils
{
	import com.apm.data.install.*;
	import com.apm.data.packages.PackageIdentifier;
	
	
	public class InstallDataValidator
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "InstallDataValidator";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function InstallDataValidator()
		{
		}
		
		
		/**
		 * This function checks the install data for potential conflicts and generates the list
		 * of packages that need to be installed.
		 *
		 * <br/>
		 * If a compatible list of packages cannot be generated the function will fail.
		 *
		 *
		 * @param data	The <code>InstallData</code> to verify
		 * @return	<code>true</code> if the data was successfully verified and <code>false</code if a install cannot be created
		 */
		public function verifyInstall( data:InstallData ):Boolean
		{
			// Group packages by identifier, each with an array of versions (sorted by version, highest first)
			var packageGroups:Object = groupPackagesByIdentifier( data.packagesAll );
			for (var packageIdentifier:String in packageGroups)
			{
				var group:InstallPackageDataGroup = packageGroups[ packageIdentifier ];
				if (group.length == 1)
				{
					data.packagesToInstall.push( group.versions[ 0 ] );
				}
				else
				{
					// Conflict / multiple versions
					var resolvedPackage:InstallPackageData = resolvePackage( group );
					if (resolvedPackage != null)
					{
						data.packagesToInstall.push( resolvedPackage );
						for (var i:int = 0; i < group.length; i++)
						{
							if (!group.versions[ i ].equals( resolvedPackage ))
							{
								data.packagesToRemove.push( group.versions[ i ] );
							}
						}
					}
					else
					{
						// Unresolved conflict found ...
						data.packagesConflicting.push( group );
					}
				}
			}

			data.packagesToInstall.sort( InstallPackageData.sortFunction );
			data.packagesToRemove.sort( InstallPackageData.sortFunction );
			data.packagesConflicting.sort( InstallPackageDataGroup.sortFunction );

			return data.packagesConflicting.length == 0;
		}
		
		
		/**
		 * Groups the InstallPackageData package references by package identifier
		 *
		 * @param packages
		 *
		 * @return An object, with package identifiers indexing to InstallPackageDataGroup instances
		 */
		private function groupPackagesByIdentifier( packages:Vector.<InstallPackageData> ):Object
		{
			var groups:Object = {};
			for (var i:int = 0; i < packages.length; i++)
			{
				var identifier:String = PackageIdentifier.identifierWithoutVariant( packages[ i ].packageVersion.packageDef.identifier );
				if (!groups.hasOwnProperty( identifier ))
				{
					groups[ identifier ] = new InstallPackageDataGroup();
				}
				// Filter identical duplicates
				var packageGroup:InstallPackageDataGroup = groups[ identifier ];
				packageGroup.addIfNotExists( packages[ i ] );
			}
			for (var packageIdentifier:String in groups)
			{
				var g:InstallPackageDataGroup = groups[ packageIdentifier ];
				if (g.length > 1)
				{
					g.sortByVersion();
				}
			}
			return groups;
		}
		
		
		/**
		 * In order for us to select a version we must have the same major version
		 * for each version and then we select the highest minor/build version.
		 * <br/>
		 * If we cannot resolve a compatible package return null
		 */
		private function resolvePackage( potentialPackages:InstallPackageDataGroup ):InstallPackageData
		{
			// Sort by version
			potentialPackages.sortByVersion();
			
			// take the most recent / highest version as the candidate
			var candidate:InstallPackageData = potentialPackages.versions[ 0 ];
			var candidateMajor:int = candidate.packageVersion.version.major;
			for (var i:int = 0; i < potentialPackages.length; i++)
			{
				var otherMajor:int = potentialPackages.versions[ i ].packageVersion.version.major;
				if (candidateMajor != otherMajor)
				{
					// Conflicting major versions!
					return null;
				}
				// TODO:: Any other conflict checks?
			}
			return candidate;
		}
		
		
	}
}
