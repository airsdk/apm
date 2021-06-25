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
	import com.apm.client.APMCore;
	import com.apm.client.processes.ProcessBase;
	import com.apm.data.packages.PackageVersion;
	
	import flash.utils.setTimeout;
	
	
	public class ExtractPackageProcess extends ProcessBase
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "ExtractPackageProcess";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _core:APMCore;
		private var _package:PackageVersion;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function ExtractPackageProcess( core:APMCore, packageVersion:PackageVersion )
		{
			super();
			_core = core;
			_package = packageVersion;
		}
		
		
		override public function start():void
		{
			_core.io.showSpinner( "Extracting package : " + _package.packageDef.toString() );
			setTimeout( function ():void {
				
				// TODO unzip package
				
				_core.io.stopSpinner( true,
									  "complete" );
				complete();
			}, 2000 );
		}
		
		
	}
	
}
