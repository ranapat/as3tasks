package org.ranapat.tasks {
	import flash.utils.Dictionary;
	
	internal class TaskQueueMap {
		private static var _allowInstance:Boolean;
		private static var _instance:TaskQueueMap;
		
		private var map:Dictionary;
		
		public static function get instance():TaskQueueMap {
			if (!TaskQueueMap._instance) {
				TaskQueueMap._allowInstance = true;
				TaskQueueMap._instance = new TaskQueueMap();
				TaskQueueMap._allowInstance = false;
			}
			return TaskQueueMap._instance;
		}

		public function TaskQueueMap() {
			if (TaskQueueMap._allowInstance) {
				this.map = new Dictionary(true);
			} else {
				throw new Error("Use TaskQueueMap::instance getter instead.");
			}
		}
		
		public function set(task:Task, queue:TaskQueue):void {
			this.map[task] = queue;
		}
		
		public function get(task:Task):TaskQueue {
			return this.map[task];
		}
	}

}