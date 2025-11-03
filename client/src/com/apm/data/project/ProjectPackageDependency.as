/**
 * @author Michael Archbold (https://michaelarchbold.com)
 * @created 17/10/2025
 */
package com.apm.data.project
{
	import com.apm.SemVerRange;
	import com.apm.data.packages.PackageDependency;

	public class ProjectPackageDependency extends PackageDependency
	{
		////////////////////////////////////////////////////////
		//	CONSTANTS
		//

		private static const TAG:String = "ProjectPackageDependency";


		////////////////////////////////////////////////////////
		//	VARIABLES
		//

		public var delayLoad:String = "none";


		////////////////////////////////////////////////////////
		//	FUNCTIONALITY
		//

		public function ProjectPackageDependency()
		{
		}


		override public function toObject( forceObjectOutput:Boolean = false ):Object
		{
			if (_singleLineOutput && !forceObjectOutput)
			{
				return identifier + ":" + version.toString();
			}
			else
			{
				var o:Object = {
					id     : identifier,
					version: version.toString()
				};
				if (source != null) o.source = source;
				if (delayLoad != "none") o.delayLoad = delayLoad;
				return o;
			}
		}


		override public function fromObject( data:Object ):PackageDependency
		{
			if (data != null)
			{
				if (data is String)
				{
					var line:String = String( data );
					// single line format com.package.example:1.0.0
					// single line format com.package.example@1.0.0
					this._singleLineOutput = true;
					if (line.indexOf( ":" ) > 0)
					{
						this.identifier = line.substring( 0, line.indexOf( ":" ) );
						this.version = SemVerRange.fromString( line.substring( line.indexOf( ":" ) + 1 ) );
					}
					else if (line.indexOf( "@" ) > 0)
					{
						this.identifier = line.substring( 0, line.indexOf( "@" ) );
						this.version = SemVerRange.fromString( line.substring( line.indexOf( "@" ) + 1 ) );
					}
					else
					{
						this.identifier = line;
						this.version = null;
					}
				}
				else
				{
					if (data.hasOwnProperty( "id" )) this.identifier = data["id"];
					if (data.hasOwnProperty( "version" )) this.version = SemVerRange.fromString( data["version"] );
					if (data.hasOwnProperty( "source" )) this.source = data["source"];
					if (data.hasOwnProperty( "package" )) this.identifier = data["package"].identifier;
					if (data.hasOwnProperty( "delayLoad" )) this.delayLoad = data["delayLoad"];
				}
			}
			return this;
		}

		////////////////////////////////////////////////////////
		//	EVENT HANDLERS
		//

	}
}
