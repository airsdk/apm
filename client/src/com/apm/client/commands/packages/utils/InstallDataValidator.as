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
 * @created		18/6/21
 */
package com.apm.client.commands.packages.utils
{
	import com.apm.client.commands.packages.data.*;
	import com.apm.client.commands.packages.data.InstallData;
	import com.apm.client.commands.packages.data.InstallPackageData;
	
	
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
			var installList:Vector.<InstallPackageData> = new Vector.<InstallPackageData>();
			var duplicatePackages:Object = findDuplicatePackages( data.packagesAll );
			
			for (var packageIdentifier:String in duplicatePackages)
			{
				var resolvedPackage:InstallPackageData = resolvePackage( duplicatePackages[packageIdentifier] );
				
				
			}
			
			
			
			
			return false;
		}
		
		
		private function findDuplicatePackages( packages:Vector.<InstallPackageData> ):Object
		{
			var duplicates:Object = {};
			for (var i:int = 0; i < packages.length; i++)
			{
				for (var j:int = 0; j < packages.length; j++)
				{
					if (i != j)
					{
						if (packages[i].packageDefinition.equals( packages[j].packageDefinition ) )
						{
							if (!duplicates.hasOwnProperty(packages[i].packageDefinition.identifier))
							{
								duplicates[ packages[i].packageDefinition.identifier ] = [];
							}
							
							var packageDuplicates:Array = duplicates[ packages[i].packageDefinition.identifier ];
							addIfNotExists( packageDuplicates, packages[i] );
							addIfNotExists( packageDuplicates, packages[j] );
						}
					}
				}
			}
			return duplicates;
		}
		
		
		private function addIfNotExists( dest:Array, data:InstallPackageData ):void
		{
			var exists:Boolean = false;
			for each (var p:InstallPackageData in dest)
			{
				if (installDataMatches( p, data )) exists = true;
			}
			if (!exists)
			{
				dest.push( data );
			}
		}
		
		
		private function installDataMatches( a:InstallPackageData, b:InstallPackageData ):Boolean
		{
			if (a.packageDefinition.equals( b.packageDefinition )
					&& a.packageVersion.equals( b.packageVersion))
			{
				return true;
			}
			return false;
		}
		
		
		/**
		 * In order for us to select a version we must have the same major version
		 * for each version and then we select the highest minor/build version.
		 * <br/>
		 * If we cannot resolve a compatible package return null
		 */
		private function resolvePackage( potentialPackages:Array ):InstallPackageData
		{
			var major:int = 0;
			for each (var potential:InstallPackageData in potentialPackages)
			{
			
			}
			return null;
		}
		
		
	}
}
