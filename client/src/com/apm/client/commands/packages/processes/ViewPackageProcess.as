/**
 * @author 		Michael Archbold (https://michaelarchbold.com)
 * @created		15/6/2021
 */
package com.apm.client.commands.packages.processes
{
	import com.apm.client.APM;
	import com.apm.client.processes.ProcessBase;
	import com.apm.client.repositories.PackageResolver;
	import com.apm.data.packages.PackageDefinition;
	import com.apm.data.packages.PackageVersion;
	
	
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
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function ViewPackageProcess( packageIdentifier:String )
		{
			super();
			_packageIdentifier = packageIdentifier;
		}
		
		
		override public function start( completeCallback:Function = null, failureCallback:Function = null ):void
		{
			super.start( completeCallback, failureCallback );
			APM.io.showSpinner( "Finding package : " + _packageIdentifier );
			PackageResolver.instance.getPackage(
					_packageIdentifier,
					null,
					function ( success:Boolean, packageDefinition:PackageDefinition ):void
					{
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
									var v:PackageVersion = packageDefinition.versions[ i ];
									APM.io.writeLine(
											(i == packageDefinition.versions.length - 1 ? "└──" : "├──") +
											v.toDescriptiveString() );
								}
							}
							
						}
						complete();
					}
			);
			
		}
		
		
	}
	
}
