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
 * @created		24/6/21
 */
package com.apm.data.packages
{
	import com.apm.SemVer;
	import com.apm.data.packages.PackageLicense;
	import com.apm.data.utils.JSONUtils;
	
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	
	/**
	 * This represents the file that is included in a package,
	 * detailing a specific version of a package.
	 *
	 * The format is slightly flatter than that returned from the
	 * repository server, and only allows for one single version
	 * of a package.
	 */
	public class PackageDefinitionFile
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "PackageDefinitionFile";
		
		
		public static const DEFAULT_FILENAME:String = "package.json";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _sourceFile:File;
		
		private var _packageDef:PackageDefinition;
		private var _packageVersion:PackageVersion;
		private var _packageDependencies:Vector.<PackageDependency>;
		
		
		public function get sourceFile():File { return _sourceFile; }
		
		
		public function get packageDef():PackageDefinition { return _packageDef; }
		
		
		public function get version():PackageVersion { return _packageVersion; }
		
		
		public function get dependencies():Vector.<PackageDependency> { return _packageDependencies; }
		
		
		public var readme : String = "";
		
		public var changelog : String = "";
		
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function PackageDefinitionFile()
		{
			_packageDef = new PackageDefinition();
			_packageVersion = new PackageVersion();
			
			_packageVersion.packageDef = _packageDef;
			_packageDef.versions.push( _packageVersion );
			
			_packageDependencies = new Vector.<PackageDependency>();
		}
		
		
		public function toString():String
		{
			return _packageDef.toDescriptiveString();
		}
		
		
		public function parse( content:String ):void
		{
			var data:Object = JSON.parse( content );
			
			if (data.hasOwnProperty( "id" )) _packageDef.identifier = data[ "id" ];
			if (data.hasOwnProperty( "name" )) _packageDef.name = data[ "name" ];
			if (data.hasOwnProperty( "url" )) _packageDef.url = data[ "url" ];
			if (data.hasOwnProperty( "docUrl" )) _packageDef.docUrl = data[ "docUrl" ];
			if (data.hasOwnProperty( "description" )) _packageDef.description = data[ "description" ];
			if (data.hasOwnProperty( "type" )) _packageDef.type = data[ "type" ];
			
			if (data.hasOwnProperty( "version" )) _packageVersion.version = SemVer.fromString( data[ "version" ] );
			if (data.hasOwnProperty( "sourceUrl" )) _packageVersion.sourceUrl = data[ "sourceUrl" ];
			if (data.hasOwnProperty( "publishedAt" )) _packageVersion.publishedAt = data[ "publishedAt" ];
			
			if (data.hasOwnProperty( "parameters" ))
			{
				for each (var param:Object in data.parameters)
				{
					_packageVersion.parameters.push( new PackageParameter().fromObject( param ) );
				}
			}
			
			if (data.hasOwnProperty( "dependencies" ))
			{
				for each (var dep:Object in data.dependencies)
				{
					try
					{
						_packageDependencies.push( new PackageDependency().fromObject( dep ) );
					}
					catch (e:Error)
					{
					}
				}
			}
			
			if (data.hasOwnProperty( "tags" ))
			{
				for each (var tag:String in data.tags)
				{
					_packageDef.tags.push( tag );
				}
			}
			
			if (data.hasOwnProperty( "purchaseUrl" )) _packageDef.purchaseUrl = data[ "purchaseUrl" ];
			if (data.hasOwnProperty( "license" )) _packageDef.license = new PackageLicense().fromObject( data[ "license" ] );
			
		}
		
		
		public function stringify():String
		{
			var data:Object = toObject();
			
			// Ensures the output JSON format is in a familiar order
			var keyOrder:Array = ["id", "name", "url", "docUrl", "description", "type", "version", "sourceUrl", "publishedAt", "dependencies", "parameters", "tags"];
			JSONUtils.addMissingKeys( data, keyOrder );
			
			return JSON.stringify( data, keyOrder, 4 ) + "\n";
		}
		
		
		public function toObject( forceObjectOutput:Boolean=false, outputChecksum:Boolean=false ):Object
		{
			var data:Object = {};
			
			data[ "id" ] = _packageDef.identifier;
			data[ "name" ] = _packageDef.name;
			data[ "url" ] = _packageDef.url;
			data[ "docUrl" ] = _packageDef.docUrl;
			data[ "description" ] = _packageDef.description;
			data[ "type" ] = _packageDef.type;
			
			data[ "version" ] = _packageVersion.version.toString();
			data[ "sourceUrl" ] = _packageVersion.sourceUrl;
			data[ "publishedAt" ] = _packageVersion.publishedAt;
			
			var deps:Array = [];
			for each (var dep:PackageDependency in _packageDependencies)
			{
				deps.push( dep.toObject( forceObjectOutput ) );
			}
			data[ "dependencies" ] = deps;
			
			var params:Array = [];
			for each (var param:PackageParameter in _packageVersion.parameters)
			{
				params.push( param.toObject( forceObjectOutput ) );
			}
			data.parameters = params;
			
			var tags:Array = [];
			for each (var tag:String in _packageDef.tags)
			{
				tags.push( tag );
			}
			data.tags = tags;
			
			if (outputChecksum)
			{
				data["checksum"] = _packageVersion.checksum;
			}
			
			if (_packageDef.license)
			{
				data["license"] = _packageDef.license.toObject();
			}
			data[ "purchaseUrl" ] = _packageDef.purchaseUrl;
			
			return data;
		}
		
		
		//
		//	IO
		//
		
		/**
		 * Saves this project definition into the specified file.
		 *
		 * @param f
		 */
		public function save( f:File = null ):void
		{
			if (f == null)
			{
				f = _sourceFile;
			}
			
			if (f == null)
			{
				throw new Error( "No output file specified" );
			}
			
			
			var content:String = stringify();
			
			var fs:FileStream = new FileStream();
			fs.open( f, FileMode.WRITE );
			fs.writeUTFBytes( content );
			fs.close();
		}
		
		
		/**
		 * Loads the specified file as a project definition file
		 *
		 * @param f
		 *
		 * @return
		 */
		public function load( f:File ):PackageDefinitionFile
		{
			if (!f.exists)
			{
				throw new Error( "File doesn't exist" );
			}
			
			_sourceFile = f;
			
			var fs:FileStream = new FileStream();
			fs.open( f, FileMode.READ );
			var content:String = fs.readUTFBytes( fs.bytesAvailable );
			fs.close();
			
			parse( content );
			
			return this;
		}
		
		
	}
}
