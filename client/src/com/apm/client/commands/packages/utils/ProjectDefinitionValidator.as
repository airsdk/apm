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
	import com.apm.SemVer;
	import com.apm.data.install.InstallRequest;
	import com.apm.data.packages.PackageDependency;
	import com.apm.data.project.ProjectDefinition;
	import com.apm.data.packages.PackageIdentifier;
	
	
	public class ProjectDefinitionValidator
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "ProjectDefinitionValidator";
		
		
		public static const NOT_INSTALLED : int = -1;
		public static const ALREADY_INSTALLED : int = 0;
		public static const UNKNOWN_LATEST_REQUESTED:int = 1;
		public static const HIGHER_VERSION_REQUESTED:int = 2;
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function ProjectDefinitionValidator()
		{
		}
		
		
		public static function checkPackageAlreadyInstalled( project:ProjectDefinition, request:InstallRequest ):int
		{
			// Check package not already installed
			for (var i:int = 0; i < project.dependencies.length; i++)
			{
				if (PackageIdentifier.isEquivalent( request.packageIdentifier, project.dependencies[i].identifier ))
				{
					if (request.version == "latest")
					{
						return UNKNOWN_LATEST_REQUESTED; // Unknown as yet
					}
					else if (project.dependencies[i].version.greaterThanOrEqual( request.semVer ))
					{
						return ALREADY_INSTALLED;
					}
					else
					{
						// Upgrading ...
						return HIGHER_VERSION_REQUESTED;
					}
				}
			}
			return NOT_INSTALLED;
		}
		
		
		public static function getInstalledPackageDependency( project:ProjectDefinition, request:InstallRequest ):PackageDependency
		{
			for (var i:int = 0; i < project.dependencies.length; i++)
			{
				if (PackageIdentifier.isEquivalent( request.packageIdentifier, project.dependencies[ i ].identifier ))
				{
					return project.dependencies[ i ];
				}
			}
			return null;
		}
		
		
	}
}
