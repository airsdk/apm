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
 * @created		10/9/21
 */
package com.apple.plist
{
	import com.apple.plist.entries.PlistDictEntry;
	
	import flash.events.Event;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	
	
	/**
	 *
	 */
	public class Plist extends PlistDictEntry
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "Plist";
		
		private static const EMPTY_PLIST:String =
									 "<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n" +
									 "<!DOCTYPE plist PUBLIC \"-//Apple//DTD PLIST 1.0//EN\" \"http://www.apple.com/DTDs/PropertyList-1.0.dtd\">\n" +
									 "<plist version=\"1.0\">\n" +
									 "<dict>\n" +
									 "\n" +
									 "</dict>\n" +
									 "</plist>";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function Plist( content:String = EMPTY_PLIST )
		{
			super("");
			loadPlistXMLString( content );
		}
		
		
		
		//
		//	LOADING / SAVING
		//
		
		
		public function loadPlistXMLString( xmlString:String ):void
		{
			var xml:XML = new XML( xmlString );
			// process entries
			try
			{
				var dict:XML = xml.children()[0];
				processEntries( dict );
			}
			catch (e:Error)
			{
			}
		}
		
		
		public function toXML():XML
		{
			var xml:XML = new XML( EMPTY_PLIST );
			xml.dict = valueXML();
			return xml;
		}

		
		public function load( plistFile:File ):Plist
		{
			if (!plistFile.exists)
			{
				throw new Error( "plist file does not exist" );
			}
			
			var fs:FileStream = new FileStream();
			fs.open( plistFile, FileMode.READ );
			var content:String = fs.readUTFBytes( fs.bytesAvailable );
			fs.close();
			
			loadPlistXMLString( content );
			
			return this;
		}
		
		
		public function save( plistFile:File ):void
		{
			var data:String = toXML().toXMLString();
			
			var fileStream:FileStream = new FileStream();
			fileStream.open( plistFile, FileMode.WRITE );
			fileStream.writeUTFBytes( data );
			fileStream.close();
		}
		
		
		public function saveAsync( plistFile:File, complete:Function = null ):void
		{
			var data:String = toXML().toXMLString();
			
			var fileStream:FileStream = new FileStream();
			fileStream.addEventListener( Event.CLOSE, function ( event:Event ):void {
				event.currentTarget.removeEventListener( event.type, arguments.callee );
				if (complete != null)
				{
					complete();
				}
			} );
			
			fileStream.openAsync( plistFile, FileMode.WRITE );
			fileStream.writeUTFBytes( data );
			fileStream.close();
		}
		
		
	}
	
	
}
