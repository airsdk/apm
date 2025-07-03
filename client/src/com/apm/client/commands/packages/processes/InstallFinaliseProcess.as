/**
 * @author 		Michael Archbold (https://michaelarchbold.com)
 * @created		22/6/2021
 */
package com.apm.client.commands.packages.processes
{
	import com.apm.SemVerRange;
	import com.apm.client.APM;
	import com.apm.client.logging.Log;
	import com.apm.client.processes.ProcessBase;
	import com.apm.data.install.InstallData;
	import com.apm.data.install.InstallPackageData;
	import com.apm.data.packages.PackageDependency;
	import com.apm.data.packages.PackageParameter;
	import com.apm.data.packages.PackageVersion;
	import com.apm.data.project.ProjectLock;

	import flash.filesystem.File;

	/**
	 * This is the final process in the install command,
	 * it updates the project config file to represent the resolved
	 * installation state.
	 */
	public class InstallFinaliseProcess extends ProcessBase
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//

		private static const TAG:String = "InstallFinaliseProcess";


		////////////////////////////////////////////////////////
		//  VARIABLES
		//

		private var _installData:InstallData;


		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//

		public function InstallFinaliseProcess( installData:InstallData )
		{
			_installData = installData;
		}


		override public function start( completeCallback:Function = null, failureCallback:Function = null ):void
		{
			super.start( completeCallback, failureCallback );
			Log.d( TAG, "start()" );
			// save all the installed packages into the project file
			var lockFile:ProjectLock = new ProjectLock();
			for each (var p:InstallPackageData in _installData.packagesToInstall)
			{
				var packageVersion:PackageVersion = p.packageVersion;
				packageVersion.source             = p.request.source;

				lockFile.addPackageDependency( p );

				if (p.request.requiringPackage == null)
				{
					var dependency:PackageDependency = new PackageDependency();
					dependency.identifier            = packageVersion.packageDef.identifier;
					dependency.version               = SemVerRange.fromString( p.request.version );
					dependency.source                = p.request.source;

					APM.config.projectDefinition.addPackageDependency( dependency );
				}

				// Ensure all extension parameters are added with defaults
				for each (var param:PackageParameter in p.packageVersion.parameters)
				{
					Log.d( TAG, "add package param: " + param.name );
					APM.config.projectDefinition.addPackageParameter( param );
				}
			}

			APM.config.projectDefinition.save();

			var f:File = new File( APM.config.workingDirectory ).resolvePath( ProjectLock.DEFAULT_FILENAME );
			lockFile.save( f );

			complete();
		}

	}
}
