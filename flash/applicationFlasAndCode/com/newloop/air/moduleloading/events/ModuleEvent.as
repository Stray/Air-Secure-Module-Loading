/* AS3
	Copyright 2009 Newloop.
*/
package com.newloop.air.moduleloading.events {
	import flash.events.Event;
	
	/**
	 *	Event subclass description.
	 *
	 *	@langversion ActionScript 3.0
	 *	@playerversion Flash 9.0
	 *
	 *	@author Lindsey Fallow
	 *	@since  15.09.2009
	 */
	public class ModuleEvent extends Event {
		
		//--------------------------------------
		// CLASS CONSTANTS
		//--------------------------------------
		
		public static const MODULE_PROGRESS_UPDATE : String = "moduleUpdate";
		public static const MODULE_LOADING_COMPLETE : String = "moduleLoadingComplete";
		
		//--------------------------------------
		//  CONSTRUCTOR
		//--------------------------------------
		
		/**
		 *	@constructor
		 */
		public function ModuleEvent( type:String, msg:String = "", percentage:Number = 0, bubbles:Boolean=true, cancelable:Boolean=false ){
			super(type, bubbles, cancelable);
			this._msg = msg;
			this._percentage = percentage;		
		}
		
		//--------------------------------------
		//  GETTER/SETTERS
		//--------------------------------------
		
		//--------------------------------------
		//  PUBLIC METHODS
		//--------------------------------------

		override public function clone() : Event {
			return new ModuleEvent(type, _msg, _percentage, bubbles, cancelable);
		}
		
		public function get message():String{
			return this._msg;
		}
		
		public function get percentage():Number{
			return this._percentage;
		}
		
		//--------------------------------------
		//  EVENT HANDLERS
		//--------------------------------------

		//--------------------------------------
		//  PRIVATE VARIABLES
		//--------------------------------------
		
		private var _msg:String;
		
		private var _percentage:Number;
		
		//--------------------------------------
		//  PRIVATE & PROTECTED INSTANCE METHODS
		//--------------------------------------
		
	}
	
}
