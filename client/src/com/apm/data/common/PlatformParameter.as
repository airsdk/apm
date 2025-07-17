/**
 * @author Michael Archbold (https://michaelarchbold.com)
 * @created 3/7/2025
 */
package com.apm.data.common
{
	import com.apm.SemVer;

	public class PlatformParameter
	{
		////////////////////////////////////////////////////////
		//	CONSTANTS
		//

		private static const TAG:String = "PlatformParameter";


		public static const TYPE_BOOLEAN:String = "boolean";
		public static const TYPE_VERSION:String = "version";
		public static const TYPE_STRING_ARRAY:String = "stringArray";
		public static const TYPE_STRING:String = "string";
		public static const TYPE_NUMBER:String = "number";
		public static const TYPE_UNKOWN:String = "unknown";


		////////////////////////////////////////////////////////
		//	VARIABLES
		//

		public var name:String;

		public var value:String = "";


		////////////////////////////////////////////////////////
		//	FUNCTIONALITY
		//

		public function PlatformParameter( name:String, value:String = "" )
		{
			this.name = name;
			this.value = value;
		}


		public function isValid():Boolean
		{
			switch (valueType())
			{
				case TYPE_BOOLEAN:
					return value.toLowerCase() == "true" || value.toLowerCase() == "false" || value == "1" || value == "0";

				case TYPE_VERSION:
					try
					{
						new SemVer( value );
						return true;
					}
					catch (e:Error)
					{
						return false;
					}

				case TYPE_NUMBER:
					return !isNaN( parseFloat( value ) );

				case TYPE_STRING:
				case TYPE_STRING_ARRAY:
					return value != null && value != "";

				case TYPE_UNKOWN:
				default:
					return false;
			}
		}


		public function asBoolean():Boolean
		{
			return value.toLowerCase() == "true" || value == "1";
		}


		public function asVersion():SemVer
		{
			return new SemVer( value );
		}


		public function asNumber():Number
		{
			return parseFloat( value );
		}


		public function asStringArray():Array
		{
			if (value == null || value == "")
			{
				return [];
			}
			return value.split( "," );
		}


		public function valueType():String
		{
			switch (name)
			{
					// Boolean
				case "containsVideo":
				case "runtimeInBackgroundThread":
				case "disableSensorAccess":
				case "preventDeviceModelAccess":
				case "webViewAllowFileAccess":
				case "supportsAndroidTV":
				{
					return TYPE_BOOLEAN;
				}

					// Versions
				case "minimumVersion":
				case "deploymentTarget":
				case "gradleVersion":
				case "androidGradlePluginVersion":
				case "androidBuildToolsVersion":
				case "androidCompileSdkVersion":
				{
					return TYPE_VERSION;
				}

					// String arrays
				case "buildArchitectures":
				case "uncompressedExtensions":
				{
					return TYPE_STRING_ARRAY;
				}

					// Strings
				case "requestedDisplayResolution":
				{
					return TYPE_STRING;
				}

			}
			return TYPE_UNKOWN;
		}


	}

}
