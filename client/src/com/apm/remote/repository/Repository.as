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
 * @created		15/9/21
 */
package com.apm.remote.repository
{
	import com.apm.SemVer;
	import com.apm.data.packages.PackageDefinitionFile;
	
	import flash.events.IEventDispatcher;
	
	
	public interface Repository extends IEventDispatcher
	{
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		function get name():String;
		
		
		function setName( name:String ):Repository;
		
		
		function search( query:String, options:RepositoryQueryOptions = null, callback:Function = null ):void;
		
		
		function getPackage( identifier:String, options:RepositoryQueryOptions = null, callback:Function = null ):void;
		
		
		function getPackageVersion( identifier:String, version:SemVer, options:RepositoryQueryOptions = null, callback:Function = null ):void;
		
		
		function logEvent( event:String, identifier:String, version:String, callback:Function = null ):void;
		
		
		function setToken( token:String ):Repository;
		
		
		function publish( packageDef:PackageDefinitionFile, callback:Function = null ):void;
		
	}
	
}
