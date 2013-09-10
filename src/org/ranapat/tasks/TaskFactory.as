package org.ranapat.tasks {
	import flash.utils.Dictionary;
	
	public class TaskFactory {
		private static var _allowInstance:Boolean;
		private static var _instance:TaskFactory;
		
		private var _queues:Dictionary;
		
		public static function get instance():TaskFactory {
			if (!TaskFactory._instance) {
				TaskFactory._allowInstance = true;
				TaskFactory._instance = new TaskFactory();
				TaskFactory._allowInstance = false;
			}
			return TaskFactory._instance;
		}
		
		public function TaskFactory() {
			if (TaskFactory._allowInstance) {
				this._queues = new Dictionary();
			} else {
				throw new Error("Use TaskFactory::instance getter instead.");
			}
		}
		
		public function destroy():void {
			TaskFactory._instance = null;
		}
		
		public function toTask(...args):Task {
			if (args.length > 0) {
				if (args[0] is Function) {
					return new CallbackTask(args.shift(), args);
				} else if (args[0] == undefined && args.length >= 2 && args[1] is Function) {
					args.shift();
					return new UndeterminedTask(args.shift(), args);
				} else if (args[0] is uint && args.length == 1) {
					return new TimeoutTask(args[0]);
				} else {
					TT.log(this, "[ " + args + " ] unknown arguments to create task from.");
					return null;
				}
			} else {
				return null;
			}
		}
		
		public function auto(name:String):TaskQueue {
			return this.get(name, true);
		}
		
		public function get(name:String, autostart:Boolean = false):TaskQueue {
			var tmp:TaskQueue;
			if (!this._queues[name]) {
				tmp = new TaskQueue(name);
				tmp.appendOnComplete(this.onComplete, name);
				tmp.autostart = autostart;
				this._queues[name] = tmp;
			} else {
				tmp = this._queues[name] as TaskQueue;
				if (!tmp.running && !tmp.destroyed && !tmp.autostart && autostart) {
					tmp.autostart = autostart;
				}
			}
			return tmp;
		}
		
		private function onComplete(name:String):void {
			this._queues[name] = null;
			delete this._queues[name];
			
			TT.log(this, name + " removed from queues.");
		}
		
	}

}