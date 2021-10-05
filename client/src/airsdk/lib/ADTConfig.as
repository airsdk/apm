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
 * @created		5/10/21
 */
package airsdk.lib
{
	import com.apm.utils.FileUtils;
	
	import flash.filesystem.File;
	
	import org.as3commons.file.PropertiesFile;
	
	
	public class ADTConfig extends PropertiesFile
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "ADTConfig";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function ADTConfig()
		{
			super();
		}
		
		
		public static function load( file:File ):ADTConfig
		{
			var config:ADTConfig = null;
			if (file != null && file.exists)
			{
				var content:String = FileUtils.readFileContentAsString( file );
				
				config = new ADTConfig();
				config.parse( content );
			}
			return config;
		}
		
		
	}
}
