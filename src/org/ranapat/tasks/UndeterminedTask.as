package org.ranapat.tasks {
	
	public class UndeterminedTask extends Task {
		private var _callback:Function;
		private var _args:Array;
		
		public function UndeterminedTask(callback:Function, ...args) {
			super();
			
			this._callback = callback;
			this._args = args.length == 1 && args[0]? args[0] : args;
		}
		
		override public function start():void {
			super.start();
			
			if (this._callback != null) {
				this._args.unshift(this.generateCompel());
				
				var failed:Boolean;
				
				try {
					this._callback.apply(null, this._args);
				} catch (e:Error) {
					failed = true;
					
					TT.log(this, "Undetermined function cannot be called [ " + e + " ]");
				}
			}
			
			this._callback = null;
			this._args = null;
			if (failed) {
				this.completed();
			}
		}
	}

}