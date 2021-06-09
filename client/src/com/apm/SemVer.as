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
 * @created		4/6/21
 */
package com.apm
{
	
	public class SemVer
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "SemVer";
		
//		public static const DEFAULT:SemVer = new SemVer( "0.0.0" );
		
		private var FORMAT:RegExp = /^(\d|[1-9]\d*)\.(\d|[1-9]\d*)(\.(\d|[1-9]\d*))?(-(alpha|beta|rc)(\.(\d|[1-9]\d*))?)?$/;
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _major:int = 0;
		private var _minor:int = 0;
		private var _patch:int = 0;
		private var _preview:String = null;
		private var _previewNum:int = 0;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function SemVer( version:String )
		{
			var results:Array = FORMAT.exec( version );
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
					case 4:
						if (results[i] != undefined) _patch = results[ i ];
						break;
					case 6:
						if (results[i] != undefined) _preview = results[ i ];
						break;
					case 8:
						if (results[i] != undefined) _previewNum = results[ i ];
						break;
				}
			}
		}
		
		
		public static function fromString( version:String ):SemVer
		{
			return new SemVer( version );
		}
		
		
		public function toString():String
		{
			return _major + "." + _minor + "." + _patch +
					(
							(_preview == null) ? "" : ("-" + _preview +
										(_previewNum == 0 ? "" : ("." + _previewNum)))
					)
			;
		}
		
	}
}
