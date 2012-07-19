package
{
	import flash.display.*;
	import flash.events.*;
	import flash.geom.Point;
	
	public class OOIManager extends MovieClip
	{
		public var objectsOfInterest:Array = null;				//array of objects of interest
		private var ooiUnused:Array = null;						//array of objects of interest that have not yet been used for hunt
		private var currentOOI:ObjectOfInterest = null;			//current object of interest being hunted				
				
		public static const WRONG_ANSWER_NOTIFY:String = "That is not the answer to the riddle"; 	//message that appears in the clue textfield when the wrong clue is guessed
		public static const NO_CLUES_NOTIFY:String = "No clues remain"; 							//message that appears in the clue textfield when the wrong clue is guessed
		
		//event types
		public static const CORRECT:String = "The correct answer was given";				//dispatched when a correct answer is given
		public static const INCORRECT:String = "An incorrect answer was given";				//dispatched when an incorrect answer is given
		
		//construct Object of Interest Manager
		public function OOIManager()
		{
			//create empty array of objects of interest
			objectsOfInterest = new Array();				
			
			//listen for being added to the display list
			addEventListener(Event.ADDED_TO_STAGE, addedToStage);
		}
		
						
		//add an object of interest to the list
		public function addObjectOfInterest(newObject:ObjectOfInterest)
		{
			//add new object to list
			objectsOfInterest.push(newObject);
			
			//add new object as a display list child
			addChild(newObject);			
			
			//if the manager is part of the display list, direct the new object's placement of caption and description
			if(parent)
			{
				newObject.setCaptionContainer(stage);
				newObject.setDescriptionContainer(stage);
			}
			
			//listen for when the cursor begins to hover over the new object
			newObject.addEventListener(MouseEvent.MOUSE_OVER, function(e:MouseEvent):void
																					{	
																						var targetObject:ObjectOfInterest = ObjectOfInterest(e.target);
																						targetObject.showHighlight();	
																						targetObject.prepareDescription();								
																					});

			//listen for when the cursor stops hovering over the new object
			newObject.addEventListener(MouseEvent.MOUSE_OUT, function(e:MouseEvent):void
																					{	
																						if(!testMouseOverOOI(newObject))
																						{
																							newObject.hideHighlight();	
																							newObject.unprepareDescription();
																						}
																					});
			
			//listen for when the cursor stops hovering over the new object's description pane
			newObject.getDescriptionPane().addEventListener(MouseEvent.MOUSE_OUT, function(e:MouseEvent):void
																					{	
																						if(!testMouseOverOOI(newObject))
																						{
																							newObject.hideHighlight();	
																							newObject.unprepareDescription();
																						}
																					});
			
			
			
			//listen for when the object of interest is clicked
			newObject.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void
																					{	
																						if(currentOOI)
																						{
																							if(ObjectOfInterest(e.target).getID() == currentOOI.getID())
																								dispatchEvent(new Event(CORRECT));
																							else
																								dispatchEvent(new Event(INCORRECT));
																						}
																					});
			
			//listen for when the object of interest is double-clicked
			newObject.doubleClickEnabled = true;
			newObject.addEventListener(MouseEvent.DOUBLE_CLICK, function(e:MouseEvent):void
																					{	
																						ObjectOfInterest(e.target).displayDescription();
																					});
			
		}
		
		private function addedToStage(e:Event)
		{
			for(var i:int; i < objectsOfInterest.length; i++)
			{
				objectsOfInterest[i].setCaptionContainer(stage);
				objectsOfInterest[i].setDescriptionContainer(stage);
			}
		}
		
		//determine whether or not the mouse is hovering over either the object of interest or its description
		private function testMouseOverOOI(targetOOI:ObjectOfInterest):Boolean
		{
			var ooiParent:DisplayObjectContainer = targetOOI.parent;			
			var descriptionPane:OOIDescriptionPane = targetOOI.getDescriptionPane();
			var descriptionPaneParent:DisplayObjectContainer = descriptionPane.parent;																						
			
			var mouseOverOOI:Boolean = false;
			var mouseOverDescription:Boolean = false;
			
			if(ooiParent)
				mouseOverOOI = targetOOI.hitTest(new Point(ooiParent.mouseX, ooiParent.mouseY));
			
			if(descriptionPaneParent)
				mouseOverDescription = descriptionPane.hitTestPoint(descriptionPaneParent.mouseX, descriptionPaneParent.mouseY);
				
			var mouseOverEither = mouseOverOOI || mouseOverDescription;
			return mouseOverEither;
		}
		
		//reset the unused object of interest list so that objects can be re-hunted
		public function resetUnusedOOIList():void
		{
			ooiUnused = new Array();
			for(var i:int = 0; i < objectsOfInterest.length; i++)
				ooiUnused.push(objectsOfInterest[i]);
		}
		
		//pick the next object of interest to hunt at random and return its clue
		public function pickNextOOI():String
		{
			//temporary, stop making clue after 7/10
			if(ooiUnused.length < objectsOfInterest.length - 7 + 1)
			{
				currentOOI = null;
				return null;
			}
			
			//if no objects remain, return a failure
			//if(ooiUnused.length < 1)
			//	return null;
			
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
			
			return currentOOI.getClue();
		}
				
		//add all objects whose highlights are visible to a list of bitmaps
		public function addObjectHighlightsToList(bitmapList:Array, texturePointList:Array, samplePoint:Point, useFullsize:Boolean = false)
		{
			for(var i:int = 0; i < objectsOfInterest.length; i++)
				if(objectsOfInterest[i].isHighlightd())
					objectsOfInterest[i].addHighlightToList(bitmapList, texturePointList, new Point(samplePoint.x, samplePoint.y), useFullsize);
		}
		
		public function getCurrentOOI():ObjectOfInterest	{	return currentOOI;					}
		public function getCurrentClue():String				{	return currentOOI.getClue();		}
	}
}