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
 * @created		18/5/21
 */
package com.apm.client.commands.packages
{
	import com.apm.client.APM;
	import com.apm.client.commands.Command;
	import com.apm.client.commands.packages.processes.PackageContentCreateProcess;
	import com.apm.client.commands.packages.processes.PackageContentVerifyProcess;
	import com.apm.client.commands.packages.processes.PackageDependenciesVerifyProcess;
	import com.apm.client.commands.packages.processes.ViewPackageProcess;
	import com.apm.client.events.CommandEvent;
	import com.apm.client.logging.Log;
	import com.apm.client.processes.ProcessQueue;
	import com.apm.client.repositories.RepositoryResolver;
	import com.apm.data.packages.PackageDefinition;
	import com.apm.data.packages.PackageDefinitionFile;
	import com.apm.data.packages.PackageDependency;
	
	import flash.events.EventDispatcher;
	
	import flash.filesystem.File;
	
	
	public class PackageAddDependencyCommand extends EventDispatcher implements Command
	{
		
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "PackageAddDependencyCommand";
		
		public static const NAME:String = "package/add";
		
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _parameters:Array;
		private var _queue:ProcessQueue;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function PackageAddDependencyCommand()
		{
			super();
			_queue = new ProcessQueue();
		}
		
		
		public function setParameters( parameters:Array ):void
		{
			_parameters = parameters;
		}
		
		
		public function get name():String
		{
			return NAME;
		}
		
		
		public function get category():String
		{
			return "";
		}
		
		
		public function get requiresNetwork():Boolean
		{
			return true;
		}
		
		
		public function get requiresProject():Boolean
		{
			return false;
		}
		
		
		public function get description():String
		{
			return "add a package dependency into a package under construction";
		}
		
		
		public function get usage():String
		{
			return description + "\n" +
					"\n" +
					"apm package add <package_identifier>    add a package dependency (there must be a package.json in the working dir)\n";
		}
		
		
		public function execute():void
		{
			if (_parameters == null || _parameters.length == 0)
			{
				APM.io.writeLine( "no search params provided" );
				dispatchEvent( new CommandEvent( CommandEvent.PRINT_USAGE, NAME ));
				dispatchEvent( new CommandEvent( CommandEvent.COMPLETE, APM.CODE_ERROR ));
				return;
			}
			var path:String = "";
			var identifier:String = _parameters[0];
			
			APM.io.writeLine( "Adding package dependency: " + identifier );
			
			var packageDir:File = new File( APM.config.workingDir + File.separator + path );
			var packageFile:File =  packageDir.resolvePath( PackageDefinitionFile.DEFAULT_FILENAME );
			if (!packageFile.exists)
			{
				APM.io.writeLine( "no package definition file found" );
				dispatchEvent( new CommandEvent( CommandEvent.PRINT_USAGE, NAME ));
				dispatchEvent( new CommandEvent( CommandEvent.COMPLETE, APM.CODE_ERROR ));
				return;
			}

			APM.io.showSpinner( "Locating package " + identifier );
			RepositoryResolver.repositoryForSource()
					.getPackageVersion( identifier, null, function ( success:Boolean, packageDef:PackageDefinition ):void
					{
						try
						{
							APM.io.stopSpinner( success, success ? "Found package " + packageDef.toString() : "Could not locate package " + identifier );
							if (success && packageDef.versions.length > 0)
							{
								var packageDefinitionFile:PackageDefinitionFile = new PackageDefinitionFile().load( packageFile );
								packageDefinitionFile.dependencies.push(
										new PackageDependency().fromObject( packageDef.toString() )
								);
								packageDefinitionFile.save();
								dispatchEvent( new CommandEvent( CommandEvent.COMPLETE, APM.CODE_OK ) );
							}
							else
							{
								dispatchEvent( new CommandEvent( CommandEvent.COMPLETE, APM.CODE_ERROR ) );
							}
						}
						catch (e:Error)
						{
							Log.e( TAG, e );
							dispatchEvent( new CommandEvent( CommandEvent.COMPLETE, APM.CODE_ERROR ) );
						}
					}
			);
		}
		
	}
	
}
