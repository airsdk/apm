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
	import com.apm.client.commands.packages.data.InstallQueryRequest;
	import com.apm.data.project.ProjectDefinition;
	
	
	public class ProjectDefintionValidator
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "ProjectDefintionValidator";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function ProjectDefintionValidator()
		{
		}
		
		
		public static function checkPackageAlreadyInstalled( project:ProjectDefinition, request:InstallQueryRequest ):int
		{
			// Check package not already installed
			for (var i:int = 0; i < project.dependencies.length; i++)
			{
				if (request.packageIdentifier == project.dependencies[ i ].identifier)
				{
					if (request.version == "latest")
					{
						return 0; // Unknown as yet
					}
					else if (project.dependencies[i].version.greaterThanOrEqual( SemVer.fromString(request.version) ))
					{
						return 1;
					}
					else
					{
						// TODO Upgrade ?
						return 2;
					}
				}
			}
			return -1;
		}
		
		
	}
}
