package org.ranapat.tasks {
	import flash.events.TimerEvent;
	import flash.utils.getQualifiedClassName;
	import flash.utils.Timer;
	
	public class TaskQueue {
		private var _uid:String;
		
		private var _started:Boolean;
		private var _destroyed:Boolean;
		
		private var _queue:Vector.<Task>;
		private var _current:Task;
		private var _autostart:Boolean;
		
		private var _lazyAutoStart:Timer;
		
		public function TaskQueue(uid:String = null) {
			this._uid = uid? uid : this.getRandomUID().toString();
			this._queue = new Vector.<Task>();
			this._current = null;
			
			this._lazyAutoStart = new Timer(TaskQueueSettings.LAZY_START_TIMEOUT, 1);
			this._lazyAutoStart.addEventListener(TimerEvent.TIMER, this.handleLazyAutoStartTimer, false, 0, true);
		}
		
		public function get autostart():Boolean {
			return this._autostart;
		}
		
		public function set autostart(value:Boolean):void {
			this._autostart = value;
		}
		
		public function get complete():Boolean {
			return this._current == null && this._queue.length == 0;
		}
		
		public function start():void {
			if (this.canProceed) {
				this.tryNext();
			} else {
				throw new Error("[" + getQualifiedClassName(this) + "] " + this._uid + " already destroyed.");
			}
		}
		
		public function push(task:Task):TaskQueue {
			this.append(task);
			
			return this;
		}
		
		public function append(task:Task):Number {
			if (this.canProceed) {
				if (task) {
					if (this.tolleranceAppend(task)) {
						if (
							!this._started
							&& this.autostart
							&& !this._lazyAutoStart.running
						) {
							this._lazyAutoStart.start();
						}
						
						return task.uid;
					} else {
						return 0;
					}
				} else {
					return 0;
				}
			} else {
				throw new Error("[" + getQualifiedClassName(this) + "] " + this._uid + " already destroyed.");
			}
		}
		
		public function stopCurrent():Boolean {
			return this._current && this._current.stop();
		}
		
		public function stopAllButCurrent():void {
			this._queue = new Vector.<Task>();
		}
		
		public function stopAll():void {
			this._queue = new Vector.<Task>();
			this.stopCurrent();
		}
		
		public function stopByTask(task:Task):Boolean {
			var result:Boolean = false;
			
			if (this._current == task) {
				result = this._current.stop();
			} else if (this._queue) {
				var queue:Vector.<Task> = this._queue;
				var length:uint = queue.length;
				for (var i:uint = 0; i < length; ++i) {
					if (queue[i] == task) {
						this._queue.splice(i, 1);
						
						result = true;
						break;
					}
				}
			}
			
			return result;
		}
		
		public function stopByUID(uid:Number):Boolean {
			var result:Boolean = false;
			
			if (this._current != null && this._current.uid == uid) {
				result = this._current.stop();
			} else if (this._queue) {
				var queue:Vector.<Task> = this._queue;
				var length:uint = queue.length;
				for (var i:uint = 0; i < length; ++i) {
					if (queue[i].uid == uid) {
						this._queue.splice(i, 1);
						
						result = true;
						break;
					}
				}
			}
			
			return result;
		}
		
		public function appendOnComplete(callback:Function, ...args):void {
			var _completed:Function = this.completed;
			this.completed = function ():void {
				_completed.apply(this);
				callback.apply(null, args);
			}
		}
		
		public function destroy():void {
			if (!this._destroyed) {
				this._lazyAutoStart.stop();
				this._lazyAutoStart.removeEventListener(TimerEvent.TIMER, this.handleLazyAutoStartTimer);
				this._lazyAutoStart = null;
				
				this.stopAll();
				
				this._current = null;
				this._autostart = false;
				this._queue = null;
				
				this._destroyed = true;
				
				this.completed();
			}
		}
		
		protected function tryNext():void {
			if (this._current == null && this._queue.length > 0) {
				if (!this._started) {
					TT.log(this, this._uid + " started.");
					this._started = true;
				}
				
				this._current = this._queue.shift();
				this._current.start();
			} else if (this._current == null && this._queue.length == 0) {
				if (this._started) {
					TT.log(this, this._uid + " completed.");
				}
				
				this.destroy();
			}
		}
		
		protected function tolleranceAppend(task:Task):Boolean {
			var result:Boolean = true;
			
			if (this._current) {
				result = this.checkTaskTolerance(task, this._current, TaskToleranceCodes.PENDING, TaskToleranceCodes.RUNNING);
			}
			
			var queue:Vector.<Task> = this._queue;
			var length:uint = queue.length;
			var tmp:Task;
			for (var i:uint = 0; i < length && result; ++i) {
				tmp = queue[i];
				result = this.checkTaskTolerance(task, tmp, TaskToleranceCodes.PENDING, TaskToleranceCodes.WAITING);
			}
			
			if (result) {
				task.appendOnComplete(this.onComplete);
				this._queue.push(task);
				
				TT.log(this, task.uid + " accepted in the queue.");
			}
			
			return result;
		}
		
		protected function checkTaskTolerance(taskA:Task, taskB:Task, statusA:uint, statusB:uint):Boolean {
			var result:Boolean = true;
			
			if (
				taskA.tollerance(taskB, statusB) == TaskToleranceCodes.ACCEPT
			) {
				if (
					taskB.tollerance(taskA, statusA) == TaskToleranceCodes.ACCEPT
				) {
					//result = true;
				} else if (
					taskB.tollerance(taskA, statusA) == TaskToleranceCodes.REJECT_SELF
				) {
					TT.log(this, taskB.uid + " as " + TaskToleranceCodes.statusToString(statusB) + " removed because of " + taskA.uid + " as " + TaskToleranceCodes.statusToString(statusA) + ".");
					this.stopByTask(taskB);
					
					//result = true;
				} else {
					if (
						taskB.tollerance(taskA, statusA) == TaskToleranceCodes.REJECT_BOTH
					) {
						TT.log(this, taskB.uid + " as " + TaskToleranceCodes.statusToString(statusB) + " removed because of " + taskA.uid + " as " + TaskToleranceCodes.statusToString(statusA) + ".");
						this.stopByTask(taskB);
					}
					
					TT.log(this, taskA.uid + " as " + TaskToleranceCodes.statusToString(statusA) + " rejected from queue because of " + taskB.uid + " as " + TaskToleranceCodes.statusToString(statusB) + ".");
					result = false;
				}
			} else if (
				taskA.tollerance(taskB, statusB) == TaskToleranceCodes.REJECT_OTHER
			) {
				if (
					taskB.tollerance(taskA, statusA) == TaskToleranceCodes.REJECT_OTHER
					|| taskB.tollerance(taskA, statusA) == TaskToleranceCodes.REJECT_BOTH
				) {
					TT.log(this, taskA.uid + " as " + TaskToleranceCodes.statusToString(statusA) + " rejected from queue because of " + taskB.uid + " as " + TaskToleranceCodes.statusToString(statusB) + ".");
					result = false;
				} else {
					//result = true;
				}
				
				TT.log(this, taskB.uid + " as " + TaskToleranceCodes.statusToString(statusB) + " removed because of " + taskA.uid + " as " + TaskToleranceCodes.statusToString(statusA) + ".");
				this.stopByTask(taskB);
			} else if (
				taskA.tollerance(taskB, statusB) == TaskToleranceCodes.REJECT_SELF
			) {
				TT.log(this, taskA.uid + " as " + TaskToleranceCodes.statusToString(statusA) + " rejected from queue because of " + taskB.uid + " as " + TaskToleranceCodes.statusToString(statusB) + ".");
				result = false;
			} else if (
				taskA.tollerance(taskB, statusB) == TaskToleranceCodes.REJECT_BOTH
			) {
				TT.log(this, taskB.uid + " as " + TaskToleranceCodes.statusToString(statusB) + " removed because of " + taskA.uid + " as " + TaskToleranceCodes.statusToString(statusA) + ".");
				this.stopByTask(taskB);
				
				TT.log(this, taskA.uid + " as " + TaskToleranceCodes.statusToString(statusA) + " rejected from queue because of " + taskB.uid + " as " + TaskToleranceCodes.statusToString(statusB) + ".");
				result = false;
			}
			
			return result;
		}
		
		protected function handleLazyAutoStartTimer(e:TimerEvent):void {
			this.tryNext();
		}
		
		protected function onComplete():void {
			this._current = null;
			this.tryNext();
		}
		
		protected function getRandomUID():Number {
			return (new Date()).getTime() * 1000 + Math.random() * 1000 + Math.random();
		}
		
		protected var completed:Function = function ():void {}
		
		private function get canProceed():Boolean {
			return !this._destroyed;
		}
		
	}

}