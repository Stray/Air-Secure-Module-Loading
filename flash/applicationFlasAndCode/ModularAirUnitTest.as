/* AS3
	Copyright 2009 Newloop. Please re-use, redistribute, recycle, remix and republish freely.
*/
package {

	import fl.controls.TextArea;
	import fl.controls.ComboBox;
	import fl.data.DataProvider;
	
	import flash.display.MovieClip;
	
	import flash.events.Event;
	import flash.events.ErrorEvent;
	
	import flash.filesystem.File;
	import flash.net.FileFilter;
	
	import com.newloop.air.moduleloading.ITestableModule;
	import com.newloop.air.moduleloading.ModuleInstaller;
	import com.newloop.air.moduleloading.ModuleLoader;
	import com.newloop.air.moduleloading.ModuleDescription;
	import com.newloop.air.moduleloading.ModuleDescriptionIterator;
	import com.newloop.air.moduleloading.ModuleDictionary;
	import com.newloop.air.moduleloading.ModuleXMLLoader;
	import com.newloop.air.moduleloading.events.ModuleEvent;
	import com.newloop.air.moduleloading.ModuleChainLoader;
	import com.newloop.air.events.AirUpdateManagerEvent;
	
	import com.newloop.util.events.DebugEvent;
	
	/**
	 *	Proof of concept for Modular loading using signature verfication.
	 *	This is the FLA class. Requires ComboBox and TextArea components.
	 *	Uses a TextArea to output progress.
	 *
	 *	@langversion ActionScript 3.0
	 *	@playerversion Flash 9.0
	 *
	 *	@author Lindsey Fallow
	 *	@since  02.09.2009
	 */
	public class ModularAirUnitTest extends MovieClip {
		
		//--------------------------------------
		// CLASS CONSTANTS
		//--------------------------------------
		
		//--------------------------------------
		//  CONSTRUCTOR
		//--------------------------------------
		
		/**
		 *	@Constructor
		 */
		public function ModularAirUnitTest(){
			trace("initialising: ModularAirUnitTest ");
			this.runTests();
		}
		
		//--------------------------------------
		//  PRIVATE VARIABLES
		//--------------------------------------
		
		private var testOutputField:TextArea;
		
		private var moduleDescriptionIterator:ModuleDescriptionIterator;
		
		//--------------------------------------
		//  GETTER/SETTERS
		//--------------------------------------
		
		//--------------------------------------
		//  PUBLIC METHODS
		//--------------------------------------

		//--------------------------------------
		//  EVENT HANDLERS
		//--------------------------------------
				
		
		// if you don't want to report debug events then deregister from listening for them
		
		private function debugEventHandler(e:DebugEvent):void{
			var debugMessage:String = e.message;
			this.updateTextOutput("Debug Message: " + debugMessage);
		}
		
		
		// reports to screen what's happening - events come from the moduleChainLoader
		private function moduleProgressUpdateHandler(e:ModuleEvent):void{
			
			var progressMessage:String = e.message;
			
			this.updateTextOutput(progressMessage);
			
		}
		
		// xml has been loaded and parsed - now send it to the loader
		private function moduleXMLLoadedHandler(e:Event):void{
			this.updateTextOutput("Module specification loaded.");
			this.updateTextOutput("Loading modules:");
			
			var moduleXMLLoader:ModuleXMLLoader = e.target as ModuleXMLLoader;
			
			var moduleDescriptionVector:Vector.<ModuleDescription> = moduleXMLLoader.getModuleDescriptionVector();
			
			this.loadModules(moduleDescriptionVector)
		}
		
		// loading has finished - now run some tests on the loaded modules
		private function moduleLoadingCompleteHandler(e:ModuleEvent):void{
			//
			var moduleChainLoader:ModuleChainLoader = e.target as ModuleChainLoader;
			  
			var moduleDictionary:ModuleDictionary = moduleChainLoader.getModuleDictionary();
			
			this.createModuleTestInterface(moduleDictionary);
		   
		}
		
		// handles selection of loaded modules in the test combo
		private function moduleComboChangeHandler(e:Event):void{
			
		    var comboBox:ComboBox = e.target as ComboBox;
			var dataObj:Object = comboBox.selectedItem;
			var moduleName:String = dataObj.label;
			var moduleContent:Object = dataObj.data;
			
			this.testModule(moduleName, moduleContent);
			
		}
		
		
		// browse handler for picking up the initial xml file
		private function browseForFileHandler(event:Event) :void{
			var xmlFile:File = new File(File(event.target).nativePath);
			this.loadModuleXMLData(xmlFile.url);
		};
		
		//--------------------------------------
		//  PRIVATE & PROTECTED INSTANCE METHODS
		//--------------------------------------
        
		// initial function run on startup
		
		private function runTests():void{
			
			this.createTestOutputField();
			
			this.browseForFile();
			
		}
		
		
		// offers the user a browse window - find the xml file where your moduleData is stored
		private function browseForFile():void{
			var xmlFilter:FileFilter = new FileFilter("xml files", "*.xml");
			
			var browseFile:File = new File();
			browseFile.addEventListener(Event.SELECT, this.browseForFileHandler);
			browseFile.browse([xmlFilter]);
		}
		
		// load that moduleData xml
		private function loadModuleXMLData(filePath:String):void{
			
			var moduleXMLLoader:ModuleXMLLoader = new ModuleXMLLoader();
			
			moduleXMLLoader.addEventListener(Event.COMPLETE, this.moduleXMLLoadedHandler);
			
			moduleXMLLoader.loadData(filePath);
			
		}
		
		// run the actual module loader
		private function loadModules(moduleDescriptionVector:Vector.<ModuleDescription>):void{
            
			this.moduleDescriptionIterator = new ModuleDescriptionIterator(moduleDescriptionVector);
			
			var moduleChainLoader:ModuleChainLoader = new ModuleChainLoader(this.moduleDescriptionIterator);
			
			moduleChainLoader.addEventListener(ModuleEvent.MODULE_PROGRESS_UPDATE, this.moduleProgressUpdateHandler);
			moduleChainLoader.addEventListener(ModuleEvent.MODULE_LOADING_COMPLETE, this.moduleLoadingCompleteHandler);
			// once the application is developed you'd want to stop listening for these events
			moduleChainLoader.addEventListener(DebugEvent.DEBUG_MESSAGE, this.debugEventHandler);
			
			moduleChainLoader.startLoadingModules();
		}
		
		// creates a text area where we can see what's happening
		private function createTestOutputField():void{
			// only required if you work with automatically declare stage instances unticked (AS3 prefs in publish settings)
			// otherwise just put a TA on the stage called "testOutputField" and don't run this function
			this.testOutputField = new TextArea();
			this.testOutputField.x = 25;
			this.testOutputField.y = 60;
			this.testOutputField.width = 450;
			this.testOutputField.height = 300;
			this.addChild(this.testOutputField);
		}
		
		// puts a ComboBox on stage to hold the modules so we can run tests on them
		private function createModuleTestInterface(moduleDictionary:ModuleDictionary):void{
			
			var moduleKeysVector:Vector.<String> = moduleDictionary.keysVector;
			
			var loadedModulesStr:String = moduleKeysVector.toString();
			
			this.updateTextOutput("LOADED MODULES: " + loadedModulesStr);
			
			var moduleCombo:ComboBox = new ComboBox();
			moduleCombo.x = 600;
			moduleCombo.y = 50;
			moduleCombo.width = 150;
			
			var dpArray:Array = [];
			
			var iLength:uint = moduleKeysVector.length;
			for (var i:uint = 0; i<iLength; i++){
				var nextModuleName = moduleKeysVector[i];
				var o:Object = {};
				o.label = nextModuleName;
				
				var nextModule:ITestableModule = moduleDictionary.getModule(nextModuleName);
				
				if(nextModule != null){
					o.data = nextModule;
				} else {
					o.data = moduleDictionary.getSandboxedModule(nextModuleName);
				}
				
				dpArray.push(o);
			}
			
			var dp:DataProvider = new DataProvider(dpArray);
			
			moduleCombo.dataProvider = dp;
			
			moduleCombo.addEventListener(Event.CHANGE, this.moduleComboChangeHandler);
			
			this.addChild(moduleCombo);
			
			
		}
		
		/* runs two tests on the selected module:
		  1: Attempts to load library assets passed from a function
		  2: Attempts to create a directory on the user's desktop
		  Test 1 should pass on all loaded modules - you should see the library element on the stage
		  Test 2 should pass on the securely loaded modules, and fail on modules outside the application sandbox
		*/
		private function testModule(moduleName:String, moduleContent:Object):void{
			
			this.updateTextOutput("SELECTED MODULE: " + moduleName + " -> " + moduleContent.toString());
			
			if(moduleContent is ITestableModule){
				this.updateTextOutput("ATTACHING MC FROM: " + moduleName);
				var testableModule:ITestableModule = moduleContent as ITestableModule;
				var testMC:MovieClip = testableModule.createTestMC();
				testMC.x = 650;
				testMC.y = 200;
				this.addChild(testMC);
				
			} else {
				try {
					this.updateTextOutput("ATTACHING SERIALISED MC FROM: " + moduleName);
					var serialisedMC:MovieClip = moduleContent["createTestMC"]() as MovieClip;
					serialisedMC.x = 650;
					serialisedMC.y = 200;
					this.addChild(serialisedMC);
					
				} catch (e:Error){
					this.updateTextOutput("ERROR: " + e.message + " -> " + "While attempting to run 'createTestMC' on " + moduleName);
				}
			}
			
			
			try{
				var directoryPath:String = moduleContent["attemptToAccessFileSystem"]();
				this.updateTextOutput("Wrote directory from: " + moduleName + " -> " + directoryPath); 
			} catch(e:Error){
				// this error SHOULD be thrown in the case of non secure modules... it shows that the unsafe content cannot access the filesystem
				this.updateTextOutput("ERROR: " + e.message + " -> " + "While attempting to create directory from " + moduleName);
			}
		}
		
		
		// utility function that updates the text window from the top.
		private function updateTextOutput(msg:String):void{
			
			this.testOutputField.text = msg + "\n" + this.testOutputField.text;
			
			
		}
		
		

		//--------------------------------------
		//  UNIT TESTS
		//--------------------------------------
		
		
		
	}
	
}
