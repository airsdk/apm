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
 * @created		15/6/2021
 */
package com.apm.client.commands.packages.processes
{
	import com.apm.client.APM;
	import com.apm.data.packages.PackageIdentifier;
	import com.apm.data.packages.PackageParameter;
	import com.apm.utils.DeployFileUtils;
	import com.apm.utils.FileUtils;
	import com.apm.utils.PackageFileUtils;
	import com.apm.client.logging.Log;
	import com.apm.client.processes.ProcessBase;
	import com.apm.data.packages.PackageDefinitionFile;
	import com.apm.utils.ProjectPackageCache;

	import flash.filesystem.File;
	import flash.html.script.Package;


	/**
	 * This process removes any unused project config params associated with an AIR package
	 * - it does not remove any related dependencies
	 * - it only removes config params that isn't related to other packages
	 */
	public class UninstallConfigForPackageProcess extends ProcessBase
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "UninstallConfigForPackageProcess";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _packageDefinition:PackageDefinitionFile;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function UninstallConfigForPackageProcess( packageDefinition:PackageDefinitionFile )
		{
			super();
			_packageDefinition = packageDefinition;
		}
		
		
		override public function start( completeCallback:Function = null, failureCallback:Function = null ):void
		{
			super.start( completeCallback, failureCallback );
			APM.io.showSpinner( "Removing config for package : " + _packageDefinition.packageDef.identifier );

			var paramsToRemove:Vector.<PackageParameter> = new Vector.<PackageParameter>();

			var packages:Vector.<PackageDefinitionFile> = ProjectPackageCache.getPackages();
			for each (var param:PackageParameter in _packageDefinition.version.parameters)
			{
				var shouldRemove:Boolean = true;
				for each (var packageDef:PackageDefinitionFile in packages)
				{
					if (packageDef.packageDef.equals( _packageDefinition.packageDef )) continue;
					for each (var packageParam:PackageParameter in packageDef.version.parameters)
					{
						if (packageParam.name == param.name) shouldRemove = false;
					}
				}

				if (shouldRemove) paramsToRemove.push( param );
			}

			for each (var removeParam:PackageParameter in paramsToRemove)
			{
				APM.config.projectDefinition.removePackageParameter( removeParam.name );
			}

			APM.io.stopSpinner( true, "Removed config for package : " + _packageDefinition.packageDef.identifier );
			complete();
		}
		
		

	}
	
}
