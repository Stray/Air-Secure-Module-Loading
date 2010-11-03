/* AS3
	Copyright 2009 Newloop.
*/
package com.newloop.air.moduleloading {
	
	import flash.display.Loader;
	import flash.events.Event;
	import flash.events.ErrorEvent;
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	
	import com.newloop.util.events.DebugEvent;
	/**
	 * 	EventDispatcher subclass description.
	 *
	 * 	@langversion ActionScript 3.0
	 *	@playerversion Flash 9.0
	 *
	 *	@author Lindsey Fallow
	 * 	@since  02.09.2009
	 */	
	public class ModuleLoader extends EventDispatcher {
		
		//--------------------------------------
		// CLASS CONSTANTS
		//--------------------------------------
		
		public static const MODULE_FAILED:String = "moduleFailed";
		public static const MODULE_PASSED:String = "modulePassed";		
		public static const MODULE_LOADED:String = "moduleLoaded";
		public static const MODULE_LOADING_ERROR:String = "moduleLoadingError";
		
		public const ERROR_MESSAGE_NO_PACKAGE:String = "You can only load a module into the application sandbox if it is inside a verified package.";
		public const ERROR_MESSAGE_NOT_FOUND:String = "The module you're trying to load cannot be found.";
		
		//--------------------------------------
		//  CONSTRUCTOR
		//--------------------------------------
		
		/**
		 *	@constructor
		 */
		public function ModuleLoader(){
			super();
		}
		
		//--------------------------------------
		//  PRIVATE VARIABLES
		//--------------------------------------
		
		private var moduleFile:File;
		
		private var loadedSwf:*;
		
		private var modulePackageName:String;
		
		private var packageChecker:PackageSignatureCheck;
		
		//--------------------------------------
		//  GETTER/SETTERS
		//--------------------------------------
		
		public function getLoadedModule():*{
			return this.loadedSwf;
		}
		
		//--------------------------------------
		//  PUBLIC METHODS
		//--------------------------------------
        
		public function loadModule(moduleFilePath:String, isLoadIntoApplicationSandbox:Boolean = false):void{
			
			// reset stored data incase this isn't the first request
			this.loadedSwf = null;
			this.moduleFile = null;
			
			var moduleFileNameParts:Array = moduleFilePath.split("/");
			
			if((moduleFileNameParts.length != 2) && isLoadIntoApplicationSandbox){
				// you can only load a module using loadBytes if it's in a parent package
				this.throwError(this.ERROR_MESSAGE_NO_PACKAGE);
			}
			
			if(moduleFileNameParts.length == 2){
				this.modulePackageName = moduleFileNameParts[0];
				var moduleFileName:String = moduleFileNameParts[1];

			}
			
			
			// now verify that the file exists
			try{
				var moduleFile:File = File.applicationStorageDirectory.resolvePath(moduleFilePath);
			} catch (e:Error) {
				//
				this.throwError(this.ERROR_MESSAGE_NOT_FOUND);
				return;
			}
			
			this.moduleFile = moduleFile;
			
			if(isLoadIntoApplicationSandbox) {
			    
				if(this.packageChecker == null){
			
					this.packageChecker = new PackageSignatureCheck();
					// add some event listeners
					this.packageChecker.addEventListener(PackageSignatureCheck.PACKAGE_SIGNATURE_PASSED, this.signatureCheckPassedHandler);
					this.packageChecker.addEventListener(PackageSignatureCheck.PACKAGE_SIGNATURE_FAILED, this.signatureCheckFailedHandler);
					this.packageChecker.addEventListener(PackageSignatureCheck.PACKAGE_SIGNATURE_ERROR, this.signatureCheckErrorHandler);
					this.packageChecker.addEventListener(PackageSignatureCheck.READY, this.signatureCheckerReadyHandler);
					this.packageChecker.addEventListener(DebugEvent.DEBUG_MESSAGE, this.debugEventHandler); 
					
					this.packageChecker.initialise();
				                                    
				} 
				// process your file - must be in the application storage directory  
				this.dispatchDebugEvent("ModuleLoader: starting validation");
                
				

			} else {
				this.loadFileWithoutVerification();
			}
			
			
		}

		//--------------------------------------
		//  EVENT HANDLERS
		//--------------------------------------
		
		private function signatureCheckErrorHandler(e:ErrorEvent):void{
			this.dispatchEvent(new ErrorEvent(ModuleLoader.MODULE_LOADING_ERROR, false, false, e.text));
		}
		
		private function signatureCheckFailedHandler(e:Event):void{
			this.dispatchEvent(new Event(ModuleLoader.MODULE_FAILED));
		}
		
		private function signatureCheckPassedHandler(e:Event):void{
			this.dispatchEvent(new Event(ModuleLoader.MODULE_PASSED)); 
			this.loadFileToApplicationSandbox();
		}
		
		private function signatureCheckerReadyHandler(e:Event):void{
			this.dispatchDebugEvent("Signature check ready for validation");
			var mySignatureChecker:PackageSignatureCheck = e.target as PackageSignatureCheck;
			mySignatureChecker.validate(this.modulePackageName);
		}
		
		private function debugEventHandler(e:DebugEvent):void{
			this.dispatchEvent(e);
		}
		                         
		
		//--------------------------------------
		//  PRIVATE & PROTECTED INSTANCE METHODS
		//--------------------------------------
		
		private function throwError(errorMsg:String):void{
			var err:Error = new Error(errorMsg);
			throw(err);
		}
		
		
		private function loadFileToApplicationSandbox():void {
		    trace("loadFileToApplicationSandbox");
			// Open the SWF file
		    var fileStream:FileStream = new FileStream();
			fileStream.open(this.moduleFile, FileMode.READ); 

			// Read SWF bytes into byte array and close file
			var bytes:ByteArray = new ByteArray();
			fileStream.readBytes(bytes);
		   	fileStream.close();
		
			var moduleLoader:Loader = new Loader();
			var context:LoaderContext = new LoaderContext();
			context.allowLoadBytesCodeExecution = true;
			context.applicationDomain = ApplicationDomain.currentDomain;    
		
			//bytes from local file (module file is stored in app storage)
			moduleLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, this.moduleLoadCompleteHandler);
			moduleLoader.loadBytes(bytes, context);
		
		}
	
		private function loadFileWithoutVerification():void{
			trace("loadFileWithoutVerification : " + this.moduleFile);
				
			var urlRequest:URLRequest=new URLRequest(this.moduleFile.url);
			//
			var moduleLoader:Loader = new Loader();
			//		
			moduleLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, this.moduleLoadCompleteHandler);
			//
			moduleLoader.load(urlRequest);
		}
	
		private function moduleLoadCompleteHandler(e:Event):void{
		
			var moduleLoader:Loader = e.target.loader as Loader;
		
			this.loadedSwf = moduleLoader.content;
		
			this.dispatchEvent(new Event(ModuleLoader.MODULE_LOADED));
		
		}
		
		private function dispatchDebugEvent(debugMessage:String):void{
			var e:DebugEvent = new DebugEvent(DebugEvent.DEBUG_MESSAGE, debugMessage);
			this.dispatchEvent(e);
		}                                       
		
	}
	
}
