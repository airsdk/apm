/**
 * @author 		Michael Archbold (https://michaelarchbold.com)
 * @created		30/9/2021
 */
package com.apm.remote.repository
{
	import flash.net.URLVariables;
	
	
	public class RepositoryQueryOptions
	{
		////////////////////////////////////////////////////////
		//  CONSTANTS
		//
		
		private static const TAG:String = "RepositoryQueryOptions";
		
		
		////////////////////////////////////////////////////////
		//  VARIABLES
		//
		
		
		private var _includePrerelease:Boolean = false;
		
		public function get includePrerelease():Boolean { return _includePrerelease; }
		public function set includePrerelease( value:Boolean ):void { _includePrerelease = value; }
		
		
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		public function RepositoryQueryOptions()
		{
		}
		
		
		public function setIncludePrerelease( includePrerelease:Boolean = true ):RepositoryQueryOptions
		{
			_includePrerelease = includePrerelease;
			return this;
		}
		
		
		public function toURLVariables():URLVariables
		{
			var vars:URLVariables = new URLVariables();
			apply( vars );
			return vars;
		}
		
		
		public function apply( variables:URLVariables ):URLVariables
		{
			variables["includePrerelease"] = includePrerelease;
			
			return variables;
		}
		
		
		//
		//
		//
		
		public static function fromParameters( parameters:Array ):RepositoryQueryOptions
		{
			var repoQueryOptions:RepositoryQueryOptions = null;
			if (parameters != null)
			{
				for (var i:int = parameters.length-1; i >= 0; --i)
				{
					var param:String = parameters[i];
					if (param == "--include-prerelease")
					{
						parameters.removeAt( i );
						if (repoQueryOptions == null) repoQueryOptions = new RepositoryQueryOptions();
						repoQueryOptions.setIncludePrerelease();
					}
				}
			}
			return repoQueryOptions;
		}
		
	}
}
