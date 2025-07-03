/**
 * @author 		Michael Archbold (https://michaelarchbold.com)
 * @created		27/10/2021
 */
package com.apm.client.commands.packages
{
	import com.apm.client.APM;
	import com.apm.client.commands.Command;
	import com.apm.client.commands.packages.processes.QueryPackageProcess;
	import com.apm.client.commands.packages.utils.InstallDataValidator;
	import com.apm.client.commands.project.processes.ValidatePackageCacheProcess;
	import com.apm.client.events.CommandEvent;
	import com.apm.client.io.IOColour;
	import com.apm.client.processes.ProcessQueue;
	import com.apm.data.install.InstallData;
	import com.apm.data.install.InstallPackageData;
	import com.apm.data.install.InstallRequest;
	import com.apm.data.packages.PackageDefinitionFile;
	import com.apm.data.packages.PackageDependency;
	import com.apm.data.project.ProjectDefinition;
	import com.apm.utils.ProjectPackageCache;

	import flash.events.EventDispatcher;

	/**
	 * This command will check the registry to see if any updates are available
	 * for the packages that are currently installed.
	 */
	public class OutdatedCommand extends EventDispatcher implements Command
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//

		private static const TAG:String = "OutdatedCommand";

		public static const NAME:String = "outdated";


		////////////////////////////////////////////////////////
		//  VARIABLES
		//

		private var _parameters:Array;
		private var _queue:ProcessQueue;
		private var _queryData:InstallData;


		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//

		public function OutdatedCommand()
		{
			super();
			_queue = new ProcessQueue();
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
			return true;
		}


		public function get description():String
		{
			return "check for outdated packages in your project (packages with a newer version available in the repository)";
		}


		public function get usage():String
		{
			return description + "\n" +
					"\n" +
					"apm outdated              check all dependencies in your project\n" +
					"apm outdated <foo>        check the <foo> dependency in your project\n" +
					"\n" +
					"options: \n" +
					"  --dependencies(--deps)  include package dependencies in the check\n" +
					"                          (default will only check the project installed packages)\n" +
					"  --current               display current packages (without updates) \n"
					;
		}


		public function setParameters( parameters:Array ):void
		{
			_parameters = parameters;
		}


		public function execute():void
		{
			var includeDependencies:Boolean = false;
			var printUpdateAvailableOnly:Boolean = true;
			if (_parameters != null)
			{
				for each (var param:String in _parameters)
				{
					if (param == "--dependencies" || param == "--deps" || param == "--all")
					{
						includeDependencies = true;
					}
					if (param == "--current")
					{
						printUpdateAvailableOnly = false;
					}
				}
			}

			var project:ProjectDefinition = APM.config.projectDefinition;
			if (project == null)
			{
				APM.io.writeError( "project.apm", "No project file found, run 'apm init' first" );
				dispatchEvent( new CommandEvent( CommandEvent.COMPLETE, APM.CODE_ERROR ) );
				return;
			}

			_queryData = new InstallData();

			_queue.addProcess( new ValidatePackageCacheProcess() );

			for each (var dependency:PackageDependency in project.dependencies)
			{
				// If the dependency contains a version range use this, otherwise query for the latest
				_queue.addProcess( new QueryPackageProcess(
						_queryData,
						new InstallRequest(
								dependency.identifier,
								(dependency.version.isRange() ? dependency.version.toString() : "latest"),
								dependency.source
						),
						includeDependencies
				) );
			}

			_queue.start(
					function ():void
					{
						var validator:InstallDataValidator = new InstallDataValidator();
						validator.verifyInstall( _queryData );

						var maxIdentifierLength:int = findMaxIdentifierLength( _queryData.packagesToInstall );

						var hasUpdatesAvailable:Boolean = false;
						for each (var packageToInstall:InstallPackageData in _queryData.packagesToInstall)
						{
							var cachedPackageToInstall:PackageDefinitionFile = ProjectPackageCache.getPackage( packageToInstall.request.packageIdentifier );

							hasUpdatesAvailable ||= cachedPackageToInstall == null ? true : packageToInstall.packageVersion.version.greaterThan(
									cachedPackageToInstall.version.version );
						}

						if (hasUpdatesAvailable || !printUpdateAvailableOnly)
						{
							APM.io.writeLine(
									padTo( "identifier", maxIdentifierLength + 3 ) +
									padTo( "installed", 15 ) +
									padTo( "available", 15 ),
									IOColour.LIGHT_BLUE
							);

							for each (var packageData:InstallPackageData in _queryData.packagesToInstall)
							{
								var cachedPackage:PackageDefinitionFile = ProjectPackageCache.getPackage(
										packageData.request.packageIdentifier );

								var updateAvailable:Boolean = cachedPackage == null ? true : packageData.packageVersion.version.greaterThan(
										cachedPackage.version.version );

								if (updateAvailable || !printUpdateAvailableOnly)
								{
									APM.io.writeLine(
											padTo( packageData.request.packageIdentifier, maxIdentifierLength + 3 ) +
											padTo( cachedPackage == null ? "null" : cachedPackage.version.toString(),
												   15 ) +
											packageData.packageVersion.toString(),
											(updateAvailable ? IOColour.GREEN : null)
									);
								}
							}
						}

						dispatchEvent( new CommandEvent( CommandEvent.COMPLETE, APM.CODE_OK ) );
					},
					function ( error:String ):void
					{
						APM.io.writeError( name, error );
						dispatchEvent( new CommandEvent( CommandEvent.COMPLETE, APM.CODE_ERROR ) );
					} );
		}


		private function findMaxIdentifierLength( packages:Vector.<InstallPackageData> ):int
		{
			var maxIdentifierLength:int = 0;
			for each (var packageData:InstallPackageData in packages)
			{
				if (packageData.request.packageIdentifier.length > maxIdentifierLength)
				{
					maxIdentifierLength = packageData.request.packageIdentifier.length;
				}
			}
			return maxIdentifierLength;
		}


		private function padTo( s:String, length:int, padChar:String = " " ):String
		{
			var paddedValue:String = s;
			while (paddedValue.length < length)
			{
				paddedValue += padChar;
			}
			return paddedValue;
		}


	}

}
