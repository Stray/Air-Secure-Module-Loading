/* AS3
	Copyright 2009 Newloop. Please re-use, redistribute, recycle, remix and republish freely.  
*/
package com.newloop.air.moduleloading {
	
	
	import flash.display.MovieClip;
	
	/**
	 *	Example interface for the testable module
	 *
	 *	@langversion ActionScript 3.0
	 *	@playerversion Flash 9.0
	 *
	 *	@author Lindsey Fallow
	 *	@since  16.09.2009
	 */
	public interface ITestableModule {
		
		//--------------------------------------
		//  PUBLIC METHODS
		//--------------------------------------
		
		// allows testing of access to library assets
		function createTestMC():MovieClip;
		
		// allows testing of security sensitive actions such as file and folder read / write operations
		function attemptToAccessFileSystem():String;
		
		//--------------------------------------
		//  GETTER/SETTERS
		//--------------------------------------
		
	}
	
}
