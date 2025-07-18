/**
 * @author 		Michael Archbold (https://michaelarchbold.com)
 * @created		9/6/2023
 */
package com.apm.data.common
{
	import org.as3commons.lang.IEquals;

	public class Platform implements IEquals
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//

		private static const TAG:String = "Platform";

		public static const ANDROID:String = "android";
		public static const IOS:String = "ios";
		public static const TVOS:String = "tvos";
		public static const MACOS:String = "macos";
		public static const WINDOWS:String = "windows";
		public static const LINUX:String = "linux";
		public static const COMMON:String = "common";
		public static const UNSPECIFIED:String = "unspecified";

		public static const ALL_PLATFORMS:Vector.<String> = new <String>[
			ANDROID, TVOS, IOS, MACOS, WINDOWS, LINUX
		];

		////////////////////////////////////////////////////////
		//  VARIABLES
		//

		public var name:String = UNSPECIFIED;

		private var _singleLineOutput:Boolean = false;


		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//

		public function Platform( name:String = "", singleLineOutput:Boolean = false )
		{
			this.name = name;
			this._singleLineOutput = singleLineOutput;
		}


		public function equals( other:Object ):Boolean
		{
			if (!(other is Platform))
			{
				return false;
			}
			return ((other as Platform).name == name);
		}


		public function toString():String
		{
			return name;
		}


		/**
		 * This helper function retrieves the platform name from a sub-platform variant.
		 *
		 * Variants include sub-platforms like <code>ios_simulator</code>
		 *
		 * @param variant	The name of the sub-platform
		 * @return
		 */
		public static function getPlatformFromVariant( variant:String ):String
		{
			var variantLowerCase:String = variant.toLowerCase();
			if (variantLowerCase.substr( 0, Platform.IOS.length ) == Platform.IOS)
			{
				return Platform.IOS;
			}
			if (variantLowerCase.substr( 0, Platform.TVOS.length ) == Platform.TVOS)
			{
				return Platform.TVOS;
			}
			if (variantLowerCase.substr( 0, Platform.ANDROID.length ) == Platform.ANDROID)
			{
				return Platform.ANDROID;
			}
			if (variantLowerCase.substr( 0, Platform.WINDOWS.length ) == Platform.WINDOWS)
			{
				return Platform.WINDOWS;
			}
			if (variantLowerCase.substr( 0, Platform.MACOS.length ) == Platform.MACOS)
			{
				return Platform.MACOS;
			}
			if (variantLowerCase.substr( 0, Platform.LINUX.length ) == Platform.LINUX)
			{
				return Platform.LINUX;
			}
			return variantLowerCase;
		}


		/**
		 * Checks if the given platform name is one of the known platform names.
		 *
		 * @param platform	The name of the platform to check
		 * @return			<code>true</code> if the platform name is known, <code>false</code> otherwise
		 */
		public static function isKnownPlatformName( platform:String ):Boolean
		{
			switch (platform)
			{
				case ANDROID:
				case IOS:
				case TVOS:
				case MACOS:
				case WINDOWS:
				case LINUX:
					return true;
			}
			return false;
		}


		public function toObject( forceObjectOutput:Boolean = false ):Object
		{
			if (_singleLineOutput && !forceObjectOutput)
			{
				return name;
			}
			else
			{
				var data:Object = {
					name: name
				};
				return data;
			}
		}


		public static function fromObject( data:Object ):Platform
		{
			if (data == null)
				return null;

			var platform:Platform = new Platform();
			if (data is String)
			{
				// single line format
				platform._singleLineOutput = true;
				platform.name = String( data );
			}
			else
			{
				platform._singleLineOutput = false;
				if (data.hasOwnProperty( "name" )) platform.name = data["name"];
			}
			return platform;
		}


	}

}
