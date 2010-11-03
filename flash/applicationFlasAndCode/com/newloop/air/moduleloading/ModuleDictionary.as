/* AS3
	Copyright 2009 Newloop but feel free to reuse, remix, recycle, reversion and redistribute.
*/
package com.newloop.air.moduleloading {
	
	import flash.display.MovieClip;
	
	
	/**
	 *	Strongly typed 2 dimensional dictionary for modules.
	 *
	 *	@langversion ActionScript 3.0
	 *	@playerversion Flash 9.0
	 *
	 *	@author Lindsey Fallow
	 *	@since  15.09.2009
	 */
	public class ModuleDictionary extends Object {
		
		//--------------------------------------
		// CLASS CONSTANTS
		//--------------------------------------
		
		//--------------------------------------
		//  CONSTRUCTOR
		//--------------------------------------
		
		/**
		 *	@Constructor
		 */
		public function ModuleDictionary(){
			this.moduleKeysVector = new Vector.<String>();
			this.moduleVector = new Vector.<ITestableModule>();
			this.moduleSwfsVector = new Vector.<MovieClip>();

		}
		
		//--------------------------------------
		//  PRIVATE VARIABLES
		//--------------------------------------
		
		// strongly typed array to hold unique strings which relate to unique modules
		private var moduleKeysVector:Vector.<String>;
		// It's likely you would implement a base class or interface for your modules rather than MovieClip, we've used ITestableModule as an example
		private var moduleVector:Vector.<ITestableModule>;
		// these are sandboxed modules
		private var moduleSwfsVector:Vector.<MovieClip>;
		
		//--------------------------------------
		//  GETTER/SETTERS
		//--------------------------------------
		
		//--------------------------------------
		//  PUBLIC METHODS
		//--------------------------------------
        
		/**
		 *	Adds a secure module under the key given.
		 *	
		 *	@param moduleKey The unique identifier for this module.
		 *	@param moduleSwf The loaded swf, which must be a verfied instance of ITestableModule
		 */
		public function addModule(moduleKey:String, moduleSwf:ITestableModule):void{
			this.moduleKeysVector[this.moduleKeysVector.length] = moduleKey;
			this.moduleVector[this.moduleVector.length] = moduleSwf;
			this.moduleSwfsVector[this.moduleSwfsVector.length] = null;
		}
		
		/**
		 *	Adds an insecure module under the key given.
		 *	
		 *	@param moduleKey The unique identifier for this module.
		 *	@param moduleSwf The loaded swf.
		 */
		public function addSandboxedModule(moduleKey:String, moduleSwf:MovieClip):void{
			this.moduleKeysVector[this.moduleKeysVector.length] = moduleKey;
			this.moduleVector[this.moduleVector.length] = null;
			this.moduleSwfsVector[this.moduleSwfsVector.length] = moduleSwf;
		}
		
		/**
		 *	Gets a secure module using the key given.
		 *	
		 *	@param moduleKey The unique identifier for this module.
		 *	
		 *	@return The required swf, which must be a verfied instance of ITestableModule.
		 */
		public function getModule(moduleKey:String):ITestableModule{
			var moduleKeyPosition:int = this.moduleKeysVector.indexOf(moduleKey);
			
			if(moduleKeyPosition == -1){
				return null;
			}
			
			return this.moduleVector[moduleKeyPosition];
		} 
		
		/**
		 *	Gets an insecure module using the key given.
		 *	
		 *	@param moduleKey The unique identifier for this module.
		 *	
		 *	@return The required swf, which is a vanilla movieclip.
		 */
		public function getSandboxedModule(moduleKey:String):MovieClip{
			var moduleKeyPosition:int = this.moduleKeysVector.indexOf(moduleKey);
			
			if(moduleKeyPosition == -1){
				return null;
			}
			
			return this.moduleSwfsVector[moduleKeyPosition];
		}
		
		/**
		 *	Gets the vector of the module unique identifiers.
		 *	
		 *	@return A vector of the module unique identifiers.
		 */
		public function get keysVector():Vector.<String>{
			return this.moduleKeysVector; 
		}

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
