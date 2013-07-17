package org.ranapat.tasks.examples {
	import org.ranapat.tasks.Task;
	import org.ranapat.tasks.TaskPriorityCodes;
	import org.ranapat.tasks.TaskToleranceCodes;
	
	[TasksEnabled(true)]
	public class Example {

		public function Example() {
			//trace("I am created")
		}

		[TaskTolerance]
		public static function checkTolerance(other:Task, otherStatus:uint, myStatus:uint):uint {
			//trace("someone calls me to check tolerance .... " + other + " .. " + otherStatus + " .. " + myStatus);
			return TaskToleranceCodes.ACCEPT;
		}

		[TaskPriority]
		public static function forcePriority(other:Task, otherPosition:uint, myPosition:uint):uint {
			//trace("someone calls me to check tolerance .... " + other + " .. " + otherPosition + " .. " + myPosition);
			return otherPosition < myPosition? TaskPriorityCodes.BEFORE : TaskPriorityCodes.DONT_MIND;
			//return TaskPriorityCodes.DONT_MIND;
		}

		[TaskStart]
		public function weWillStartHere():Boolean {
			//trace("I am started " + this)
			this.weAreCompletedHere();

			return true;
		}

		[TaskCompleted]
		public var weAreCompletedHere:Function = function ():void {
			//trace("I am completed " + this)
		}
	}

}