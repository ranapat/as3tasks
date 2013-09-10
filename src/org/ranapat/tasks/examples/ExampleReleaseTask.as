package org.ranapat.tasks.examples {
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	import org.ranapat.tasks.Task;
	
	public class ExampleReleaseTask extends Task {
		private var timer:Timer;
		
		public function ExampleReleaseTask() {
			super();
			
			this.timer = new Timer(3 * 1000, 1);
			this.timer.addEventListener(TimerEvent.TIMER, this.handleTimer, false, 0, true);
		}
		
		override public function start():void {
			super.start();
			
			trace("we start the timer and complete..........")
			this.doNotReleaseMe = true;
			this.timer.start();
			
			this.completed();
		}
		
		private function handleTimer(e:TimerEvent):void {
			trace("our timer is here mother fuckers.....");
			
			if (this.queue) {
				trace("tell the fucker to release me.........")
				this.queue.releaseKeeped(this);
			}
		}
		
	}

}