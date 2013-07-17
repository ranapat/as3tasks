package org.ranapat.tasks {
	
	public class Task {
		private var _uid:Number;
		
		protected var _progress:uint;
		
		public function Task() {
			this.generateUID();
		}
		
		public function start():void {
			TT.log(this, this.uid + " started.");
			this._progress = 0;
		}
		
		public function stop():Boolean {
			return false;
		}
		
		public function get progress():uint {
			return this._progress;
		}
		
		public function tollerance(other:Task, otherStatus:uint, myStatus:uint):uint {
			return TaskToleranceCodes.ACCEPT;
		}

		public function priority(other:Task, otherPosition:uint, myPosition:uint):uint {
			return TaskPriorityCodes.DONT_MIND;
		}
		
		public function get uid():Number {
			return this._uid;
		}
		
		public function appendOnComplete(callback:Function, ...args):void {
			var _completed:Function = this.completed;
			this.completed = function ():void {
				_completed.apply(this);
				callback.apply(null, args);
			}
		}
		
		protected var completed:Function = function ():void {
			this._progress = 100;
			TT.log(this, this.uid + " completed.");
		}
		
		protected function generateUID():void {
			this._uid = (new Date()).getTime() * 1000 + Math.random() * 1000 + Math.random();
		}
		
	}

}