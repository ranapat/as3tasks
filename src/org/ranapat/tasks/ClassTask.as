package org.ranapat.tasks {
	
	public class ClassTask extends Task {
		private var _class:Class;
		private var _classConstructorParams:Array;
		private var _startMethodName:String;
		private var _startMethodParams:Array;
		private var _completedMethodName:String;
		
		private var _instance:Object;
		
		public static function getClass(
			_class:Class,
			_classConsuctorParams:Array = null,
			_startMethodParams:Array = null
		):ClassTask {
			var result:Vector.<XML> = MetadataAnalyzer.getMetaTags(_class, null, true);
			
			var node:XML;
			var subnode:XML;
			
			var tasksEnabled:Boolean;
			var startMethodName:String;
			var completedMethodName:String;
			
			for each (node in result) {
				if (node.name() == "metadata" && node.attribute("name") == TaskSettings.METADATA_TAG_TASKS_ENABLED) {
					if (node.arg[0].attribute("value") == "true") {
						tasksEnabled = true;
						
						break;
					}
				}
			}
			
			if (tasksEnabled) {
				for each (node in result) {
					if (node.name() == "method") {
						for each (subnode in node.metadata) {
							if (subnode.attribute("name") == TaskSettings.METADATA_TAG_TASK_START) {
								startMethodName = node.attribute("name");
							}
						}
					} else if (node.name() == "variable" && node.attribute("type") == "Function") {
						for each (subnode in node.metadata) {
							if (subnode.attribute("name") == TaskSettings.METADATA_TAG_TASK_COMPLETED) {
								completedMethodName = node.attribute("name");
							}
						}
					}
				}
			}
			
			if (tasksEnabled && completedMethodName) {
				return new ClassTask(
					_class,
					completedMethodName,
					startMethodName,
					_classConsuctorParams,
					_startMethodParams
				);
			} else {
				return null;
			}
		}
		
		public function ClassTask(
			_class:Class,
			_completedMethodName:String,
			_startMethodName:String = null,
			_classConsuctorParams:Array = null,
			_startMethodParams:Array = null
		) {
			super();
			
			this._class = _class;
			this._classConstructorParams = _classConstructorParams;
			this._startMethodName = _startMethodName;
			this._startMethodParams = _startMethodParams;
			this._completedMethodName = _completedMethodName;
		}
		
		override public function start():void {
			super.start();
			
			if (this._classConstructorParams) {
				this._instance = new this._class(this._classConstructorParams);
			} else {
				this._instance = new this._class();
			}
			
			if (this._completedMethodName) {
				var _completed:Function = this._instance[this._completedMethodName];
				var _onCompleted:Function = this.onCompleted;
				var _instance:* = this._instance;
				this._instance[this._completedMethodName] = function (...args):void {
					_completed.apply(_instance, args);
					
					_onCompleted.apply();
				}
			}
			
			if (this._startMethodName) {
				if (this._startMethodParams) {
					this._instance[this._startMethodName].apply(null, this._startMethodParams);
				} else {
					this._instance[this._startMethodName].apply(null, this._startMethodParams);
				}
			}
		}
		
		private function onCompleted():void {
			this._class = null;
			this._classConstructorParams = null;
			this._startMethodName = null;
			this._startMethodParams = null;
			this._completedMethodName = null;
			
			this.completed();
		}
		
	}

}