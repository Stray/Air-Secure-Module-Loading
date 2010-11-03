/* AS3
	Copyright 2009 Newloop but feel free to reuse, remix, recycle, reversion and redistribute.
*/
package com.newloop.air.moduleloading {
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.events.ErrorEvent;
	
	import flash.display.MovieClip;
	                                          
	import com.newloop.air.moduleloading.events.ModuleEvent;
	import com.newloop.air.events.AirUpdateManagerEvent;
    
	import com.newloop.util.events.DebugEvent;
	
	/**
	 * Dispatched when all modules have completed loading (even if some failed) 
	 *
	 * @eventType com.newloop.air.moduleloading.events.ModuleEvent.MODULE_LOADING_COMPLETE
	 */
	[Event(name="moduleLoadingComplete", type="com.newloop.air.moduleloading.events.ModuleEvent")]
	
	/**
	 * Dispatched when there's progress to update the user about
	 *
	 * @eventType com.newloop.air.moduleloading.events.ModuleEvent.MODULE_PROGRESS_UPDATE
	 */
	[Event(name="moduleProgressUpdate", type="com.newloop.air.moduleloading.events.ModuleEvent")]
	
	/**
	 * Dispatched when there's a debug message to report to the developer.
	 * These debug messages are necessary because the signature check
	 *	will only run in the actual air application, not the test player,
	 *	so 'trace' commands don't work.
	 *
	 * @eventType com.newloop.util.events.DebugEvent.DEBUG_MESSAGE
	 */
	[Event(name="debugMessage", type="com.newloop.air.moduleloading.events.DEBUG_MESSAGE")]
	
	
	/**
	 * 	ModuleChainLoader accepts an iterator of ModuleDescriptions and then installs and loads the modules, with package sig verification
	 *	The process is basically: <b>more modules? install -> load</b>, where modules are loaded into the application sandbox if requested and
	 *	if they pass the security certificate check, and into the non-application sandbox if application loading isn't requested.
	 *	Modules requesting loading to the application sandbox and not passing the security check are not loaded at all.
	 *	
	 *
	 * 	@langversion ActionScript 3.0
	 *	@playerversion Flash 9.0
	 *
	 *	@author Lindsey Fallow
	 * 	@since  15.09.2009
	 */	
	public class ModuleChainLoader extends EventDispatcher {
		
		//--------------------------------------
		// CLASS CONSTANTS
		//--------------------------------------
		
		//--------------------------------------
		//  CONSTRUCTOR
		//--------------------------------------
		
		/**
		 *	@constructor
		 *	
		 *	@param moduleDescriptionIterator An iterator of the descriptions of modules to be loaded.
		 *	@param isErrorSilently Defaults true. If false, failed loading attempts will throw an error.
		 */
		public function ModuleChainLoader(moduleDescriptionIterator:ModuleDescriptionIterator, isErrorSilently:Boolean = true){
			super();
			this.moduleDescriptionIterator = moduleDescriptionIterator;
			this.isErrorSilently = isErrorSilently;
			this.moduleSwfDictionary = new ModuleDictionary();
			
		}
		
		//--------------------------------------
		//  PRIVATE VARIABLES
		//--------------------------------------
		
		// a strongly typed iterator of module descriptions
		private var moduleDescriptionIterator:ModuleDescriptionIterator;
		
		// the current module description (holds information about resource path, module name, whether to load to the application or non-app sandbox etc)
		private var currentModuleDescription:ModuleDescription;
		
		// a strongly typed (vector based) dictionary for storing and retrieving the loaded modules by id
		private var moduleSwfDictionary:ModuleDictionary;
		
		// the name of the current module (for user feedback about progress)
		private var moduleDisplayName:String;
		
		// whether to re-throw run time loading error or not
		private var isErrorSilently:Boolean;
		
  	
		//--------------------------------------
		//  PUBLIC METHODS
		//--------------------------------------
        
		/**
		 *	Begin the process of installing and loading modules
		 */
		public function startLoadingModules():void{
			this.installNextModule();
		}
		
		/**
		 *	Get the dictionary of loaded modules - will return null until the COMPLETE event has fired
		 */
		public function getModuleDictionary():ModuleDictionary{
			return this.moduleSwfDictionary;
		}

		//--------------------------------------
		//  EVENT HANDLERS
		//--------------------------------------
		
		
		/**
		 *	@private
		 *	
		 *	when the module has installed, report it and load the module 
		 */
		private function moduleInstalledHandler(e:Event):void{
			var msg:String = "Module Installed: " + this.moduleDisplayName;
			this.dispatchModuleEvent(msg);
			this.loadCurrentModule();
		}
		
		/**
		 *	@private
		 *	
		 *	when the module has been found locally, report it and load the module 
		 */
		private function moduleFoundHandler(e:Event):void{
		    var msg:String = "Module Found: " + this.moduleDisplayName;
			this.dispatchModuleEvent(msg);
			this.loadCurrentModule();
		}
		
		/**
		 *	@private
		 *	
		 *	when the module has not been found locally, and requires installation, report it 
		 */
		private function moduleNotFoundHandler(e:Event):void{
			var msg:String = ("Module not found: beginning installation of " + this.moduleDisplayName);
			this.dispatchModuleEvent(msg);
		}
		
		/**
		 *	@private
		 *	
		 *	when the module is downloading, and progress is made, report it 
		 */
		private function downloadProgressHandler(e:AirUpdateManagerEvent):void{
			var percentage:Number = e.detail as Number;
			var msg:String = "Module downloading: " + percentage + "%";
			this.dispatchModuleEvent(msg, percentage);
   		}
		
		/**
		 *	@private
		 *	
		 *	when the module is downloading, and there is an error, report it    
		 *	NOTE: You may wish to handle this event additionally if loading of all modules is critical and you're not checking what has loaded elsewhere
		 */
		private function downloadErrorHandler(e:AirUpdateManagerEvent):void{
			var errorMsg:String = e.detail as String;
			var msg:String = "Module installation error for : " + this.moduleDisplayName + " -> " + errorMsg;
			this.dispatchModuleEvent(msg);
		}
		
		/**
		 *	@private
		 *	
		 *	when the module is flagged to be loaded securely, and fails the security check, report it and install the next module 
		 */
		private function moduleLoadFailedHandler(e:Event):void{
			var msg:String = "The module " + this.moduleDisplayName + " failed certificate verification and cannot be loaded.";
			this.dispatchModuleEvent(msg);
			this.installNextModule();
		}
		
		/**
		 *	@private
		 *	
		 *	when the module is flagged to be loaded securely, and passes the security check, report it 
		 */
		private function moduleLoadPassedHandler(e:Event):void{
			var msg:String = "Module verified successfully: " + this.moduleDisplayName;
			this.dispatchModuleEvent(msg);
		}
		
		/**
		 *	@private
		 *	
		 *	when the module has loaded, report it and enter it in the dictionary either in the application or in the sandbox
		 *	we're assuming here that modules loaded into the application implement an interface
		 *	modules which load unsecurely (into the non-application sandbox) will not pass the 'is interface' test even if their base class did implement it 
		 */
		private function moduleLoadedHandler(e:Event):void{
			var msg:String = "Module loaded successfully: " + this.moduleDisplayName;
			this.dispatchModuleEvent(msg);
			
			var moduleLoader:ModuleLoader = e.target as ModuleLoader;
			
			var moduleSwf:MovieClip = moduleLoader.getLoadedModule() as MovieClip;
			
			// it's unlikely you'd want to report these additional messages about casting to the end user, hence they're dispatched as debug events
			
		  	if(moduleSwf is ITestableModule){
				this.dispatchDebugEvent("swf appears to be ITestableModule");
				var testableModule:ITestableModule = moduleSwf as ITestableModule;
				this.dispatchDebugEvent("Successfully cast swf to ITestableModule");
				this.moduleSwfDictionary.addModule(this.moduleDisplayName, testableModule);
			} else {
				this.dispatchDebugEvent("swf is not ITestableModule");
				this.moduleSwfDictionary.addSandboxedModule(this.moduleDisplayName, moduleSwf);
				
			} 
			
			// kick off the next install
			this.installNextModule();
		}
		
		/**
		 *	@private
		 *	
		 *	If there's an error loading the module, report it, then move on to the next module
		 */
		private function moduleLoadingErrorHandler(e:ErrorEvent):void{
			var msg:String = "Module loading error: " + e.text + this.moduleDisplayName;
			this.dispatchModuleEvent(msg);
			this.installNextModule();
		}
		
		/**
		 *	@private
		 *	
		 *	Handle and pass on debug messages
		 */
		private function debugEventHandler(e:DebugEvent):void{
			var debugMessage:String = e.message;
			var msg:String = "Debug Message: " + debugMessage;
			this.dispatchDebugEvent(msg);
		}

		//--------------------------------------
		//  PRIVATE & PROTECTED INSTANCE METHODS
		//--------------------------------------
		
		
		/**
		 *	@private
		 *	
		 *	Get the next ModuleDescription from the iterator (if there is one) and begin installing it
		 *	If there isn't another one to load then dispatch the complete event.
		 */
		private function installNextModule():void{
			
			if(this.moduleDescriptionIterator.hasNext()){
				this.currentModuleDescription = this.moduleDescriptionIterator.getNext();
				this.moduleDisplayName = this.currentModuleDescription.moduleDisplayName;
				this.installCurrentModule();
			} else {
				var e:ModuleEvent = new ModuleEvent(ModuleEvent.MODULE_LOADING_COMPLETE);
				this.dispatchEvent(e);
			}
			
		}
		
		/**
		 *	@private
		 *	
		 *	Install the current module (simply pass it to the ModuleInstaller which handles actual installation)
		 */
		private function installCurrentModule():void{
			
			// create the module installer
			var moduleInstaller:ModuleInstaller = new ModuleInstaller();
			
			// listen for events and error events - handlers for this would usually feedback to the user unless silent install is required
			moduleInstaller.addEventListener(ModuleInstaller.MODULE_INSTALLED, this.moduleInstalledHandler);
			moduleInstaller.addEventListener(ModuleInstaller.MODULE_FOUND, this.moduleFoundHandler);
			moduleInstaller.addEventListener(ModuleInstaller.MODULE_NOT_FOUND, this.moduleNotFoundHandler);
			moduleInstaller.addEventListener(AirUpdateManagerEvent.DOWNLOAD_PROGRESS, this.downloadProgressHandler);
			moduleInstaller.addEventListener(AirUpdateManagerEvent.DOWNLOAD_ERROR, this.downloadErrorHandler);
			
			// attempt to install a module: file path (From the application storage dir) and resource path (http:// remote path to find the source)
			var moduleInstallPath:String = this.currentModuleDescription.moduleInstallPath;
			var moduleResourcePath:String = this.currentModuleDescription.moduleResourcePath;
			
			moduleInstaller.installModule(moduleInstallPath, moduleResourcePath);
		
		}
		
		/**
		 *	@private
		 *	
		 *	Load the installed module (simply passing it to the ModuleLoader which handles actual loading)
		 */
		private function loadCurrentModule():void{
			// create the module loader
			var moduleLoader:ModuleLoader = new ModuleLoader();
			
			// listen for events and error events - handlers for this would usually feedback to the user unless silent loading is required
			moduleLoader.addEventListener(ModuleLoader.MODULE_FAILED, this.moduleLoadFailedHandler);
			moduleLoader.addEventListener(ModuleLoader.MODULE_PASSED, this.moduleLoadPassedHandler);
			moduleLoader.addEventListener(ModuleLoader.MODULE_LOADED, this.moduleLoadedHandler);
			moduleLoader.addEventListener(ModuleLoader.MODULE_LOADING_ERROR, this.moduleLoadingErrorHandler);
			moduleLoader.addEventListener(DebugEvent.DEBUG_MESSAGE, this.debugEventHandler);
			
			var moduleInstallPath:String = this.currentModuleDescription.moduleInstallPath;
			var isLoadToApplication:Boolean = this.currentModuleDescription.isLoadToApplication;
			
			try {
				moduleLoader.loadModule(moduleInstallPath, isLoadToApplication);
			} catch(e:Error){
				var msg:String = "ERROR: " + e.message;
				this.dispatchModuleEvent(msg);
				
				if(this.isErrorSilently){
					this.installNextModule();
				} else {
					throw(e);
				}
				
			}
		}
		
		/**
		 *	@private
		 *	
		 *	Dispatch update events to keep the user informed of what's happening
		 */
		private function dispatchModuleEvent(msg:String, percentage:Number = 0):void{
			var e:ModuleEvent = new ModuleEvent(ModuleEvent.MODULE_PROGRESS_UPDATE, msg, percentage);
			this.dispatchEvent(e);
		}
		
		/**
		 *	@private
		 *	
		 *	Dispatch debug events to keep the developer informed of what's happening
		 *	The package signature stuff can only work within the actual air application, and the DebugEvent is used
		 *	... in the absence of the ability to do "trace(msg)" stuff.
		 *	Normally this would be turned off before the software is released - eg comment out the 'this.dispatchEvent(e)' part.
		 */
		private function dispatchDebugEvent(msg:String):void{
			var e:DebugEvent = new DebugEvent(DebugEvent.DEBUG_MESSAGE, msg);
			this.dispatchEvent(e);
		}
	}
	
}
