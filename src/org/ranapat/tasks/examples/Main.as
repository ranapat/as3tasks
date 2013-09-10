package org.ranapat.tasks.examples {
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.utils.Dictionary;
	import org.ranapat.tasks.CallbackTask;
	import org.ranapat.tasks.ClassTask;
	import org.ranapat.tasks.ParallelTask;
	import org.ranapat.tasks.Task;
	import org.ranapat.tasks.TaskFactory;
	import org.ranapat.tasks.TaskQueue;
	import org.ranapat.tasks.TF;
	import org.ranapat.tasks.TimeoutTask;
	import org.ranapat.tasks.TimerTask;
	import org.ranapat.tasks.UndeterminedTask;
	
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
			
			
			
			var strict:Vector.<Vector.<uint>> = Vector.<Vector.<uint>>([
				Vector.<uint>([1, 2, 3, 4]),
				Vector.<uint>([88, 3, 4, 5]),
				Vector.<uint>([3, 4, 5, 6]),
				Vector.<uint>([4, 5, 6, 7]),
			]);
			var usersCount:uint = strict.length;
			var roundsCount:uint = strict[0].length;

			var result:Vector.<Vector.<uint>> = new Vector.<Vector.<uint>>(roundsCount, true);

			for (var round:uint = 0; round < roundsCount; ++round) {
				result[round] = new Vector.<uint>(usersCount, true);
				for (var user:uint = 0; user < usersCount; ++user) {
					result[round][user] = strict[user][round];
				}
			}
			
			trace(result)

			
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

			/*
			TaskFactory.instance.get("someshit", true)
				.push(new CallbackTask(this.callbackMain, "test", "test1"))
				.push(new TimeoutTask(1 * 1000))
				.push(ClassTask.getClass(Example))
				.push(new ParallelTask([new TimeoutTask(.5 * 1000), new TimeoutTask(3.5 * 1000)], ParallelTask.TYPE_COMPLETE_ON_LAST))
				.push(new CallbackTask(this.callbackMain, "test", "test1"))
				.push(new TimerTask(1000, 4, this.callbackMain, "t", "tt"))
			;
			*/
			
			/*
			t1 = TF.toTask(this.callbackTest1)
			t2 = TF.toTask(this.callbackTest2);
			
			trace(t1.uid)
			trace(t2.uid)
			
			TF.auto("ssss")
				.push(t1)
				.push(t2)
			;
			*/
			
			/*
			TF.auto("d1")
				.push(TF.toTask(5 * 1000, 12, 33))
				//.push(new UndeterminedTask(this.undetermined))
				.push(TF.toTask(undefined, this.undetermined))
				.push(new CallbackTask(this.callbackTest1_1, ["a", "b", "c"]))
				.push(new CallbackTask(this.callbackTest1))
			*/
				
			
			trace("++++++++++++++ " + TF.get("ffff"))
			TF.get("ffff")
				.push(TF.toTask(this.callbackTest1))
				
			TF.get("ffff").start()
				
			trace("??? " + TF.auto("ffff").complete)
			//TF.auto("ffff").start()
				
			
		}
		
		public var t1:Task;
		public var t2:Task;
		
		public function undetermined(compel:Number):void {
			trace("I am undetermined.... " + compel)
			TF.auto("d1").compel(compel);
		}
		
		public function callbackTest1():void {
			trace("t1");
			//TF.auto("ssss").appendBeforeTask(TF.toTask(this.callbackTest1_1), t2);
		}
		
		public function callbackTest2():void {
			trace("t2");
		}
		
		public function callbackTest1_1(...args):void {
			trace("t1_1 " + args.length + " .. " + args);
		}
		
		public function callbackMain(param1:String, param2:String):void {
			trace("I'm here... " + this + " .. " + param1 + " .. " + param2)
			//TaskFactory.instance.get("someshit").stopAll();
		}
	}
	
}