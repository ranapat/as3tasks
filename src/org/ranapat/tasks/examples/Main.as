package org.ranapat.tasks.examples {
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.Dictionary;
	import org.ranapat.tasks.CallbackTask;
	import org.ranapat.tasks.ClassTask;
	import org.ranapat.tasks.ParallelTask;
	import org.ranapat.tasks.TaskFactory;
	import org.ranapat.tasks.TaskQueue;
	import org.ranapat.tasks.TimeoutTask;
	
	public class Main extends Sprite {
		
		private var taskQueue:TaskQueue;
		
		public function Main():void {
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void {
			removeEventListener(Event.ADDED_TO_STAGE, init);
			// entry point
			
			trace("we are here");
			
			//taskQueue = new TaskQueue();
			//taskQueue.autostart = true;
			//taskQueue.append(new ParallelTask(Vector.<Task>([new Task(), new Task()])));
			//taskQueue.append(new Task());
			//taskQueue.append(new Task());
			//taskQueue.append(new Task());
			//taskQueue.append(new Task());
			/*
			taskQueue.append(new ParallelTask(
				[
					new TimeoutTask(.5 * 1000),
					new TimeoutTask(3.5 * 1000)
				],
				ParallelTask.TYPE_COMPLETE_ON_LAST
			));
			*/
			//taskQueue.append(new CallbackTask(this.callbackMain, [ "test", "test1" ]));
			//taskQueue.append(new TimeoutTask(1 * 1000));
			//taskQueue.append(new TimeoutTask(2 * 1000));
			//taskQueue.append(new TimeoutTask(3 * 1000));
			//taskQueue.append(new TimeoutTask(4 * 1000));
			
			//taskQueue.start();
			//taskQueue.stopAll();
			
			TaskFactory.instance.get("someshit", true)
				.push(new CallbackTask(this.callbackMain, "test", "test1"))
				.push(new TimeoutTask(1 * 1000))
				.push(ClassTask.getClass(Example))
				.push(new ParallelTask([new TimeoutTask(.5 * 1000), new TimeoutTask(3.5 * 1000)], ParallelTask.TYPE_COMPLETE_ON_LAST))
				.push(new CallbackTask(this.callbackMain, "test", "test1"))
			;
		}
		
		public function callbackMain(param1:String, param2:String):void {
			//trace("I'm here... " + this + " .. " + param1 + " .. " + param2)
			//TaskFactory.instance.get("someshit").stopAll();
		}
	}
	
}