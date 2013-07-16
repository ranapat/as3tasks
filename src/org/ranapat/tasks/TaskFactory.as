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
		
		public function get(name:String, autostart:Boolean = false):TaskQueue {
			if (!this._queues[name]) {
				var tmp:TaskQueue = new TaskQueue(name);
				tmp.appendOnComplete(this.onComplete, name);
				tmp.autostart = autostart;
				this._queues[name] = tmp;
			}
			return this._queues[name] as TaskQueue;
		}
		
		private function onComplete(name:String):void {
			this._queues[name] = null;
			delete this._queues[name];
			
			TT.log(this, name + " removed from queues.");
		}
		
	}

}