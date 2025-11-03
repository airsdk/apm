/**
 * @author Michael Archbold (https://michaelarchbold.com)
 * @created 3/11/2025
 */
package com.apm.client.io.utils
{
	public class ListOutput
	{


		public static function marker( isLast:Boolean = true ):String
		{
			return (isLast ? "└── " : "├── ");
		}



	}
}
