package org.ranapat.tasks {
	import flash.events.TimerEvent;
	import flash.utils.Dictionary;
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
		
		public var parameters:Dictionary;
		
		public function TaskQueue(uid:String = null) {
			this._uid = uid? uid : this.getRandomUID().toString();
			this._queue = new Vector.<Task>();
			this._current = null;
			
			this._lazyAutoStart = new Timer(TaskQueueSettings.LAZY_START_TIMEOUT, 1);
			this._lazyAutoStart.addEventListener(TimerEvent.TIMER, this.handleLazyAutoStartTimer, false, 0, true);
			
			this.parameters = new Dictionary(true);
			
			TT.log(this, this._uid + " created.");
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
		
		public function get current():Task {
			return this._current;
		}
		
		public function get running():Boolean {
			return this._started && !this._destroyed;
		}
		
		public function get destroyed():Boolean {
			return this._destroyed;
		}
		
		public function start():void {
			if (this.canProceed) {
				this.tryNext();
			} else {
				//
			}
		}
		
		public function push(task:Task, toIndex:int = -1):TaskQueue {
			if (toIndex == -1) {
				this.append(task);
			} else {
				this.appendToIndex(task, toIndex);
			}
			
			return this;
		}
		
		public function compel(code:Number):Boolean {
			if (this._current) {
				return this._current.compel(code);
			} else {
				return false;
			}
		}
		
		public function append(task:Task):Number {
			if (this.canProceed) {
				if (task) {
					if (this.tolleranceAppend(task)) {
						task.appendOnComplete(this.onComplete);
						
						TaskQueueMap.instance.set(task, this);
						
						this.tryToAutoStart();
						
						return task.uid;
					} else {
						return 0;
					}
				} else {
					return 0;
				}
			} else {
				return 0;
			}
		}
		
		public function appendToIndex(task:Task, index:uint):Number {
			if (this.canProceed) {
				if (task) {
					this._queue.splice(index > this._queue.length? this._queue.length : index, 0, task);
					task.appendOnComplete(this.onComplete);
					
					TaskQueueMap.instance.set(task, this);
					
					this.tryToAutoStart();
					
					return task.uid;
				} else {
					return 0;
				}
			} else {
				return 0;
			}
		}
		
		public function appendAfterUID(task:Task, uid:Number):Number {
			if (this._current != null && this._current.uid == uid) {
				return this.appendToIndex(task, 0);
			} else if (this._queue) {
				var queue:Vector.<Task> = this._queue;
				var length:uint = queue.length;
				for (var i:uint = 0; i < length; ++i) {
					if (queue[i].uid == uid) {
						return this.appendToIndex(task, i + 1);
					}
				}
			}
			return 0;
		}
		
		public function appendAfterTask(task:Task, after:Task):Number {
			return this.appendAfterUID(task, after.uid);
		}
		
		public function appendAfterCurrent(task:Task):Number {
			if (this._current) {
				return this.appendAfterTask(task, this._current);
			} else {
				return this.appendToIndex(task, 0);
			}
		}
		
		public function appendBeforeUID(task:Task, uid:Number):Number {
			if (this._current != null && this._current.uid == uid) {
				return this.appendToIndex(task, 0);
			} else if (this._queue) {
				var queue:Vector.<Task> = this._queue;
				var length:uint = queue.length;
				for (var i:uint = 0; i < length; ++i) {
					if (queue[i].uid == uid) {
						return this.appendToIndex(task, i);
					}
				}
			}
			return 0;
		}
		
		public function appendBeforeTask(task:Task, before:Task):Number {
			return this.appendBeforeUID(task, before.uid);
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
		
		protected function tryToAutoStart():void {
			if (
				!this._started
				&& this.autostart
				&& !this._lazyAutoStart.running
			) {
				this._lazyAutoStart.start();
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
			var i:uint;

			queue = _queue;
			length = queue.length;
			for (i = 0; i < length && result; ++i) {
				tmp = queue[i];
				result = this.checkTaskTolerance(task, tmp, TaskToleranceCodes.PENDING, TaskToleranceCodes.WAITING);
			}
			
			if (result) {
				queue = this._queue;
				length = queue.length;
				if (length > 0) {
					var desiredPosition:uint = length;

					for (i = length - 1; i >= 0 && i < length; --i) {
						tmp = queue[i];
						var priorityA:uint = task.priority(tmp, i, desiredPosition);
						var priorityB:uint = tmp.priority(task, desiredPosition, i);

						if (priorityA == TaskPriorityCodes.DONT_MOVE || priorityB == TaskPriorityCodes.DONT_MOVE) {
							break;
						} else if (
								priorityA == TaskPriorityCodes.BEFORE
								&& (
										priorityB == TaskPriorityCodes.DONT_MIND
										|| priorityB == TaskPriorityCodes.AFTER
								)
						) {
							desiredPosition = i;
						} else if (
								priorityA == TaskPriorityCodes.DONT_MIND
								&& priorityB == TaskPriorityCodes.AFTER
						) {
							desiredPosition = i;
						}
					}

					this._queue.splice(desiredPosition, 0, task);
				} else {
					this._queue.push(task);
				}
				
				TT.log(this, task.uid + " accepted in the queue.");
			}
			
			return result;
		}
		
		protected function checkTaskTolerance(taskA:Task, taskB:Task, statusA:uint, statusB:uint):Boolean {
			var result:Boolean = true;
			
			if (
				taskA.tollerance(taskB, statusB, statusA) == TaskToleranceCodes.ACCEPT
			) {
				if (
					taskB.tollerance(taskA, statusA, statusB) == TaskToleranceCodes.ACCEPT
				) {
					//result = true;
				} else if (
					taskB.tollerance(taskA, statusA, statusB) == TaskToleranceCodes.REJECT_SELF
				) {
					TT.log(this, taskB.uid + " as " + TaskToleranceCodes.statusToString(statusB) + " removed because of " + taskA.uid + " as " + TaskToleranceCodes.statusToString(statusA) + ".");
					this.stopByTask(taskB);
					
					//result = true;
				} else {
					if (
						taskB.tollerance(taskA, statusA, statusB) == TaskToleranceCodes.REJECT_BOTH
					) {
						TT.log(this, taskB.uid + " as " + TaskToleranceCodes.statusToString(statusB) + " removed because of " + taskA.uid + " as " + TaskToleranceCodes.statusToString(statusA) + ".");
						this.stopByTask(taskB);
					}
					
					TT.log(this, taskA.uid + " as " + TaskToleranceCodes.statusToString(statusA) + " rejected from queue because of " + taskB.uid + " as " + TaskToleranceCodes.statusToString(statusB) + ".");
					result = false;
				}
			} else if (
				taskA.tollerance(taskB, statusB, statusA) == TaskToleranceCodes.REJECT_OTHER
			) {
				if (
					taskB.tollerance(taskA, statusA, statusB) == TaskToleranceCodes.REJECT_OTHER
					|| taskB.tollerance(taskA, statusA, statusB) == TaskToleranceCodes.REJECT_BOTH
				) {
					TT.log(this, taskA.uid + " as " + TaskToleranceCodes.statusToString(statusA) + " rejected from queue because of " + taskB.uid + " as " + TaskToleranceCodes.statusToString(statusB) + ".");
					result = false;
				} else {
					//result = true;
				}
				
				TT.log(this, taskB.uid + " as " + TaskToleranceCodes.statusToString(statusB) + " removed because of " + taskA.uid + " as " + TaskToleranceCodes.statusToString(statusA) + ".");
				this.stopByTask(taskB);
			} else if (
				taskA.tollerance(taskB, statusB, statusA) == TaskToleranceCodes.REJECT_SELF
			) {
				TT.log(this, taskA.uid + " as " + TaskToleranceCodes.statusToString(statusA) + " rejected from queue because of " + taskB.uid + " as " + TaskToleranceCodes.statusToString(statusB) + ".");
				result = false;
			} else if (
				taskA.tollerance(taskB, statusB, statusA) == TaskToleranceCodes.REJECT_BOTH
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