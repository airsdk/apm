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
package com.apm.client.commands.project.processes
{
	import com.apm.client.APM;
	import com.apm.client.processes.ProcessBase;
	import com.apm.data.project.ProjectParameter;
	import com.apm.utils.FileUtils;
	import com.apple.plist.Plist;
	import com.apple.plist.PlistUtils;
	
	import flash.filesystem.File;
	
	
	public class IOSPlistMergeProcess extends ProcessBase
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "IOSPlistMergeProcess";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		private var _mergePlist:File;
		private var _currentPlist:File;
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function IOSPlistMergeProcess( mergePlist:File, currentPlist:File )
		{
			_mergePlist = mergePlist;
			_currentPlist = currentPlist;
		}
		
		
		override public function start( completeCallback:Function = null, failureCallback:Function = null ):void
		{
			super.start( completeCallback, failureCallback );
			
			if (!_mergePlist.exists || !_currentPlist.exists)
			{
				failure( "Plist file doesn't exist" );
				return;
			}
			
			try
			{
				// Insert configuration parameters into merge plist
				// Note: currentPlist should already have parameters
				var mergeContent:String = FileUtils.readFileContentAsString( _mergePlist );
				for each (var param:ProjectParameter in APM.config.projectDefinition.getConfiguration( APM.config.buildType ))
				{
					var regex:RegExp = new RegExp( "\\$\\{" + param.name + "\\}", "g" );
					mergeContent = mergeContent.replace( regex, param.value );
				}
				
				mergeContent = mergeContent.replace( /\$\{applicationId\}/g, APM.config.projectDefinition.applicationId );
				
				// Load and merge plists
				var merge:Plist = new Plist( mergeContent );
				var current:Plist = new Plist().load( _currentPlist );
				
				var result:Plist = PlistUtils.merge( current, merge );
	
				result.saveAsync( _currentPlist, complete );
			}
			catch (e:Error)
			{
				failure( e.message );
			}
			
		}
		
		
	}
	
}
