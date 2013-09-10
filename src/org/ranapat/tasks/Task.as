package org.ranapat.tasks {
	
	public class Task {
		private var _uid:Number;
		private var _compel:Number;
		private var _doNotReleaseMe:Boolean;
		
		protected var _started:Boolean;
		protected var _complete:Boolean;
		protected var _progress:uint;
		
		public function Task() {
			Tools.ensureAbstractClass(this, Task);
			
			this.generateUID();
		}
		
		public function get uid():Number {
			return this._uid;
		}
		
		public function get started():Boolean {
			return this._started;
		}

		public function get progress():uint {
			return this._progress;
		}
		
		public function get complete():Boolean {
			return this._complete;
		}
		
		public function get doNotReleaseMe():Boolean {
			return this._doNotReleaseMe;
		}
		
		public function set doNotReleaseMe(value:Boolean):void {
			this._doNotReleaseMe = value;
		}
		
		public function get queue():TaskQueue {
			return TaskQueueMap.instance.get(this);
		}
		
		public function start():void {
			TT.log(this, this.uid + " started.");
			this._started = true;
			this._progress = 0;
		}
		
		public function stop():Boolean {
			return false;
		}
		
		public function compel(code:Number):Boolean {
			if (this._started && !isNaN(this._compel) && this._compel == code) {
				this.completed();
				
				return true;
			} else {
				return false;
			}
		}
		
		public function tollerance(other:Task, otherStatus:uint, myStatus:uint):uint {
			return TaskToleranceCodes.ACCEPT;
		}

		public function priority(other:Task, otherPosition:uint, myPosition:uint):uint {
			return TaskPriorityCodes.DONT_MIND;
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
			this._complete = true;
			TT.log(this, this.uid + " completed.");
		}
		
		protected function generateUID():void {
			this._uid = (new Date()).getTime() * 1000 + Math.random() * 1000 + Math.random();
		}
		
		protected function generateCompel():Number {
			this._compel = (new Date()).getTime() * 1000 + Math.random() * 1000 + Math.random();
			
			return this._compel;
		}
		
	}

}