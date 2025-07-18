/**
 * @author 		Michael Archbold (https://michaelarchbold.com)
 * @created		28/8/2021
 */
package airsdk
{
	import com.apm.utils.FileUtils;
	
	import flash.filesystem.File;
	
	
	/**
	 * Specialised SemVer style version handler for the AIR SDK with 4 version numbers (XX.Y.Z.BBB)
	 */
	public class AIRSDKVersion
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "AIRSDKVersion";
		
		private var FORMAT:RegExp = /^(\d|[0-9]\d*)\.(\d|[0-9]\d*)\.(\d|[0-9]\d*)\.(\d|[0-9]\d*)?$/;
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _major:int = 0;
		private var _minor:int = 0;
		private var _patch:int = 0;
		private var _build:int = 0;
		
		
		public function get major():int { return _major; }
		
		
		public function get minor():int { return _minor; }
		
		
		public function get patch():int { return _patch; }
		
		
		public function get build():int { return _build; }
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function AIRSDKVersion( version:String )
		{
			var results:Array = FORMAT.exec( version );
			if (results != null)
			{
				for (var i:int = 0; i < results.length; i++)
				{
					switch (i)
					{
						case 1:
							_major = results[ i ];
							break;
						case 2:
							_minor = results[ i ];
							break;
						case 3:
							if (results[ i ] != undefined) _patch = results[ i ];
							break;
						case 4:
							if (results[ i ] != undefined) _build = results[ i ];
							break;
					}
				}
			}
			else
			{
				throw new Error( "Invalid AIR SDK version format" )
			}
		}
		
		
		public static function fromString( version:String ):AIRSDKVersion
		{
			try
			{
				if (version != null)
				{
					return new AIRSDKVersion( version );
				}
			}
			catch (e:Error)
			{
			}
			return null;
		}
		
		
		public function toString():String
		{
			return _major + "." + _minor + "." + _patch + "." + _build;
		}
		
		
		public function getNamespace():String
		{
			return "http://ns.adobe.com/air/application/" + _major + "." + _minor;
		}
		
		
		public static function fromAIRSDKDescription( file:File ):AIRSDKVersion
		{
			try
			{
				if (file.exists)
				{
					var airSDKDescriptionString:String = FileUtils.readFileContentAsString( file );
					var airSDKDescription:XML = new XML( airSDKDescriptionString );
					var versionString:String = airSDKDescription.version.text() + "." + airSDKDescription.build.text();
					var version:AIRSDKVersion = new AIRSDKVersion( versionString );
					return version;
				}
			}
			catch (e:Error)
			{
				trace( e );
			}
			return null;
		}
		
		
	}
	
}
