/**
 * @author 		Michael Archbold (https://michaelarchbold.com)
 * @created		31/5/2021
 */
package com.apm.data.packages
{
	import com.apm.SemVer;
	import com.apm.SemVerRange;
	
	
	/**
	 * Represents a simple dependency reference either in a package definition file
	 * or the project definition file.
	 * <br/>
	 *
	 * Note: Dependencies from the repository server do not use this format,
	 * they supply PackageVersion with populated PackageDefinition for a more complete specification
	 *
	 */
	public class PackageDependency
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "PackageDependency";
		
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		public var identifier:String;
		public var version:SemVerRange;
		public var source:String;
		
		private var _singleLineOutput:Boolean = false;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function PackageDependency()
		{
		}
		
		
		public function setIdentifier( identifier:String ):PackageDependency
		{
			this.identifier = identifier;
			return this;
		}
		
		
		public function setVersion( version:SemVerRange ):PackageDependency
		{
			this.version = version;
			return this;
		}
		
		
		public function setSource( source:String ):PackageDependency
		{
			this.source = source;
			return this;
		}
		
		
		public function toString():String
		{
			return (identifier == null ? "none" : identifier)
					+ "@" + (version == null ? "unknown" : version.toString())
					+ (source == null ? "" : " ["+source+"]");
		}
		
		
		public function toObject( forceObjectOutput:Boolean=false ):Object
		{
			if (_singleLineOutput && !forceObjectOutput)
			{
				return identifier + ":" + version.toString();
			}
			else
			{
				var o:Object = {
					id:      identifier,
					version: version.toString()
				};
				if (source != null) o.source = source;
				return o;
			}
		}
		
		
		public function fromObject( data:Object ):PackageDependency
		{
			if (data != null)
			{
				if (data is String)
				{
					var line:String = String(data);
					// single line format com.package.example:1.0.0
					// single line format com.package.example@1.0.0
					this._singleLineOutput = true;
					if (line.indexOf(":") > 0)
					{
						this.identifier = line.substring( 0, line.indexOf(":") );
						this.version = SemVerRange.fromString( line.substring( line.indexOf(":") + 1 ) );
					}
					else if (line.indexOf("@") > 0)
					{
						this.identifier = line.substring( 0, line.indexOf("@") );
						this.version = SemVerRange.fromString( line.substring( line.indexOf("@") + 1 ) );
					}
					else
					{
						this.identifier = line;
						this.version = null;
					}
				}
				else
				{
					if (data.hasOwnProperty( "id" )) this.identifier = data[ "id" ];
					if (data.hasOwnProperty( "version" )) this.version = SemVerRange.fromString( data[ "version" ] );
					if (data.hasOwnProperty( "source" )) this.source = data[ "source" ];
					if (data.hasOwnProperty( "package" )) this.identifier = data["package"].identifier;
				}
			}
			return this;
		}
		
	}
	
}
