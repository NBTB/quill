package
{
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.geom.Point;
	
	
	import flash.text.*;
	import flash.utils.Timer;
	
	public class OOIManager extends MovieClip
	{
		public var objectsOfInterest:Array = null;				//array of objects of interest
		private var ooiUnused:Array = null;						//array of objects of interest that have not yet been used for hunt
		private var currentOOI:ObjectOfInterest = null;			//current object of interest being hunted
		
		private static var clueTextFormat:TextFormat = new TextFormat("Edwardian Script ITC", 30, 0x40E0D0, 
																	  null, null, null, null, null, TextFormatAlign.CENTER);	//text format of the clue textfield
		
		
		
		/*TODO should go into scavenger hunt and be private*/
		private var clueTimer:Timer = null;						//timer used to trigger the hiding of the clue textfield
		var clueText:TextField = new TextField(); 		//textfield to hold a newly unlocked clue
		
		public static var wrongAnswer:String = "That is not the answer to the riddle"; 										//message that appears in the clue textfield when the wrong clue is guessed
		
		//construct Object of Interest Manager
		public function OOIManager()
		{
			//create empty array of objects of interest
			objectsOfInterest = new Array();			
			
			//create clue timer
			clueTimer = new Timer(3 * 1000, 1);
			
			//listen for the completion of the clue timer
			clueTimer.addEventListener(TimerEvent.TIMER, function(e:TimerEvent):void
																		  {
																			//reset clue time and hide the clue text box
																			clueTimer.reset();
																			clueText.text = ""
																			clueText.visible = false;
																		  });
			
			//listen for being added to the display list
			addEventListener(Event.ADDED_TO_STAGE, addedToStage);
		}
		
		private function addedToStage(e:Event):void
		{			
			//set clue textfield location and settings		
			clueText.defaultTextFormat = clueTextFormat;
			clueText.wordWrap=true;
			clueText.x=66;
			clueText.y=68;
			clueText.width=474;
			
			//add clue textfield to display list
			addChild(clueText);	
		}
		
						
		//add an object of interest to the list
		public function addObjectOfInterest(newObject:ObjectOfInterest)
		{
			//add new object to list
			objectsOfInterest.push(newObject);
			
			//add new object as a display list child
			addChild(newObject);			
			
			//listen for when the cursor begins to hover over the new object
			newObject.addEventListener(MouseEvent.MOUSE_OVER, function(e:MouseEvent):void
																					{	
																						var targetObject:ObjectOfInterest = ObjectOfInterest(e.target);
																						targetObject.showOutline();	
																						targetObject.prepareCaption();																						
																					});

			//listen for when the cursor stops hovering over the new object
			newObject.addEventListener(MouseEvent.MOUSE_OUT, function(e:MouseEvent):void
																					{	
																						var targetObject:ObjectOfInterest = ObjectOfInterest(e.target);
																						targetObject.hideOutline();	
																						targetObject.unprepareCaption();
																					});
			
			
			
			//listen for when the object of interest is clicked
			newObject.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void
																					{	
																						if(currentOOI)
																						{
																							if(ObjectOfInterest(e.target).getID() == currentOOI.getID())
																							{
																								pickNextOOI();
																								displayClue();
																							}
																							else
																								displayIncorrect();
																						}
																					});
			
		}
		
		//reset the unused object of interest list so that objects can be re-hunted
		public function resetUnusedOOIList():void
		{
			ooiUnused = new Array();
			for(var i:int = 0; i < objectsOfInterest.length; i++)
				ooiUnused.push(objectsOfInterest[i]);
		}
		
		//pick the next object of interest to hunt at random
		public function pickNextOOI():void
		{
			//generate a number [0, 1)
			var randNum:Number = Math.random();
			if(randNum >= 1)
				randNum = 0;
			
			//determine index of next object of interest
			var index:int = int(randNum * ooiUnused.length);
			
			//address chosen object
			currentOOI = ooiUnused[index];
			
			//remove object from list of unused
			ooiUnused.splice(index, 1);
		}
		
		//display the clue of the current object of interest in the clue textfield
		public function displayClue():void
		{
			//if an object is being hunted, display its clue
			if(currentOOI)
			{
				clueText.visible = true;
				clueText.text = currentOOI.getClue();
			}
			//otherwise, notify the user that the hunt has been completed
			else
			{
				clueText.visible = true;
				clueText.text = "All done";
			}
			
			//restart the clue hiding timer
			clueTimer.reset();
			clueTimer.start();
		}
		
		//notify the user that the last attempt at solving the clue was incorrect
		public function displayIncorrect():void
		{
			//display notification
			clueText.visible = true;
			clueText.text = wrongAnswer;
			
			//restart the clue hiding timer
			clueTimer.reset();
			clueTimer.start();
		}
		
		//add all objects whose outlines are visible to a list of bitmaps
		public function addObjectOutlinesToList(bitmapList:Array, texturePointList:Array, samplePoint:Point, useFullsize:Boolean = false)
		{
			for(var i:int = 0; i < objectsOfInterest.length; i++)
				if(objectsOfInterest[i].isOutlined())
					objectsOfInterest[i].addOutlineToList(bitmapList, texturePointList, new Point(samplePoint.x, samplePoint.y), useFullsize);
		}
	}
}