package org.ranapat.tasks {
	
	public class CallbackTask extends Task {
		private var _callback:Function;
		private var _args:Array;
		
		public function CallbackTask(callback:Function, ...args) {
			super();
			
			this._callback = callback;
			this._args = args.length == 1 && args[0]? args[0] : args;
		}
		
		override public function start():void {
			super.start();
			
			if (this._callback != null) {
				this._callback.apply(null, this._args);
			}
			
			this.completed();
			this._callback = null;
			this._args = null;
		}
	}

}