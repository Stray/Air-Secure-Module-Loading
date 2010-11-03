/* AS3
	Copyright 2009 Newloop.
*/
package com.newloop.air.moduleloading {
	
	/**
	 *	Strongly typed property container for modules.
	 *
	 *	@langversion ActionScript 3.0
	 *	@playerversion Flash 9.0
	 *
	 *	@author Lindsey Fallow
	 *	@since  03.09.2009
	 */
	public class ModuleDescription extends Object {
		
		//--------------------------------------
		// CLASS CONSTANTS
		//--------------------------------------
		
		//--------------------------------------
		//  CONSTRUCTOR
		//--------------------------------------
		
		/**
		 *	@Constructor
		 */
		public function ModuleDescription(moduleIdentifier:String, moduleDisplayName:String, moduleInstallPath:String, moduleResourcePath:String, isLoadToApplication:Boolean = false){
			//trace("initialising: ModuleDescription -> ", moduleIdentifier, moduleDisplayName, moduleInstallPath, moduleResourcePath, isLoadToApplication);
			this._moduleIdentifier = moduleIdentifier;
		    this._moduleDisplayName = moduleDisplayName;
			this._moduleInstallPath = moduleInstallPath;
			this._moduleResourcePath = moduleResourcePath;
			this._isLoadToApplication = isLoadToApplication;
		}
		
		//--------------------------------------
		//  PRIVATE VARIABLES
		//--------------------------------------
		
		// the reference you'd like to use to to access the module once loaded
		private var _moduleIdentifier:String;
		
		// what is displayed to the user while it's loading
		private var _moduleDisplayName:String;
		
		// where the module should be installed (within appStorage)
		private var _moduleInstallPath:String;
		
		// where the zip file containing the module can be found
		private var _moduleResourcePath:String;
		
		// whether to load the module into the application sandbox
		private var _isLoadToApplication:Boolean;
		
		//--------------------------------------
		//  GETTER/SETTERS
		//--------------------------------------
		
		/**
		 *	The (upper and lower case only, no spaces) identifier you want to use within the software to refer uniquely to this module.
		 */
		public function get moduleIdentifier():String{
			return this._moduleIdentifier;
		}
		
		/**
		 *	What the module is called when loading updates are displayed to the user.
		 */
		public function get moduleDisplayName():String{
			return this._moduleDisplayName;
		}
		
		/**
		 *	Where the module is found (within app-storage).
		 */
		public function get moduleInstallPath():String{
			return this._moduleInstallPath;
		}
		
		/**
		 *	Where the .zip package containing the module is obtained - usually an http:// path to a server holding the files.
		 */
		public function get moduleResourcePath():String{
			return this._moduleResourcePath;
		}  
		
		/**
		 *	Whether this module should be loaded with application privileges or simply put into the non-application sandbox.
		 */
		public function get isLoadToApplication():Boolean{
			return this._isLoadToApplication;
		}
		//--------------------------------------
		//  PUBLIC METHODS
		//--------------------------------------

		//--------------------------------------
		//  EVENT HANDLERS
		//--------------------------------------
		
		//--------------------------------------
		//  PRIVATE & PROTECTED INSTANCE METHODS
		//--------------------------------------

		//--------------------------------------
		//  UNIT TESTS
		//--------------------------------------
		
	}
	
}
