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
 * @created		27/8/21
 */
package com.apm.data.project
{
	import com.apm.remote.airsdk.AIRSDKVersion;
	
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	
	public class ApplicationDescriptor
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "ApplicationDescriptor";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		public var androidManifest:String = "";
		public var iosInfoAdditions:String = "";
		public var iosEntitlements:String = "";
		
		
		private var _xml:XML;
		public function get xml():XML { return _xml; }
		
		
		
		
		private var _airSDKVersion:AIRSDKVersion;
		
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function ApplicationDescriptor( airSDKVersion:AIRSDKVersion=null )
		{
			_airSDKVersion = (airSDKVersion == null ? new AIRSDKVersion( "33.1.1.556" ) : airSDKVersion);
		}
		
		
		public function load( file:File ):void
		{
			if (file == null || !file.exists)
				return;
			
			try
			{
				var fs:FileStream = new FileStream();
				fs.open( file, FileMode.READ );
				var appDescriptorContent:String = fs.readUTFBytes( fs.bytesAvailable );
				fs.close();
				
				// Remove any existing namespace, to ensure we have the correct AIR SDK namespace
				var nsRegEx:RegExp = new RegExp(" xmlns(?:.*?)?=\".*?\"", "gim");
				_xml = new XML( appDescriptorContent.replace( nsRegEx, "" ) );
				_xml.setNamespace( new Namespace( _airSDKVersion.getNamespace() ) );
			}
			catch (e:Error)
			{
			}
			
		}
		
		
		
		public function toString():String
		{
			if (_xml == null) return "";
			return _xml.toString();
		}
		
		
		
	}
	
}
