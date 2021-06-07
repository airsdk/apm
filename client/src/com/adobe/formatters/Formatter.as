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

import mx.managers.ISystemManager;
import mx.managers.SystemManager;
import mx.resources.ResourceBundle;

/**
 *  The Formatter class is the base class for all data formatters.
 *  Any subclass of Formatter must override the <code>format()</code> method.
 *
 *  @mxml
 *
 *  <p>The Formatter class defines the following tag attributes,
 *  which all of its subclasses inherit:</p>
 *  
 *  <pre>
 *  &lt;mx:<i>tagname</i>
 *    <b>Properties</b>
 *    error=""
 *  /&gt;
 *  </pre>
 *  
 *  @includeExample examples/SimpleFormatterExample.mxml
 */
public class Formatter
{
	//--------------------------------------------------------------------------
	//
	//  Class resources
	//
	//--------------------------------------------------------------------------

    /**
     *  A ResourceBundle object containing all symbols
	 *  from <code>formatters.properties</code>.
     */
	protected static var packageResources:ResourceBundle;
	    
	//--------------------------------------------------------------------------
	//
	//  Class properties
	//
	//--------------------------------------------------------------------------

	/**
	 *  Error message for an invalid value specified to the formatter. 
	 *
	 *  @default "Invalid value"
	 */
	protected var defaultInvalidValueError:String = "Invalid value";
	
	/**
	 *  Error message for an invalid format string specified to the formatter. 
	 *
	 *  @default "Invalid format"
	 */
	protected var defaultInvalidFormatError:String = "Invalid format";
	
	//--------------------------------------------------------------------------
	//
	//  Constructor
	//
	//--------------------------------------------------------------------------

	/**
	 *  Constructor.
	 */
	public function Formatter()
	{
		super();
	}

	//--------------------------------------------------------------------------
	//
	//  Properties
	//
	//--------------------------------------------------------------------------

	//----------------------------------
	//  error
	//----------------------------------

    [Inspectable(category="General", defaultValue="null")]

	/**
	 *  Description saved by the formatter when an error occurs.
	 *  For the possible values of this property,
	 *  see the description of each formatter.
	 *  <p>Subclasses must set this value
	 *  in the <code>format()</code> method.</p>
	 */
	public var error:String;

	//--------------------------------------------------------------------------
	//
	//  Methods
	//
	//--------------------------------------------------------------------------

	/**
	 *  Formats a value and returns a String
	 *  containing the new, formatted, value.
	 *  All subclasses must override this method to implement the formatter.
	 *
	 *  @param value Value to be formatted.
	 *
	 *  @return The formatted string.
	 */
	public function format(value:Object):String
	{
		error = "This format function is abstract. " +
			    "Subclasses must override it.";

	    return "";
	}
}

}
