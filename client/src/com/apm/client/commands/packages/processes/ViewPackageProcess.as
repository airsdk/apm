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
 * @created		15/6/21
 */
package com.apm.client.commands.packages.processes
{
	import com.apm.client.APM;
	import com.apm.client.processes.ProcessBase;
	import com.apm.data.packages.PackageDefinition;
	import com.apm.remote.repository.RepositoryAPI;
	
	
	public class ViewPackageProcess extends ProcessBase
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "ViewPackageProcess";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _packageIdentifier:String;
		private var _repositoryAPI:RepositoryAPI;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function ViewPackageProcess( packageIdentifier:String )
		{
			super();
			_packageIdentifier = packageIdentifier;
			_repositoryAPI = new RepositoryAPI();
		}
		
		
		override public function start( completeCallback:Function = null, failureCallback:Function = null ):void
		{
			super.start( completeCallback, failureCallback );
			APM.io.showSpinner( "Finding package : " + _packageIdentifier );
			_repositoryAPI.getPackage( _packageIdentifier, function ( success:Boolean, packageDefinition:PackageDefinition ):void {
				APM.io.stopSpinner( success, "No package found matching : " + _packageIdentifier, success );
				if (success)
				{
					APM.io.writeLine( packageDefinition.toDescriptiveString() );
					
					if (packageDefinition.license != null && packageDefinition.license.type != "none")
					{
						APM.io.writeLine( "license" );
						APM.io.writeLine( "└── " + packageDefinition.license.toDescriptiveString() );
						if (!packageDefinition.license.isPublic)
						{
							APM.io.writeLine( "└── more info: " + packageDefinition.purchaseUrl );
						}
					}
					
					var tagsLine:String = "";
					for each (var tag:String in packageDefinition.tags)
					{
						tagsLine += tag + " ";
					}
					APM.io.writeLine( "tags" );
					APM.io.writeLine( "└── [ " + tagsLine + " ]" );
					
					if (packageDefinition.versions.length == 0)
					{
						APM.io.writeLine( "└── (empty)" );
					}
					else
					{
						APM.io.writeLine( "versions" );
						for (var i:int = 0; i < packageDefinition.versions.length; i++)
						{
							APM.io.writeLine(
									(i == packageDefinition.versions.length - 1 ? "└──" : "├──") +
									packageDefinition.versions[ i ].toDescriptiveString() );
						}
					}
					
				}
				complete();
			} );
			
		}
		
		
	}
	
}
