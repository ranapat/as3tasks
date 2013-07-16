package org.ranapat.tasks {
	import flash.sampler.getSavedThis;
	import flash.utils.describeType;
	
	internal final class Tools {

		public static function arrayToFixedCount(count:uint, array:Array = null):Array {
			if (array) {
				var result:Array = [];
				var length:uint = array.length;
				length = length > count? count : length;
				for (var i:int = 0; i < length; ++i) {
					result.push(array[i]);
				}
				while (result.length < count) {
					result.push(null);
				}
				return result;
			} else {
				return array;
			}
		}
		
		public static function getFunctionName(f:Function):String {
			try {
				var t:Object = getSavedThis(f); 
				var methods:XMLList = describeType(t)..method.@name;

				for each (var m:String in methods) {
					if (t.hasOwnProperty(m) && t[m] != null && t[m] === f) return m;            
				}
			} catch (e:Error) {
				//
			}
			
			return null;                                        
		}
	}

}