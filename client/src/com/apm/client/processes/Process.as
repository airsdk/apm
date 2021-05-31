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
 * @created		28/5/21
 */
package com.apm.client.processes
{
	import flash.events.IEventDispatcher;
	
	
	public interface Process extends IEventDispatcher
	{
		////////////////////////////////////////////////////////
		//  FUNCTIONALITY
		//
		
		function start():void;
		
		
	}
	
}
