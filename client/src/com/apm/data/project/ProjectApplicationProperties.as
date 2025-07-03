/**
 * @author 		Michael Archbold (https://michaelarchbold.com)
 * @created		20/2/2023
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
