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
 * @created		4/6/2021
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
		
		private var FORMAT:RegExp = /^([x0-9]*)(\.([0-9]*))?(\.([0-9]*))?(-(alpha|beta|rc)(\.(\d|[1-9]\d*))?)?$/;
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		protected var _major:String = "0";
		protected var _minor:String = "0";
		protected var _patch:String = "0";
		protected var _preview:String = null;
		protected var _previewNum:int = 0;
		
		
		public function get major():int { return int( _major ); }
		
		
		public function get minor():int { return int( _minor ); }
		
		
		public function get patch():int { return int( _patch ); }
		
		
		public function get preview():String { return _preview; }
		
		
		public function get previewNum():int { return _previewNum; }
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function SemVer( version:String, format:RegExp = null )
		{
			if (format == null) format = FORMAT;
			var results:Array = format.exec( version );
			if (results != null)
			{
				for (var i:int = 0; i < results.length; i++)
				{
					switch (i)
					{
						case 1:
							_major = results[ i ];
							break;
						case 3:
							_minor = results[ i ];
							break;
						case 5:
							if (results[ i ] != undefined) _patch = results[ i ];
							break;
						case 7:
							if (results[ i ] != undefined) _preview = results[ i ];
							break;
						case 9:
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
				{
					return new SemVer( version );
				}
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
			{
				return true;
			}
			
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
			if (major > v.major)
			{
				return true;
			}
			else if (major == v.major)
			{
				if (minor > v.minor)
				{
					return true;
				}
				else if (minor == v.minor)
				{
					if (patch > v.patch) return true;
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
