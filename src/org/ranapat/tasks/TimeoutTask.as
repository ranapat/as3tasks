package org.ranapat.tasks {
	import flash.events.TimerEvent;
	import flash.utils.Timer;
	
	public class TimeoutTask extends Task {
		
		private var _timeout:uint;
		
		private var timeoutTimer:Timer;
		
		public function TimeoutTask(timeout:uint) {
			this._timeout = timeout;
			
			this.timeoutTimer = new Timer(this._timeout, 1);
			this.timeoutTimer.addEventListener(TimerEvent.TIMER, this.handleTimeoutTimer, false, 0, true);
		}
		
		override public function start():void {
			super.start();
			
			this.timeoutTimer.start();
		}
		
		override public function stop():Boolean {
			var result:Boolean;
			if (this.timeoutTimer) {
				this.destroy();
				
				this.completed();
				
				result = true;
			}
			return result;
		}
		
		private function destroy():void {
			this.timeoutTimer.stop();
			this.timeoutTimer.removeEventListener(TimerEvent.TIMER, this.handleTimeoutTimer);
			this.timeoutTimer = null;
		}
		
		private function handleTimeoutTimer(e:TimerEvent):void {
			this.destroy();
			
			this.completed();
		}
		
	}

}