package org.ranapat.tasks {
	
	public class CompelBlockTask extends Task {
		private var _compel:Number;
		
		public function CompelBlockTask(compel:Number) {
			this._compel = compel;
		}
		
		override public function start():void {
			super.start();
		}
		
		override public function compel(code:Number):Boolean {
			if (this._started && !isNaN(this._compel) && this._compel == code) {
				this.completed();
				
				return true;
			} else {
				return false;
			}
		}
		
	}

}