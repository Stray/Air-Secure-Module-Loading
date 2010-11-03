/* 
Copyright (c) <2009> <Newloop>

Permission is hereby granted, free of charge, to any person
obtaining a copy of this software and associated documentation
files (the "Software"), to deal in the Software without
restriction, including without limitation the rights to use,
copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the
Software is furnished to do so, subject to the following
conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
OTHER DEALINGS IN THE SOFTWARE.
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
		public function ModuleDescription(	moduleIdentifier:String, 
											moduleDisplayName:String, 
											moduleInstallPath:String, 
											moduleResourcePath:String, 
											isLoadToApplication:Boolean = false,
											isForceInstall:Boolean = false){

			_moduleIdentifier 		= moduleIdentifier;
		    _moduleDisplayName 		= moduleDisplayName;
			_moduleInstallPath 		= moduleInstallPath;
			_moduleResourcePath 	= moduleResourcePath;
			_isLoadToApplication 	= isLoadToApplication;
			_isForceInstall			= isForceInstall;
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
		
		// whether to force the installation of the module regardless of its local presence
		private var _isForceInstall:Boolean;
		
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

		/**
		 *	Whether this module should be installed regardless of its presence in the app-storage folder
		 */
		public function get isForceInstall():Boolean{
			return _isForceInstall;
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
