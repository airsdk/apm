/**
 * @author 		Michael Archbold (https://michaelarchbold.com)
 * @created		15/6/2021
 */
package com.apm.client.commands.packages.processes
{
	import com.apm.SemVerRange;
	import com.apm.client.APM;
	import com.apm.client.processes.ProcessBase;
	import com.apm.client.repositories.PackageResolver;
	import com.apm.data.packages.PackageDefinition;
	import com.apm.data.packages.PackageDependency;
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
		private var _packageVersion:SemVerRange;


		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//

		public function ViewPackageProcess( packageIdentifier:String, packageVersion:String = null )
		{
			super();
			_packageIdentifier = packageIdentifier;
			_packageVersion = SemVerRange.fromString( packageVersion );
		}


		override public function start( completeCallback:Function = null, failureCallback:Function = null ):void
		{
			super.start( completeCallback, failureCallback );
			if (_packageVersion != null)
			{
				APM.io.showSpinner( "Finding package : " + _packageIdentifier + "@" + _packageVersion.toString() );
				PackageResolver.instance.getPackageVersion(
						_packageIdentifier,
						_packageVersion,
						null,
						null,
						packageResultHandler );
			}
			else
			{
				APM.io.showSpinner( "Finding package : " + _packageIdentifier );
				PackageResolver.instance.getPackage(
						_packageIdentifier,
						null,
						packageResultHandler
				);
			}
		}


		private function packageResultHandler( success:Boolean, packageDefinition:PackageDefinition ):void
		{
			APM.io.stopSpinner( success, "No package found matching : " + _packageIdentifier, success );
			if (success)
			{
				APM.io.writeLine( packageDefinition.toDescriptiveString() );

				if (packageDefinition.license != null && packageDefinition.license.type != "none")
				{
					APM.io.writeLine( "license" );
					APM.io.writeLine(
							listMarker( packageDefinition.license.isPublic ) +
							packageDefinition.license.toDescriptiveString() );
					if (!packageDefinition.license.isPublic)
					{
						APM.io.writeLine( listMarker() + "more info: " + packageDefinition.purchaseUrl );
					}
				}

				var tagsLine:String = "";
				for each (var tag:String in packageDefinition.tags)
				{
					tagsLine += tag + " ";
				}
				APM.io.writeLine( "tags" );
				APM.io.writeLine( listMarker() + "[ " + tagsLine + " ]" );

				printVersions( packageDefinition.versions );
			}
			complete();
		}


		private function printVersions( versions:Vector.<PackageVersion> ):void
		{
			APM.io.writeLine( "versions" );
			var shouldPrintDependencies:Boolean = (versions.length == 1);
			if (versions.length == 0)
			{
				APM.io.writeLine( listMarker() + "(empty)" );
			}
			else
			{
				for (var i:int = 0; i < versions.length; i++)
				{
					var v:PackageVersion = versions[i];
					APM.io.writeLine(
							listMarker( i == versions.length - 1 ) +
							v.toDescriptiveString() );
					if (shouldPrintDependencies)
					{
						printDependencies( v.dependencies, "    " );
					}
				}
			}
		}


		private function printDependencies( dependencies:Vector.<PackageDependency>, prefix:String = "" ):void
		{
			APM.io.writeLine( prefix + "dependencies" );
			if (dependencies.length == 0)
			{
				APM.io.writeLine( prefix + listMarker() + "(none)" );
			}
			else
			{
				for (var i:int = 0; i < dependencies.length; i++)
				{
					APM.io.writeLine(
							prefix +
							listMarker( i == dependencies.length - 1 ) +
							dependencies[i].toString() );
				}
			}
		}


		private function listMarker( isLast:Boolean = true ):String
		{
			return (isLast ? "└── " : "├── ");
		}

	}

}
