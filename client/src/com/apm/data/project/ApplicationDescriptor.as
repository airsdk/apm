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
	import com.apm.client.logging.Log;
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
		
		
		
		public static const APPLICATION_DESCRIPTOR_TEMPLATE:XML = <application xmlns="http://ns.adobe.com/air/application/31.0">
			<id></id>
			<versionNumber>0.0.0</versionNumber>
			<filename>Main</filename>
			<name>Main</name>
			<initialWindow>
				<content>[]</content>
				<visible>true</visible>
				<fullScreen>false</fullScreen>
				<autoOrients>false</autoOrients>
				<renderMode>direct</renderMode>
			</initialWindow>
			<android>
				<manifestAdditions><![CDATA[
		]]></manifestAdditions>
				<containsVideo>true</containsVideo>
			</android>
		</application>;
		
		
		
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
			XML.ignoreWhitespace = true;
			XML.ignoreComments = false;
			
			_airSDKVersion = (airSDKVersion == null ? new AIRSDKVersion( "33.1.1.556" ) : airSDKVersion);
		}
		
		
	
		
		public function updateFromProjectDefinition( project:ProjectDefinition ):void
		{
			if (_xml != null)
			{
				_xml.id = project.applicationId;
				_xml.name = project.applicationName;
				if (project.applicationFilename != null)
				{
					_xml.filename = project.applicationFilename;
				}
				else
				{
					_xml.filename = project.applicationName.replace(/ /g, "");
				}
				_xml.versionNumber = project.version;
				if (project.versionLabel != null)
				{
					_xml.versionLabel = project.versionLabel;
				}
			}
		}
		
		
		public function updateAndroidAdditions():void
		{
			if (androidManifest != null && androidManifest.length > 0 && _xml != null)
			{
				var manifest:XML = new XML( androidManifest );
				var manifestAdditionsContent:String = stripManifestTag( manifest );
				var manifestAdditions:XML = new XML(
						"<manifestAdditions><![CDATA["+
						"<manifest android:installLocation=\"auto\" >\n" +
						manifestAdditionsContent + "\n" +
						"</manifest>\n" +
						"]]></manifestAdditions>"
				);
				
				_xml.android.manifestAdditions = manifestAdditions;
			}
		}
		
		
		private function stripManifestTag( manifest:XML ):String
		{
			var outputLines:Array = [];
			var manifestLines:Array = manifest.toXMLString().split("\n");
			for (var i:int = 0; i < manifestLines.length; i++)
			{
				var line:String = manifestLines[i];
				if (line.indexOf( "<manifest" ) >= 0) continue;
				if (line.indexOf( "</manifest>" ) >= 0) continue;
				outputLines.push( line );
			}
			return outputLines.join("\n");
		}
		
		
		
		public function updateIOSAdditions():void
		{
			if (iosInfoAdditions != null && _xml != null)
			{
				var infoAdditions:XML = new XML("<InfoAdditions><![CDATA[\n" + iosInfoAdditions + "]]></InfoAdditions>" );
				_xml.iPhone.InfoAdditions = infoAdditions;
			}
			if (iosEntitlements != null && _xml != null)
			{
				var entitlements:XML = new XML("<Entitlements><![CDATA[\n" + iosEntitlements + "]]></Entitlements>" );
				_xml.iPhone.Entitlements = entitlements;
			}
		}
		
		
		public function addExtension( extensionID:String ):void
		{
			var exists:Boolean = false;
			if (_xml.child("extensions").length() == 0)
			{
				_xml.extensions = <extensions/>;
			}
			
			for each (var extensionIDNode:XML in _xml.extensions.extensionID)
			{
				exists ||= (extensionID == extensionIDNode.toString());
			}
			if (!exists)
			{
				XML(_xml.extensions).appendChild( <extensionID>{extensionID}</extensionID> );
			}
		}
		
		
		
		//
		// LOADING / SAVING
		//
		
		public function isValid():Boolean
		{
			try
			{
				// TODO:: Some better validation on the descriptor
				if (_xml == null) return false;
				if (_xml.toXMLString().length == 0) return false;
				if (String(_xml.name()).indexOf( "application" ) < 0) return false;
				if (_xml.id == undefined) return false;
				return true;
			}
			catch (e:Error)
			{
			}
			return false;
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
				
				loadString( appDescriptorContent );
			}
			catch (e:Error)
			{
				Log.e( TAG, e );
			}
		}
		
		
		public function loadString( content:String ):void
		{
			try
			{
				// Remove any existing namespace, to ensure we have the correct AIR SDK namespace
				var nsRegEx:RegExp = new RegExp("[ \\n\\t]xmlns(?:.*?)?=\".*?\"", "gim");
				_xml = new XML( content.replace( nsRegEx, "" ) );
				_xml.setNamespace( new Namespace( _airSDKVersion.getNamespace() ) );
			}
			catch (e:Error)
			{
				Log.e( TAG, e );
			}
		}
		
		
		public function save( file:File ):void
		{
			try
			{
				var fs:FileStream = new FileStream();
				fs.open( file, FileMode.WRITE );
				fs.writeUTFBytes( _xml.toXMLString() );
				fs.close();
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
