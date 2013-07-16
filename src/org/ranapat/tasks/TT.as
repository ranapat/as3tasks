package org.ranapat.tasks {
	import flash.utils.getDefinitionByName;
	import flash.utils.getQualifiedClassName;
	
	internal class TT {
		
		public static function log(instance:Object, message:String):void {
			if (TaskSettings.TT_SHOW_LOG) {
				trace("[" + TT.getClassName(instance) + "] " + message);
			}
		}
		
		public static function getClassName(instance:Object):String {
			return getQualifiedClassName(instance);
		}
		
		public static function getClass(instance:Object):Class {
			return getDefinitionByName(TT.getClassName(instance)) as Class;
		}
	}

}