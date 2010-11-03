/* AS3
	Copyright 2009 Newloop.
*/
package {

	import flash.display.MovieClip;
	
	import flash.filesystem.File;
	
	import com.newloop.air.moduleloading.ITestableModule;
	/**
	 *	Class description.
	 *
	 *	@langversion ActionScript 3.0
	 *	@playerversion Flash 9.0
	 *
	 *	@author Lindsey Fallow
	 *	@since  16.09.2009
	 */
	public class GoodModuleB extends MovieClip implements ITestableModule {
		
		//--------------------------------------
		// CLASS CONSTANTS
		//--------------------------------------
		
		//--------------------------------------
		//  CONSTRUCTOR
		//--------------------------------------
		
		/**
		 *	@Constructor
		 */
		public function GoodModuleB(){
			trace("initialising: GoodModuleB ");
			super();
		}
		
		//--------------------------------------
		//  PRIVATE VARIABLES
		//--------------------------------------
		
		//--------------------------------------
		//  GETTER/SETTERS
		//--------------------------------------
		
		//--------------------------------------
		//  PUBLIC METHODS
		//--------------------------------------
        
		public function createTestMC():MovieClip{
			var testMC:MovieClip = new mc_goodModuleB();
			return testMC; 
		}
		
		public function attemptToAccessFileSystem():String{
			var newDirectory:File = File.desktopDirectory.resolvePath("GoodModuleB_Directory");
			newDirectory.createDirectory();
			return newDirectory.nativePath;
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
