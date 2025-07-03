/**
 * @author 		Michael Archbold (https://michaelarchbold.com)
 * @created		27/8/2021
 */
package com.apm.data.project
{
	import airsdk.AIRSDKVersion;

	import com.apm.client.logging.Log;

	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;

	public class ApplicationDescriptor
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//

		private static const TAG:String = "ApplicationDescriptor";

		public static const LANG_NAMESPACE:String = "http://www.w3.org/XML/1998/namespace";
		public static const ANDROID_NAMESPACE:String = "http://schemas.android.com/apk/res/android";

		public static const APPLICATION_DESCRIPTOR_TEMPLATE:XML = <application xmlns="http://ns.adobe.com/air/application/33.1">
			<id/>
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
				<containsVideo>true</containsVideo>
				<manifestAdditions/>
			</android>

			<iPhone>
				<requestedDisplayResolution>high</requestedDisplayResolution>
				<InfoAdditions/>
				<Entitlements/>
			</iPhone>

			<extensions/>

		</application>;


		////////////////////////////////////////////////////////
		//  VARIABLES
		//

		public var androidManifest:String = "";
		public var iosInfoAdditions:String = "";
		public var iosEntitlements:String = "";


		private var _xml:XML;
		public function get xml():XML { return _xml; }


		private var _airNS:Namespace;


		public function get namespace():Namespace { return _airNS; }


		private var _langNS:Namespace;


		public function get xmlNamespace():Namespace { return _langNS; }


		private var _airSDKVersion:AIRSDKVersion;


		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//

		public function ApplicationDescriptor( airSDKVersion:AIRSDKVersion = null, stripComments:Boolean = false )
		{
			XML.ignoreWhitespace = true;
			XML.ignoreComments = stripComments;

			_airSDKVersion = airSDKVersion;
			if (_airSDKVersion != null)
			{
				_airNS = new Namespace( "", _airSDKVersion.getNamespace() );
			}

			_langNS = new Namespace( "xml", LANG_NAMESPACE );
		}


		private function isPropertyValueValid( value:Object ):Boolean
		{
			if (value == null) return false;
			if (value is String)
			{
				return String( value ).length > 0;
			}
			return true;
		}


		public function updateFromProjectDefinition( project:ProjectDefinition, buildType:String = null ):void
		{
			if (_xml != null)
			{
				default xml namespace = _airNS;

				if (isPropertyValueValid( project.getApplicationId( buildType ) )) _xml.id = project.getApplicationId( buildType );
				if (isPropertyValueValid( project.getApplicationName( buildType ) ))
				{
					if (project.getApplicationName( buildType ) is String)
					{
						_xml.name = project.getApplicationName( buildType );
					}
					else
					{
						var name:XML = <name></name>;
						var langs:Array = getSortedKeys( project.getApplicationName( buildType ) );
						for each (var lang:String in langs)
						{
							var text:XML = <text>{project.getApplicationName( buildType )[lang]}</text>;
							text.@_langNS::lang = lang;
							name.appendChild( text );
						}
						_xml.name = name;
					}
				}
				if (isPropertyValueValid( project.getApplicationFilename( buildType ) )) _xml.filename = project.getApplicationFilename( buildType );
				if (isPropertyValueValid( project.getVersion( buildType ) )) _xml.versionNumber = project.getVersion( buildType );
				if (isPropertyValueValid( project.getVersionLabel( buildType ) )) _xml.versionLabel = project.getVersionLabel( buildType );

			}
		}


		private function getSortedKeys( data:Object ):Array
		{
			var keys:Array = [];
			for (var key:String in data)
			{
				keys.push( key );
			}
			keys.sort();
			return keys;
		}


		//
		//	ANDROID
		//

		public function updateAndroidAdditions():void
		{
			if (androidManifest != null && androidManifest.length > 0 && _xml != null)
			{
				//
				// We slightly modify the android manifest generated to make it suitable for the air manifest additions
				//
				// - delete any unsupported application attributes
				//     (https://airsdk.dev/docs/development/application-descriptor-files/android)
				// - strip the manifest tag to remove unsupported attributes/namespaces
				//     (means we have to treat it as a string otherwise entries will get broken)
				// - generate a simple manifest tag
				// - manually add any other custom namespaces (mainly for amazon)
				// - write the contents from the merge
				//

				var manifest:XML = new XML( androidManifest );
				var androidns:Namespace = new Namespace( "android", ANDROID_NAMESPACE );

				delete manifest.application.@androidns::theme[0];
				delete manifest.application.@androidns::name[0];
				delete manifest.application.@androidns::label[0];
				delete manifest.application.@androidns::windowSoftInputMode[0];
				delete manifest.application.@androidns::configChanges[0];
				delete manifest.application.@androidns::screenOrientation[0];
				delete manifest.application.@androidns::launchMode[0];

				var manifestAdditionsContent:String = stripManifestTag( manifest );
				var manifestAdditions:XML = new XML(
						"<manifestAdditions><![CDATA[" +
						"<manifest android:installLocation=\"auto\" " + namespacesString( manifest.namespaceDeclarations() ) + ">\n" +
						manifestAdditionsContent + "\n" +
						"</manifest>\n" +
						"]]></manifestAdditions>"
				);

				default xml namespace = _airNS;

				_xml.android.manifestAdditions = manifestAdditions;
			}
		}


		private function stripManifestTag( manifest:XML ):String
		{
			var outputLines:Array = [];
			var manifestLines:Array = manifest.toXMLString().split( "\n" );
			for (var i:int = 0; i < manifestLines.length; i++)
			{
				var line:String = manifestLines[i];
				if (line.indexOf( "<manifest" ) >= 0) continue;
				if (line.indexOf( "</manifest>" ) >= 0) continue;
				outputLines.push( line );
			}
			return outputLines.join( "\n" );
		}


		private function namespacesString( namespaces:Array ):String
		{
			var manifestNamespaces:String = "";
			for each (var ns:Namespace in namespaces)
			{
				if (ns.uri != ANDROID_NAMESPACE)
				{
					manifestNamespaces += " xmlns:" + ns.prefix + "=\"" + ns.uri + "\" ";
				}
			}
			return manifestNamespaces;
		}


		//
		//	iOS
		//

		public function updateIOSAdditions():void
		{
			default xml namespace = _airNS;

			if (iosInfoAdditions != null && iosInfoAdditions.length > 0 && _xml != null)
			{
				var infoAdditions:XML = new XML( "<InfoAdditions><![CDATA[\n" + iosInfoAdditions + "]]></InfoAdditions>" );
				_xml.iPhone.InfoAdditions = infoAdditions;
			}
			if (iosEntitlements != null && iosEntitlements.length > 0 && _xml != null)
			{
				var entitlements:XML = new XML( "<Entitlements><![CDATA[\n" + iosEntitlements + "]]></Entitlements>" );
				_xml.iPhone.Entitlements = entitlements;
			}
		}


		//
		//	EXTENSIONS
		//

		public function addExtension( extensionID:String ):void
		{
			default xml namespace = _airNS;

			if (_xml.extensions == undefined)
			{
				_xml.extensions = <extensions/>;
			}

			var extensionIDs:Array = [];
			for each (var extensionIDNode:XML in _xml.extensions..extensionID)
			{
				// Filter duplicates
				if (existsInArray( extensionIDs, extensionIDNode.toString() ))
					continue;
				extensionIDs.push( extensionIDNode.toString() );
			}
			if (!existsInArray( extensionIDs, extensionID ))
			{
				extensionIDs.push( extensionID );
			}
			extensionIDs.sort();

			_xml.extensions = <extensions/>;
			for each (var extID:String in extensionIDs)
			{
				_xml.extensions.appendChild( <extensionID>{extID}</extensionID> );
			}
		}

		private function existsInArray( arr:Array, value:* ):Boolean
		{
			if (arr == null) return false;
			for each (var item:* in arr)
			{
				if (value == item)
					return true;
			}
			return false;
		}


		public function removeAllExtensions():void
		{
			default xml namespace = _airNS;

			_xml.extensions = <extensions/>;
		}


		public function removeExtension( extensionIDToRemove:String ):void
		{
			default xml namespace = _airNS;
			if (_xml.extensions == undefined)
			{
				return;
			}
			for (var i:int = 0; i < _xml.extensions..extensionID.length(); i++)
			{
				if (_xml.extensions..extensionID[i].toString() == extensionIDToRemove)
				{
					delete _xml.extensions..extensionID[i];
					return;
				}
			}
//			delete _xml.extensions.(elements.toString() == extensionID)[0];
//			delete _xml.extensions.(extensionID == extensionIDToRemove)[0];
		}


		//
		// 	VALIDATION
		//

		public function validate():String
		{
			try
			{
				default xml namespace = _airNS;

				// TODO:: Some better validation on the descriptor

				if (_xml == null) return "XML cannot be parsed (null)";
				if (_xml.toXMLString().length == 0) return "XML is empty or invalid";
				if (String( _xml.toXMLString() ).indexOf( "application" ) < 0) return "root tag <application> not found";

				if (_xml.id == undefined) return "<id> tag not found";

				return null;
			}
			catch (e:Error)
			{
				return e.message;
			}
		}


		public function isValid():Boolean
		{
			return validate() == null;
		}


		//
		// 	LOADING / SAVING
		//

		public function load( file:File ):void
		{
			if (file == null || !file.exists)
			{
				Log.d( TAG, "ERROR: " + (file == null ? "null" : file.name) + " doesn't exist" );
				return;
			}

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
				Log.v( TAG, "loadString(): " + content );
				// If supplied an AIR Version, make sure namespace matches
				if (_airNS != null)
				{
					content = content.replace(
							/http:\/\/ns\.adobe\.com\/air\/application\/([0-9]*)\.([0-9]*)/,
							_airNS.toString()
					);
				}

				_xml = new XML( content );

				// Ensure we have the correct AIR namespace
				if (_xml.namespace( "" ) != undefined)
				{
					_airNS = _xml.namespace( "" );
				}

				Log.d( TAG, "namespace= " + _airNS.toString() );

				// Add the language namespace to correctly handle xml:lang translations
				_xml.addNamespace( _langNS );

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
				default xml namespace = _airNS;

				// Strip out language namespace which AIR doesn't need
				var xmlContent:String = "<?xml version=\"1.0\" encoding=\"utf-8\" ?>\n" +
						_xml.toXMLString()
							.replace( "xmlns:xml=\"http://www.w3.org/XML/1998/namespace\"", "" )
				;

				var fs:FileStream = new FileStream();
				fs.open( file, FileMode.WRITE );
				fs.writeUTFBytes( xmlContent );
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
