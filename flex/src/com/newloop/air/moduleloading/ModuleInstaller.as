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
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import com.newloop.air.AirResourceUpdateManager;
	import com.newloop.air.events.AirUpdateManagerEvent;
	
	/**
	 * 	ModuleInstaller checks for a file, and downloads and unpacks the required resources to the specified path if the file isn't found.
	 *
	 * 	@langversion ActionScript 3.0
	 *	@playerversion Flash 9.0
	 *
	 *	@author Lindsey Fallow
	 * 	@since  02.09.2009
	 */	
	public class ModuleInstaller extends EventDispatcher {
		
		//--------------------------------------
		// CLASS CONSTANTS
		//--------------------------------------
		
		
		public static const MODULE_FOUND:String = "moduleFound";
		public static const MODULE_NOT_FOUND:String = "moduleNotFound";
		public static const MODULE_DOWNLOADED:String = "moduleDownloaded";
		
		//--------------------------------------
		//  CONSTRUCTOR
		//--------------------------------------
		
		/**
		 *	@constructor
		 */
		public function ModuleInstaller(){
			trace("initialising: ModuleInstaller ");
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
        
		/**
		 *	Installs the required module.
		 *	
		 *	@param moduleFilePath Where the module should be found (within the application storage directory).
		 *	@param moduleResourcePath Where the resource pack (zip file) for the module can be found - usually a path to a network / web server.
		 */
		public function installModule(moduleFilePath:String, moduleResourcePath:String):void{
			
			var installFolder:String = "";
			
//			if(moduleResourcePath.indexOf(".zip")>0){
				//
				var pathBits:Array = moduleFilePath.split("/");
				installFolder = pathBits.shift() + "/";
				moduleFilePath = pathBits.join("/");
				
//			}
			
			// we're not making use of the AirResourceUpdateManager's ability to add 
			// messages using alert handlers, so the first param - the displayObjectContainer 
			// to add those to - is not required                     
			var updateManager:AirResourceUpdateManager = 
				new AirResourceUpdateManager(	null, 
												installFolder, 
												moduleFilePath, 
												"applicationStorageDirectory", 
												moduleResourcePath);
			
			updateManager.addEventListener(AirUpdateManagerEvent.DOWNLOAD_PROGRESS, this.updateProgressHandler);
			updateManager.addEventListener(AirUpdateManagerEvent.DOWNLOAD_ERROR, this.errorHandler);
			updateManager.addEventListener(AirUpdateManagerEvent.DOWNLOAD_COMPLETE, this.downloadCompleteHandler);

			if(updateManager.checkForFile(false,"")){
				// file already present
				this.dispatchEvent(new Event(ModuleInstaller.MODULE_FOUND));
				// 
			} else {
				updateManager.downloadFile();
				this.dispatchEvent(new Event(ModuleInstaller.MODULE_NOT_FOUND));
			}
		}

		//--------------------------------------
		//  EVENT HANDLERS
		//--------------------------------------
		
		/**
		 *	@private
		 */
		private function downloadCompleteHandler(e:AirUpdateManagerEvent):void{
		    this.dispatchEvent(new Event(ModuleInstaller.MODULE_DOWNLOADED));
		}
		/**
		 *	@private
		 */
		private function updateProgressHandler(e:AirUpdateManagerEvent):void{
			this.dispatchEvent(e);
		}
		/**
		 *	@private
		 */
		private function errorHandler(e:AirUpdateManagerEvent):void{
			this.dispatchEvent(e);
		}
		
		
		//--------------------------------------
		//  PRIVATE & PROTECTED INSTANCE METHODS
		//--------------------------------------
        
		//--------------------------------------
		//  UNIT TESTS
		//--------------------------------------
		
		
	}
	
}
