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
	
	import flash.display.MovieClip;
	
	import mx.modules.Module;
	
	
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
			this.moduleSwfsVector = new Vector.<Module>();

		}
		
		//--------------------------------------
		//  PRIVATE VARIABLES
		//--------------------------------------
		
		// strongly typed array to hold unique strings which relate to unique modules
		private var moduleKeysVector:Vector.<String>;
		// It's likely you would implement a base class or interface for your modules rather than MovieClip, we've used ITestableModule as an example
		private var moduleVector:Vector.<ITestableModule>;
		// these are sandboxed modules
		private var moduleSwfsVector:Vector.<Module>;
		
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
		public function addSandboxedModule(moduleKey:String, moduleSwf:Module):void{
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
		public function getSandboxedModule(moduleKey:String):Module{
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
