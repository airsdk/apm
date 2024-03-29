////////////////////////////////////////////////////////////////////////////////
//
//  Copyright (C) 2003-2006 Adobe Macromedia Software LLC and its licensors.
//  All Rights Reserved. The following is Source Code and is subject to all
//  restrictions on such code as contained in the End User License Agreement
//  accompanying this product.
//
////////////////////////////////////////////////////////////////////////////////

package com.adobe.formatters
{
/**
 *  @private
 *  The StringFormatter class provides a mechanism for displaying
 *  and saving data in the specified format.
 *  The constructor accepts the format and an Array of tokens,
 *  and uses these values to create the data structures to support
 *  the formatting during data retrieval and saving. 
 *  
 *  <p>This class is used internally by other formatters,
 *  and is typically not used directly.</p>
 *  
 *  @see mx.formatters.DateFormatter
 */
public class StringFormatter
{
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 *  Constructor.
	 *
 	 *  @param format String that contains the desired format.
	 *
	 *  @param tokens String that contains the character tokens
	 *  within the specified format String that is replaced
	 *  during data formatting operations.
	 *
	 *  @param extractTokenFunc The token 
	 *  accessor method to call when formatting for display.
	 *  The method signature is
	 *  value: anything, tokenInfo: {token: identifier, begin: start, end: finish}.
	 *  This method must return a String representation of value
	 *  for the specified <code>tokenInfo</code>.
	 */
	public function StringFormatter( format:String, tokens:String,
									 extractTokenFunc:Function)
	{
		super();

		formatPattern(format, tokens);
		extractToken = extractTokenFunc;
	}

	//--------------------------------------------------------------------------
	//
	//  Variables
	//
	//--------------------------------------------------------------------------

	/**
	 *  @private
	 */
	private var extractToken:Function;

	/**
	 *  @private
	 */
	private var reqFormat:String;

	/**
	 *  @private
	 */
	private var patternInfo:Array;

	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------

	/**
	 *  Returns the formatted String using the format, tokens,
	 *  and extraction function passed to the constructor.
	 *
	 *  @param value String to be formatted.
	 *
	 *  @return Formatted String.
	 */
	public function formatValue(value:Object):String
	{
		var curTokenInfo:Object = patternInfo[0];
		
		var result:String = reqFormat.substring(0, curTokenInfo.begin) +
							extractToken(value, curTokenInfo);

		var lastTokenInfo:Object = curTokenInfo;
		
		var n:int = patternInfo.length;
		for (var i:int = 1; i < n; i++)
		{
			curTokenInfo = patternInfo[i];
			
			result += reqFormat.substring(lastTokenInfo.end,
										  curTokenInfo.begin) +
					  extractToken(value, curTokenInfo);
			
			lastTokenInfo = curTokenInfo;
		}
		if (lastTokenInfo.end > 0 && lastTokenInfo.end != reqFormat.length)
			result += reqFormat.substring(lastTokenInfo.end);
		
		return result;
	}
	
	/**
	 *  @private
	 *  Formats a user-defined pattern String into a more usable object.
	 *
	 *  @param format String that defines the user-requested pattern.
	 *
	 *  @param tokens List of valid patttern characters.
	 */
	private function formatPattern(format:String, tokens:String):void
	{
		var start:int = 0;
		var finish:int = 0;
		var index:int = 0;
		
		var tokenArray:Array = tokens.split(",");
		
		reqFormat = format;
		
		patternInfo = [];
		
		var n:int = tokenArray.length;
		for (var i:int = 0; i < n; i++)
		{
			start = reqFormat.indexOf(tokenArray[i]);
			if (start >= 0  && start < reqFormat.length)
			{
				finish = reqFormat.lastIndexOf(tokenArray[i]);
				finish = finish >= 0 ? finish + 1 : start + 1;
				patternInfo.splice(index, 0,
					{ token: tokenArray[i], begin: start, end: finish });
				index++;
			}
		}
		
		patternInfo.sort(compareValues);
	}

	/**
	 *  @private
	 */
	private function compareValues(a:Object, b:Object):int
	{
		if (a.begin > b.begin)
			return 1;
		else if (a.begin < b.begin)
			return -1;
		else
			return 0;
	} 
}

}
