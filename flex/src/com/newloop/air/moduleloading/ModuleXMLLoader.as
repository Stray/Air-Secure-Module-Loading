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
*/package com.newloop.air.moduleloading {
	
	import com.newloop.util.events.DebugEvent;
	
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.net.URLRequestMethod;
	import flash.net.URLVariables;
	
	/**
	 * 	ModuleXMLLoader handles loading of the moduleData file and turns the 
	 * xml into ModuleDescription objects in a strongly typed iterator.
	 *
	 * 	@langversion ActionScript 3.0
	 *	@playerversion Flash 9.0
	 *
	 *	@author Lindsey Fallow
	 * 	@since  15.09.2009
	 */	
	public class ModuleXMLLoader extends EventDispatcher {
		
		//--------------------------------------
		// CLASS CONSTANTS
		//--------------------------------------
		private static const __file_name__:String = "ModuleXMLLoader.as";
		//--------------------------------------
		//  CONSTRUCTOR
		//--------------------------------------
		
		/**
		 *	@constructor
		 */
		public function ModuleXMLLoader(){
			super();
		}
		
		//--------------------------------------
		//  PRIVATE VARIABLES
		//--------------------------------------
		
		// vector to hold the moduleDescriptions
		
		private var moduleDescriptionVector:Vector.<ModuleDescription>;
		
		//--------------------------------------
		//  GETTER/SETTERS
		//--------------------------------------
		
		//--------------------------------------
		//  PUBLIC METHODS
		//--------------------------------------
        
		public function loadData(dataPath:String, useCacheKillerFlag:Boolean = true, urlVars:URLVariables = null, isGet:Boolean = false):void {
			var urlRequest:URLRequest = new URLRequest(dataPath);
			if(isGet){
				urlRequest.method = URLRequestMethod.GET;
			} else {
				urlRequest.method = URLRequestMethod.POST;
			}
			if(urlVars == null){
				urlVars = new URLVariables();
			}
			
			if (useCacheKillerFlag) {
				urlVars.cacheKiller = Math.floor(Math.random() * 100000);
			}
			
			urlRequest.data = urlVars;
			
			//
			var myLoader:URLLoader = new URLLoader();
			myLoader.load(urlRequest);
			myLoader.addEventListener(Event.COMPLETE,completeHandler);
		}
		//
		
		public function getModuleDescriptionVector():Vector.<ModuleDescription>{
			return this.moduleDescriptionVector;
		}

		//--------------------------------------
		//  EVENT HANDLERS
		//--------------------------------------
		
		private function completeHandler(event:Event):void {
			var loader:URLLoader = URLLoader(event.target);
			
			var moduleXML:XML = new XML(loader.data);
			this.createXMLData(moduleXML);
		}
		
		//--------------------------------------
		//  PRIVATE & PROTECTED INSTANCE METHODS
		//--------------------------------------
		
		/* Data structure of moduleXML expected: 
		
		<moduleConfig>
			<moduleData>
				<moduleIdentifier_txt>GoodModuleA</moduleIdentifier_txt>
				<moduleName_txt>Good Module A</moduleName_txt>
				<moduleLocalPath_fp>GoodModuleAPackage/GoodModuleA.swf</moduleLocalPath_fp>
				<moduleResourcePath_fp><![CDATA[http://my.web.com/mypackage.zip]]></moduleResourcePath_fp>
				<isLoadToApplication_boo>1</isLoadToApplication_boo>
			</moduleData>
			
			// repeated moduleData items
		*/
		
		private function createXMLData(moduleXML:XML):void{
			
		    this.moduleDescriptionVector = new Vector.<ModuleDescription>();
			
			var modulesXMLList:XMLList = moduleXML.moduleData;
			
			for each (var nextModuleXML:XML in modulesXMLList){
				
				// create a new module description
				var moduleIdentifier:String = nextModuleXML.moduleIdentifier_txt;
				var moduleName:String = nextModuleXML.moduleName_txt;
				var moduleLocalPath:String = nextModuleXML.moduleLocalPath_fp;
				var moduleResourcePath:String = nextModuleXML.moduleResourcePath_fp;
				var isLoadToApplication:Boolean = /*false*/ true; // in Flex, cannot find a way to load into remote security sandbox
				var isForceInstall:Boolean = false; 
				
				if(nextModuleXML.isLoadToApplication_boo == 1){
					isLoadToApplication = true;
				}
				isForceInstall = (nextModuleXML.hasOwnProperty("isForceInstall")&&(nextModuleXML.isForceInstall));
				
				var nextModuleDescription:ModuleDescription = 
					new ModuleDescription(	moduleIdentifier, 
											moduleName, 
											moduleLocalPath, 
											moduleResourcePath, 
											isLoadToApplication,
											isForceInstall);
				
				this.moduleDescriptionVector[this.moduleDescriptionVector.length] = nextModuleDescription;
				
			}
			
			// we're done
			var e:Event = new Event(Event.COMPLETE);
			
			this.dispatchEvent(e);
			
		}
		
	}
	
}
