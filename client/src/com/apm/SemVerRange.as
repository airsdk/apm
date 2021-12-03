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
	
	public class SemVerRange extends SemVer
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "SemVer";

//		public static const DEFAULT:SemVer = new SemVer( "0.0.0" );
		
		private var FORMAT:RegExp = /^([x0-9]*)(\.([x0-9]*))?(\.([x0-9]*))?(-(alpha|beta|rc)(\.(\d|[1-9]\d*))?)?$/;
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function SemVerRange( version:String )
		{
			super( version, FORMAT );
		}
		
		
		public static function fromString( version:String ):SemVerRange
		{
			try
			{
				if (version != null)
				{
					return new SemVerRange( version );
				}
			}
			catch (e:Error)
			{
			}
			return null;
		}
		
		
		/**
		 * Returns true if this instance represents a range of potential versions.
		 * <br/>
		 * This is true if the version contains an "x"
		 *
		 * @return
		 */
		public function isRange():Boolean
		{
			return _major == "x" || _minor == "x" || _patch == "x";
		}
		
		
		override public function toString():String
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
		
		override public function equals( v:SemVer ):Boolean
		{
			if (v == null) return false;
			
			if (major == v.major
				&& minor == v.minor
				&& patch == v.patch)
			{
				return true;
			}
			
			// TODO preview info
			return false;
		}
		
		
		override public function greaterThanOrEqual( v:SemVer ):Boolean
		{
			if (equals( v )) return true;
			return greaterThan( v );
		}
		
		
		override public function greaterThan( v:SemVer ):Boolean
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
		
		
		override public function lessThan( v:SemVer ):Boolean
		{
			return !greaterThanOrEqual( v );
		}
		
		
		override public function lessThanOrEqual( v:SemVer ):Boolean
		{
			if (equals( v )) return true;
			return lessThan( v );
		}
		
		
	}
	
}
