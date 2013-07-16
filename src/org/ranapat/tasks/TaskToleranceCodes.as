package org.ranapat.tasks {
	
	public class TaskToleranceCodes {
		public static const ACCEPT:uint = 0;
		public static const REJECT_OTHER:uint = 1;
		public static const REJECT_SELF:uint = 2;
		public static const REJECT_BOTH:uint = 3;
		
		public static const PENDING:uint = 0;
		public static const WAITING:uint = 1;
		public static const RUNNING:uint = 2;
		
		public static function statusToString(status:uint):String {
			if (status == TaskToleranceCodes.PENDING) {
				return "PENDING";
			} else if (status == TaskToleranceCodes.WAITING) {
				return "WAITING";
			} else if (status == TaskToleranceCodes.RUNNING) {
				return "RUNNING";
			} else {
				return "undefined";
			}
		}
	}

}