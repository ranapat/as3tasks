package org.ranapat.tasks {
	import flash.events.TimerEvent;
	import flash.utils.Timer;

	public class TimerTask extends Task {
		private var _interval:uint;
		private var _repeat:uint;
		private var _callback:Function;
		private var _args:Array;

		private var iterations:uint;

		private var timer:Timer;

		public function TimerTask(interval:uint, repeat:uint, callback:Function, ...args) {
			this._interval = interval;
			this._repeat = repeat;
			this._callback = callback;
			this._args = args;

			this.timer = new Timer(this._interval, this._repeat);
			this.timer.addEventListener(TimerEvent.TIMER, this.handleTimer, false, 0, true);
		}

		override public function start():void {
			super.start();

			this.timer.start();
		}

		override public function stop():Boolean {
			var result:Boolean;
			if (this.timer) {
				this.destroy();

				this.completed();

				result = true;
			}
			return result;
		}

		private function destroy():void {
			this.timer.stop();
			this.timer.removeEventListener(TimerEvent.TIMER, this.handleTimer);
			this.timer = null;

			this._callback = null;
			this._args = null;
		}

		private function handleTimer(e:TimerEvent):void {
			++this.iterations;

			if (this._callback != null) {
				this._callback.apply(null, this._args);
			}

			if (this.iterations >= this._repeat) {
				this.destroy();

				this.completed();
			}
		}

	}

}