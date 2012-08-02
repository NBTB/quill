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
		private var usableOOICount:int = -1;					//maximum number of objects of interest that can be used to finish the hunt (- values denote a use of all)
		private var objectsMenu:ObjectsMenu;					//the objectMenu, used to update said menu when objects are clicked the first time
				
		public static const WRONG_ANSWER_NOTIFY:String = "That is not the answer to the riddle"; 	//message that appears in the clue textfield when the wrong clue is guessed
		public static const NO_CLUES_NOTIFY:String = "Wow! You've found a hidden letter!!! No clues remain"; 							//message that appears in the clue textfield when the wrong clue is guessed
		
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
																						targetObject.showCaption();
																						targetObject.prepareInfoPane();							
																					});

			//listen for when the cursor stops hovering over the new object
			newObject.addEventListener(MouseEvent.MOUSE_OUT, function(e:MouseEvent):void
																					{	
																						if(!testMouseOverOOI(newObject))
																						{
																							newObject.hideHighlight();	
																							newObject.hideCaption();
																						}
																					});
			
			//listen for when the cursor stops hovering over the new object's info Pane
			newObject.getInfoPane().addEventListener(MouseEvent.MOUSE_OUT, function(e:MouseEvent):void
																					{	
																						if(!testMouseOverOOI(newObject))
																						{
																							newObject.hideHighlight();	
																							newObject.hideCaption();
																						}
																					});
			
			//listen for when an object's info pane is being opened
			newObject.addEventListener(OOIInfoPane.OPEN_PANE, function(e:Event):void
																					{	
																						hideAllOOIInfoPanes(new Array(ObjectOfInterest(e.target)));
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
																						ObjectOfInterest(e.target).showInfoPane();
																						if (ObjectOfInterest(e.target).getHasBeenOpened() == false)
																						{
																							ObjectOfInterest(e.target).hasOpened();
																							objectsMenu.objectClicked(ObjectOfInterest(e.target));
																						}
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
			var infoPane:OOIInfoPane = targetOOI.getInfoPane();
			var infoPaneParent:DisplayObjectContainer = infoPane.parent;																						
			
			var mouseOverOOI:Boolean = false;
			var mouseOverDescription:Boolean = false;
			
			if(ooiParent)
				mouseOverOOI = targetOOI.hitTest(new Point(ooiParent.mouseX, ooiParent.mouseY));
			
			if(infoPaneParent)
				mouseOverDescription = infoPane.hitTestPoint(infoPaneParent.mouseX, infoPaneParent.mouseY);
				
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
			//if the maximum number of usable objects of interet is positive or zero, ensure that it does not get exceeded
			if(usableOOICount >= 0)
			{
				//if the maxium number of usable objects of interest has been reached, return a failure
				if(ooiUnused.length < objectsOfInterest.length - usableOOICount)
				{
					currentOOI = null;
					return null;
				}
			}
			//otherwise, ensure that an unused clue remains
			else
			{
				//if the maxium number of usable objects of interest has been reached, return a failure
				if(ooiUnused.length < 1)
				{
					currentOOI = null;
					return null;
				}
			}
				
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
			
			//return turn new clue
			return currentOOI.getClue();
		}
		
		//hide all captions and info panes of non-ignored objects
		public function hideAllOOIInfoPanes(ignoreOOIs:Array = null)
		{
			//hide each object of interest's info pane
			for(var i = 0; i < objectsOfInterest.length; i++)
			{
				//address the current object of interest
				var ooi:ObjectOfInterest = objectsOfInterest[i];
				
				//if the object's info pane is in the display list, hide it
				if(ooi.getInfoPane().parent)
				{
					//determine if the current object of interest should actually be ignored and skipped
					var ignoreOOI:Boolean = false;
					if(ignoreOOIs != null)
						for(var j = 0; j < ignoreOOIs.length && !ignoreOOI; j++)
							if(ooi.getID() == ignoreOOIs[j].getID())
								ignoreOOI = true;
					
					//if the object of interest is not to be ignored, hide its info pane
					if(!ignoreOOI)
						ooi.hideInfoPane();
				}
			}
		}
				
		//add all objects whose highlights are visible to a list of bitmaps
		public function addObjectHighlightsToList(bitmapList:Array, texturePointList:Array, samplePoint:Point, useFullsize:Boolean = false)
		{
			for(var i:int = 0; i < objectsOfInterest.length; i++)
				if(objectsOfInterest[i].isHighlightd())
					objectsOfInterest[i].addHighlightToList(bitmapList, texturePointList, new Point(samplePoint.x, samplePoint.y), useFullsize);
		}
		
		//used to allow the ooiManager to update the ObjectsMenu when an object is clicked the first time.
		public function getObjectMenu(theMenu:ObjectsMenu):void	{	objectsMenu = theMenu;				}
		
		public function getCurrentOOI():ObjectOfInterest		{	return currentOOI;					}
		public function getCurrentClue():String					{	return currentOOI.getClue();		}
		
		public function setUsableOOICount(count:int):void		{	usableOOICount = count;				}
	}
}