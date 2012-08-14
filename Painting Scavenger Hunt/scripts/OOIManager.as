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
		private var ooiHitTestSuppression = false;				//flag if object of interest hit testing is being suppressed
		private var ooiCaptionContainer = null;					//container for object of interest captions
		private var ooiInfoPaneContainer = null;				//container for object of interest info panes
		
		public static const WRONG_ANSWER_NOTIFY:String = "That is not the answer to the riddle"; 				//message that appears in the clue textfield when the wrong clue is guessed
		public static const NO_CLUES_NOTIFY:String = "Wow! You've found a hidden letter!!! No clues remain"; 	//message that appears in the clue textfield when the wrong clue is guessed

		//event types
		public static const CORRECT:String = "The correct answer was given";				//dispatched when a correct answer is given
		public static const INCORRECT:String = "An incorrect answer was given";				//dispatched when an incorrect answer is given
		
		var myArrayListeners:Array=[];								//Array of Event Listeners in BaseMenu
		
		//construct Object of Interest Manager
		public function OOIManager(ooiCaptionContainer:DisplayObjectContainer = null, ooiInfoPaneContainer:DisplayObjectContainer = null)
		{
			//create empty array of objects of interest
			objectsOfInterest = new Array();
			
			//store containers of for object of interest captions and info panes
			if(!ooiCaptionContainer)
				ooiCaptionContainer = this;
			this.ooiCaptionContainer = ooiCaptionContainer;
			if(!ooiInfoPaneContainer)
				ooiInfoPaneContainer = this;
			this.ooiInfoPaneContainer = ooiInfoPaneContainer;
			
			//listen for being added to the display list
			addEventListener(Event.ADDED_TO_STAGE, addedToStage);
		}
		
						
		//add an object of interest to the list
		public function addObjectOfInterest(newObject:ObjectOfInterest)
		{
			//add new object to list
			objectsOfInterest.push(newObject);
			
			//the new object should appear immediately above the other objects (above nothing else)
			var childIndex = objectsOfInterest.length - 1;
			
			//add new object as a display list child
			addChildAt(newObject, childIndex);
			
			//instruct the new object to display its caption and info pane in the specified containers
			newObject.setCaptionContainer(ooiCaptionContainer);
			newObject.setInfoPaneContainer(ooiInfoPaneContainer);
			
			//get the new object's info pane
			var infoPane:OOIInfoPane = newObject.getInfoPane();
			
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
																						newObject.hideHighlight();	
																						newObject.hideCaption();
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
			
			//listen for when an object's info pane is being opened
			infoPane.addEventListener(BaseMenu.MENU_OPENED, function(e:Event):void
																					{	
																						hideAllOOIInfoPanes(e.target);
																						dispatchEvent(new Event(BaseMenu.MENU_OPENED));
																					});
			
			//listen for when an object's info pane is being closed
			infoPane.addEventListener(BaseMenu.MENU_CLOSED, function(e:Event):void
																					{	
																						dispatchEvent(new Event(BaseMenu.MENU_CLOSED));
																					});
			
		}

		private function addedToStage(e:Event)
		{
			for(var i:int; i < objectsOfInterest.length; i++)
			{
				objectsOfInterest[i].setInfoPaneContainer(stage);
			}
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
		
		//hide all captions and info panes of non-ignored objects (except those connected to the optional closeCaller)
		public function hideAllOOIInfoPanes(closeCaller:Object = null)
		{
			//hide each object of interest's info pane
			for(var i = 0; i < objectsOfInterest.length; i++)
			{
				//address the current object of interest and its info pane
				var ooi:ObjectOfInterest = objectsOfInterest[i];
				var infoPane:OOIInfoPane = ooi.getInfoPane();
				
				//if the object's info pane is in the display list and visible, hide it
				if(infoPane.parent && infoPane.visible)
				{					
					//only close if the pane is not connected to the caller of the close
					if(!closeCaller || (!infoPane.isObjectOpener(closeCaller) && closeCaller != infoPane))
						ooi.hideInfoPane();
				}
			}
		}
		
		//suppress or unsuppress hit testing of objects
		public function setAllOOIHitTestSuppression(suppression:Boolean)
		{			
			if(ooiHitTestSuppression != suppression)
			{
				for(var i = 0; i < objectsOfInterest.length; i++)
				{
					objectsOfInterest[i].setHitTestSuppression(suppression);
					objectsOfInterest[i].hideCaption();
					objectsOfInterest[i].hideHighlight();
				}
			}
			ooiHitTestSuppression = suppression;
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
		public function getUsableOOICount():int					{	return usableOOICount;				}
		
		public function setUsableOOICount(count:int):void		{	usableOOICount = count;				}
		
		override public function addEventListener (type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void 
		{ 
			super.addEventListener (type, listener, useCapture, priority, useWeakReference);
			myArrayListeners.push({type:type, listener:listener, useCapture:useCapture});
		}
		
		function clearEvents():void 
		{
			var i:int;
			for (i = 0; i < objectsOfInterest.length; i++)
			{
				objectsOfInterest[i].clearEvents();
			}
			for (i = 0; i < myArrayListeners.length; i++) 
			{
				if (this.hasEventListener(myArrayListeners[i].type)) 
				{
					this.removeEventListener(myArrayListeners[i].type, myArrayListeners[i].listener);
				}
			}
			myArrayListeners=null;
		}
	}
}