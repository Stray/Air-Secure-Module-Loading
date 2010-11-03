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
	
	import com.newloop.util.events.DebugEvent;
	
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.events.ErrorEvent;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.filesystem.File;
	import flash.filesystem.FileMode;
	import flash.filesystem.FileStream;
	import flash.net.URLRequest;
	import flash.system.ApplicationDomain;
	import flash.system.LoaderContext;
	import flash.utils.ByteArray;
	
	import mx.core.IFlexModuleFactory;
	import mx.modules.Module;
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
		private static const __file_name__:String = "ModuleLoader.as";
		
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
			
			if((moduleFileNameParts.length != 2) /*&& isLoadIntoApplicationSandbox*/){
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
			// modules are always loaded into the app security sandbox AND must be signed		
//			if(isLoadIntoApplicationSandbox) {
			    
				if(this.packageChecker == null){
			
					this.packageChecker = new PackageSignatureCheck();
					// add some event listeners
					this.packageChecker.addEventListener(PackageSignatureCheck.PACKAGE_SIGNATURE_PASSED, this.signatureCheckPassedHandler);
					this.packageChecker.addEventListener(PackageSignatureCheck.PACKAGE_SIGNATURE_FAILED, this.signatureCheckFailedHandler);
					this.packageChecker.addEventListener(PackageSignatureCheck.PACKAGE_SIGNATURE_ERROR, this.signatureCheckErrorHandler);
					this.packageChecker.addEventListener(PackageSignatureCheck.READY, this.signatureCheckerReadyHandler);
					this.packageChecker.addEventListener(DebugEvent.DEBUG_MESSAGE, this.debugEventHandler); 
					dispatchDebugEvent("----- Locate Air app own certificate (one time event)");
					
					this.packageChecker.initialise();
				                                    
				} 

/*			} else {
				this.loadFileWithoutVerification();
			}
*/			
			
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
			dispatchDebugEvent("----- Air app own certificate found and loaded");
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
			dispatchDebugEvent("Loading certified module to app sandbox");
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
		
// Following functions have been removed:
// 1) Cannot load module in remote security sandbox in Air 1.5.2 as of OCt 29 2009
// 2) These modules haven't been checked against the certificate and cannot be trusted.		
/*
		private function loadFileWithoutVerification():void{
			dispatchDebugEvent("ModuleLoader: loadFile without verification: " + this.moduleFile);
			var urlRequest:URLRequest=new URLRequest(this.moduleFile.url);
			//
			var moduleLoader:Loader = new Loader();
			//		
			moduleLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, this.moduleLoadCompleteHandler);
			//
			moduleLoader.load(urlRequest);
		}
*/		
		private function moduleLoadCompleteHandler(e:Event):void{
			if(e.type=="progress") return;
		    var moduleLoader:LoaderInfo= LoaderInfo(e.target);
		    try	{
		    	moduleLoader.content.addEventListener("ready", readyHandler);
		    }
		    catch (e:Error)	{	
		    	this.throwError("Error");			
		    }
		}
		private function readyHandler(e:Event): void {
			var loaderInfo:LoaderInfo = e.target.loaderInfo;
		    try	{    
			    var factory:IFlexModuleFactory = IFlexModuleFactory(e.target);
			}
		    catch (err:Error){	
		    	this.dispatchDebugEvent("Impossible to load modules in the remote sandbox.");
		    	return;			
		    }
		    this.loadedSwf = factory.create() as Module;
			this.dispatchEvent(new Event(ModuleLoader.MODULE_LOADED));
		}
		
		private function dispatchDebugEvent(debugMessage:String):void{
			var e:DebugEvent = new DebugEvent(DebugEvent.DEBUG_MESSAGE,__file_name__, debugMessage);
			this.dispatchEvent(e);
		}                                       


// MANY UNSUCCESSFUL ATTEMPS TO LOAD A MODULE IN THE REMOTE SECURITY SANDBOX IN FLEX... Oct 2009, see
// http://www.nabble.com/Sandboxed-Modules-in-AIR-td21912046.html#a21912046
// http://blogs.adobe.com/aharui/2007/03/swf_is_not_a_loadable_module.html
// http://opensource.adobe.com/wiki/display/flexsdk/Marshall+Plan
// http://blogs.adobe.com/flexdoc/loadingSubApps.pdf

/*		
public var m_moduleInfo:IModuleInfo;

private function loadFileWithoutVerification2():void{
	var test:SWFLoader = new SWFLoader();
	test.addEventListener(Event.COMPLETE,moduleLoadCompleteHandler2);
	test.addEventListener(IOErrorEvent.IO_ERROR,moduleLoadCompleteHandler2);
	test.load(this.moduleFile.url);
	return;
	m_moduleInfo = ModuleManager.getModule(this.moduleFile.url);
	m_moduleInfo.addEventListener(ModuleEvent.READY, moduleLoadCompleteHandler);           
	m_moduleInfo.addEventListener(ModuleEvent.ERROR, moduleLoadCompleteHandler);           
	m_moduleInfo.addEventListener(ModuleEvent.PROGRESS, moduleLoadCompleteHandler);           
	m_moduleInfo.load(); 				
}
private function moduleLoadCompleteHandler2(e:Event):void{
    var factory:IFlexModuleFactory = IFlexModuleFactory(e.target.content);
    this.loadedSwf = factory.create() as Module;
}
	

private function loadFileWithoutVerification4():void{
	var loader:Loader = new Loader();
	loader.addEventListener(Event.COMPLETE, modLoadedHandler);
    loader.addEventListener(Event.INIT, modLoadedHandler);
    loader.addEventListener(IOErrorEvent.IO_ERROR, modLoadedHandler);
    loader.addEventListener(Event.OPEN, modLoadedHandler);
    loader.addEventListener(ProgressEvent.PROGRESS, modLoadedHandler);
    loader.addEventListener(Event.UNLOAD, modLoadedHandler);
    loader.load(new URLRequest(this.moduleFile.url));
}
protected function modLoadedHandler(e:Event):void{
	if (e.type!=Event.COMPLETE) return;
    var factory:IFlexModuleFactory = IFlexModuleFactory(e.target.content);
    this.loadedSwf = factory.create() as Module;
}

private function loadFileWithoutVerification3():void{
	var urlRequest:URLRequest = new URLRequest(this.moduleFile.url);
	var urlLoader:URLLoader = new URLLoader();
	urlLoader.dataFormat = URLLoaderDataFormat.BINARY;
	urlLoader.load(urlRequest);
	urlLoader.addEventListener(Event.COMPLETE, bytesLoadedHandler3);
}

protected function modReadyHandler3(event:ModuleEvent):void
{
	var o:Object = ModuleManager.getModule(this.moduleFile.url).factory.create();
	dispatchEvent(event.clone());
}

protected function bytesLoadedHandler3(event:Event):void
{
	var styleModuleBytes:ByteArray = ByteArray(URLLoader(event.target).data);
	var module:IModuleInfo = ModuleManager.getModule(this.moduleFile.url);
	module.addEventListener(ModuleEvent.PROGRESS, modReadyHandler3);
	module.addEventListener(ModuleEvent.ERROR, modReadyHandler3);
	module.addEventListener(ModuleEvent.READY, modReadyHandler3);
	module.load(null, null, styleModuleBytes);
}
*/
	}
	
}
