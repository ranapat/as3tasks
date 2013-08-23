package org.ranapat.tasks {
	
	public class ParallelTask extends Task {
		public static const TYPE_COMPLETE_ON_LAST:uint = 0;
		public static const TYPE_COMPLETE_ON_FIRST:uint = 1;
		
		private var _type:uint;
		private var _parallels:Vector.<Task>;
		private var _completed:uint;
		
		public function ParallelTask(tasks:Array = null, type:uint = ParallelTask.TYPE_COMPLETE_ON_LAST) {
			super();
			
			this._type = type;
			this._parallels = new Vector.<Task>();
			
			if (tasks) {
				for each (var task:Object in tasks) {
					this.append(task as Task);
				}
			}
		}
		
		public function append(task:Task):Number {
			task.appendOnComplete(this.onComplete);
			this._parallels.push(task);
			
			return task.uid;
		}
		
		override public function start():void {
			super.start();
			this._completed = 0;
			
			var parallels:Vector.<Task> = this._parallels;
			var length:uint = parallels.length;
			for (var i:uint = 0; i < length; ++i) {
				parallels[i].start();
			}
		}
		
		override public function stop():Boolean {
			var result:Boolean = true;
			var parallels:Vector.<Task> = this._parallels;
			var length:uint = parallels.length;
			for (var i:uint = 0; i < length; ++i) {
				result &&= parallels[i].stop();
			}
			return result;
		}
		
		override public function get progress():uint {
			return this._completed / this._parallels.length * 100;
		}
		
		protected function onComplete():void {
			++this._completed;
			
			var isComplete:Boolean;
			
			if (
				this._type == ParallelTask.TYPE_COMPLETE_ON_FIRST
				&& this._completed == 1
			) {
				isComplete = true;
			} else if (
				this._type == ParallelTask.TYPE_COMPLETE_ON_LAST
				&& this._completed == this._parallels.length
			) {
				isComplete = true;
			}
			
			if (this._completed == this._parallels.length) {
				this._parallels = new Vector.<Task>();
			}
			
			if (isComplete) {
				this.completed();
			}
		}
		
	}

}