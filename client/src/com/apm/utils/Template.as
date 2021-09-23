/**
 * @author 		Jean-Christophe Hoelt (https://github.com/j3k0)
 * @created		23/9/21
 */
package com.apm.utils
{
	import com.apm.client.logging.Log;
	import com.apm.utils.FileUtils;
	import flash.filesystem.File;
	
	public class Template
	{
		public static function compile( content:String, configuration:Object ):String
		{
			var output:String = content;
			for (var name:String in configuration)
			{
				var regex:RegExp = new RegExp( "\\$\\{[ \t]*" + name + "[ \t]*\\}", "g" );
				var value:String = getParam( configuration, name );
				
				output = output.replace( regex, value );
			}
			return output;
		}

		public static function compileFile( inputFile:File, configuration:Object ):String
		{
			var content:String = FileUtils.readFileContentAsString( inputFile );
			return compile( content, configuration );
		}

		public static function compileFileToFile( inputFile:File, outputFile:File, configuration:Object ):String
		{
			var content:String = FileUtils.readFileContentAsString( inputFile );
			var compiled:String = compile( content, configuration );
			FileUtils.writeStringAsFileContent( outputFile, compiled );
			return compiled;
		}

		private static function getParam( configuration:Object, key:String ):String
		{
			if (configuration.hasOwnProperty( key ))
			{
				return configuration[ key ];
			}
			return null;
		}
	}
}
