package org.ranapat.tasks {
	
	public class TF {
		
		public static function auto(name:String):TaskQueue {
			return TaskFactory.instance.auto(name);
		}
		
		public static function toTask(...args):Task {
			return TaskFactory.instance.toTask.apply(TaskFactory.instance, args);
		}
		
		public static function get(name:String, auto:Boolean = false):TaskQueue {
			return TaskFactory.instance.get(name, auto);
		}
		
		public static function destroy():void {
			TaskFactory.instance.destroy();
		}
	}

}