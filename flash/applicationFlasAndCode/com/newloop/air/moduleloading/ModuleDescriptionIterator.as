/* AS3
	Copyright 2009 Newloop but feel free to reuse, remix, recycle, reversion and redistribute.
*/

package com.newloop.air.moduleloading{
	
	/**
	 *  Strongly typed iterator for ModuleDescriptions.
	 *	
	 * 	@langversion ActionScript 3
	 *	@playerversion Flash 10.0.0
	 *
	 *	@author Lindsey Fallow
	 *	@since  16.09.2009
	 */public class ModuleDescriptionIterator {
		
		// declare variables
		private var current:int;
		public var length:uint;
		public var data_vector:Vector.<ModuleDescription>;
		
		
		/**
		 *	@constructor
		 *	
		 *	@param dataVector A vector of ModuleDescription class instances.
		 */
		public function ModuleDescriptionIterator(data_vector:Vector.<ModuleDescription>) {
			this.data_vector = data_vector;
			this.length = data_vector.length;
			this.current = -1;
		}
		
		
		/**
		 *  Gets the next item in the iterator. Returns first item on first call.
		 *	
		 *	@return the next moduleDescription, or null if there are none left.   
		 */
		public function getNext():ModuleDescription {
			if (this.current <0) {
				this.current = 0;
			} else if (this.current>=0) {
				this.current += 1;
				// have we got to the end of the loop?
				if (this.current>=this.length) {
					return null;
				}
			} else {
				this.current = 0;
			}
			return this.data_vector[this.current];
		}
		
		/**
		 *  Gets the previous item in the iterator. Returns first item on first call.
		 *	
		 *	@return the previous moduleDescription, or null if we are at the start.   
		 */
		public function getPrevious():ModuleDescription {
			if (this.current>=0) {
				this.current -= 1;
				// have we got to the end of the loop?
				if (this.current<0) {
					return null;
				}
			} else {
				this.current = 0;
			}
			return this.data_vector[this.current];
		}
		
		/**
		 *  Gets the current item in the iterator.
		 *	
		 *	@return the current moduleDescription, or null if getNext or getPrevious has not been called yet.   
		 */
		public function getCurrent():ModuleDescription {
			// trace("getCurrent");
			if (this.current>=0) {
				return this.data_vector[this.current];
			} else {
				return null;
			}
		}
		
		/**
		 *  Sets the current item in the iterator.
		 *	
		 *	@param moduleDescription is a ModuleDescription to seek out.
		 *	
		 *	@return the index of the ModuleDescription passed in, or -1 if not found.   
		 */
		public function setCurrent(moduleDescription:ModuleDescription):int {
			var iLength:uint = this.length;
			for (var i:uint = 0; i<iLength; i++) {
				if (this.data_vector[i] == moduleDescription) {
					this.current = i;
					return i;
				}
			}
			return -1;
		}
		
		/**
		 *	Removes the current item from the iterator and returns it.
		 *	
		 *	@return the current ModuleDescription item, or null if neither getNext nor getPrevious have been called.
		 */
		public function removeCurrent():ModuleDescription {
			if (this.current>=0) {
				this.data_vector.splice(this.current, 1);
				this.length = data_vector.length;
				return this.getCurrent();
			} 
			
			return null;
			
		}
		
		/**
		 *	Checks if there is a next item in the list.
		 *	
		 *	@return whether there is a next item.
		 */
		public function hasNext():Boolean { 
			
			if(this.length==0){
				return false;
			}
			
			if (this.current<0) {
				return true;
			}
			if (this.current<(this.length-1)) {
				return true;
			} 
			
			return false;
		}
		
		/**
		 *	Checks if there is a previous item in the list.
		 *	
		 *	@return whether there is a previous item.
		 */
		public function hasPrevious():Boolean {
			if(this.length==0){
				return false;
			}
			
			if (this.current <0) {
				return true;
			}
			if (this.current>0) {
				return true;
			} 
			
			return false;
			
		}
		
		/**
		 *	Resets the list to position 0. getCurrent will give the first item in the list and getNext the second.
		 */
		public function reset():void {
			this.current = 0;
		}
		
		/**
		 *	Resets the list and clears the current index, so getNext will give the first item in the list.
		 */
		public function resetAndClear():void {
			this.current= -1;
		}
		
		/**
		 *	Sets the current index to the end of the list.
		 */
		public function resetLast():void{
			this.current = this.length-1;
		}
	}
}