/**
 *        __       __               __
 *   ____/ /_ ____/ /______ _ ___  / /_
 *  / __  / / ___/ __/ ___/ / __ `/ __/
 * / /_/ / (__  ) / / /  / / /_/ / /
 * \__,_/_/____/_/ /_/  /_/\__, /_/
 *                           / /
 *                           \/
 * https://distriqt.com
 *
 * @author 		Michael Archbold (https://github.com/marchbold)
 * @created		20/2/2023
 * @copyright	distriqt 2023 (https://distriqt.com/copyright/license.txt)
 */
package com.apm.data.project
{
	public interface ProjectApplicationProperties
	{
		function get applicationId():String;
		function get applicationName():Object;
		function get applicationFilename():String;
        function get version():String;
        function get versionLabel():String;

	}

}
