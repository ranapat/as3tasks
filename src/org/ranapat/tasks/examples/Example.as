package org.ranapat.tasks.examples {
	
	[TasksEnabled(false)]
	public class Example {
		
		public function Example() {
			trace("I am created")
		}
		
		[TaskStart()]
		[SomeOtherShit()]
		public function weWillStartHere():Boolean {
			trace("I am started " + this)
			this.weAreCompletedHere();
			
			return true;
		}
		
		[TaskCompleted()]
		public var weAreCompletedHere:Function = function ():void {
			trace("I am completed " + this)
		}
		
	}

}