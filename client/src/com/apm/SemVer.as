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
		
		private var FORMAT:RegExp = /^(\d|[0-9]\d*)\.(\d|[0-9]\d*)(\.(\d|[0-9]\d*))?(-(alpha|beta|rc)(\.(\d|[1-9]\d*))?)?$/;
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _major:int = 0;
		private var _minor:int = 0;
		private var _patch:int = 0;
		private var _preview:String = null;
		private var _previewNum:int = 0;
		
		
		public function get major():int { return _major; }
		
		
		public function get minor():int { return _minor; }
		
		
		public function get patch():int { return _patch; }
		
		
		public function get preview():String { return _preview; }
		
		
		public function get previewNum():int { return _previewNum; }
		
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function SemVer( version:String )
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
						case 4:
							if (results[ i ] != undefined) _patch = results[ i ];
							break;
						case 6:
							if (results[ i ] != undefined) _preview = results[ i ];
							break;
						case 8:
							if (results[ i ] != undefined) _previewNum = results[ i ];
							break;
					}
				}
			}
			else
			{
				throw new Error( "Invalid version - fails SemVer format" );
			}
		}
		
		
		public static function fromString( version:String ):SemVer
		{
			try
			{
				if (version != null)
					return new SemVer( version );
			}
			catch (e:Error)
			{
			}
			return null;
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
		
		
		//
		//	Comparisons
		//
		
		public function equals( v:SemVer ):Boolean
		{
			if (_major == v._major
					&& _minor == v._minor
					&& _patch == v._patch)
				return true;
			
			// TODO preview info
			return false;
		}
		
		
		public function greaterThanOrEqual( v:SemVer ):Boolean
		{
			if (equals( v )) return true;
			return greaterThan( v );
		}
		
		
		public function greaterThan( v:SemVer ):Boolean
		{
			if (equals( v )) return false;
			if (_major > v._major) return true;
			else if (_major == v._major)
			{
				if (_minor > v._minor) return true;
				else if (_minor == v._minor)
				{
					if (_patch > v._patch) return true;
					// TODO preview info ...
				}
			}
			return false;
		}
		
		
		public function lessThan( v:SemVer ):Boolean
		{
			return !greaterThanOrEqual( v );
		}
		
		
		public function lessThanOrEqual( v:SemVer ):Boolean
		{
			if (equals( v )) return true;
			return lessThan( v );
		}
		
		
	}
	
}
