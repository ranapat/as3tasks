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
			
			try {
				this._callback.apply(null, this._args);
			} catch (e:Error) {
				TT.log(this, "Callback function cannot be called [ " + e + " ]");
			}
			
			this._callback = null;
			this._args = null;
			
			this.completed();
		}
	}

}