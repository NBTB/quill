package scripts
{
	import flash.display.*;
	import flash.events.*;
	import flash.geom.Point;
	import flash.utils.Timer;
	
	public class OOIManager extends MovieClip
	{
		public var objectsOfInterest:Array = null;				//array of objects of interest
		private var ooiUnused:Array = null;						//array of objects of interest that have not yet been used for hunt
		private var currentOOI:ObjectOfInterest = null;			//current object of interest being hunted				
		private var totalOOICount:int = 0;						//total number of objects of interest stored
		private var solvableOOICount:int = -1;					//maximum number of objects of interest that can be used to finish the hunt (- values denote a use of all)
		private var totalFound = 0;								//number of objects found in painting
		private var objectsMenu:ObjectsMenu;					//the objectMenu, used to update said menu when objects are clicked the first time
		private var ooiHitTestSuppression = false;				//flag if object of interest hit testing is being suppressed
		private var ooiCaptionContainer = null;					//container for object of interest captions
		private var ooiInfoPaneContainer = null;				//container for object of interest info panes
		private var incorrectAnswerTimer = null;				//time that allows for double clicking without causing a incorrect answer	

		//event types
		public static const CORRECT:String = "The correct answer was given";				//dispatched when a correct answer is given
		public static const INCORRECT:String = "An incorrect answer was given";				//dispatched when an incorrect answer is given
		public static const ALL_OBJECTS_FOUND = "All objects have been found";				//dispatched when all object (not just those with clues) have been found
		
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
			
			//objects of interest will start of suppressed
			ooiHitTestSuppression = true;
			
			//create timer to start upon an incorrect click
			incorrectAnswerTimer = new Timer(500);
			
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
			totalOOICount++;
			addChildAt(newObject, childIndex);
			
			//instruct the new object to display its caption and info pane in the specified containers
			newObject.setCaptionContainer(ooiCaptionContainer);
			newObject.setInfoPaneContainer(ooiInfoPaneContainer);
			
			//get the new object's info pane
			var infoPane:OOIInfoPane = newObject.getInfoPane();
			
			//suppress the new object's hit tesing
			newObject.setHitTestSuppression(true);
			
			//listen for when the cursor begins to hover over the new object
			newObject.addEventListener(ObjectOfInterest.OOI_MOUSE_OVER, function(e:Event):void
																					{	
																						var targetObject:ObjectOfInterest = ObjectOfInterest(e.target);
																						targetObject.showHighlight();	
																						targetObject.showCaption();
																						targetObject.prepareInfoPane();							
																					});

			//listen for when the cursor stops hovering over the new object
			newObject.addEventListener(ObjectOfInterest.OOI_MOUSE_OUT, function(e:Event):void
																					{	
																						newObject.hideHighlight();	
																						newObject.hideCaption();
																					});
			
			//listen for when the object of interest is clicked
			newObject.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void
																					{	
																						if(currentOOI)
																						{
																							var solvedOOI:ObjectOfInterest = ObjectOfInterest(e.target);
																							if(solvedOOI.getID() == currentOOI.getID())
																							{
																								objectsMenu.objectSolved(solvedOOI);
																								dispatchEvent(new Event(CORRECT));
																							}
																							else
																							{
																								//start a timer to ensure that the object is not being double clicked before dispatching incorrect answer event
																								incorrectAnswerTimer.addEventListener(TimerEvent.TIMER, function(e:Event):void
																																										 {
																																											dispatchEvent(new Event(INCORRECT));
																																											incorrectAnswerTimer.reset();
																																										 });
																								incorrectAnswerTimer.start();
																							}
																						}
																						if (ObjectOfInterest(e.target).getHasBeenOpened() == false)
																						{
																							//link to object in objects menu and add to total found
																							ObjectOfInterest(e.target).hasOpened();
																							objectsMenu.objectClicked(ObjectOfInterest(e.target));
																							totalFound++;
																							if(totalFound >= totalOOICount)
																								dispatchEvent(new Event(ALL_OBJECTS_FOUND));
																						}
																						
																						
																					});
			
			//listen for when the object of interest is double-clicked
			newObject.doubleClickEnabled = true;
			newObject.addEventListener(MouseEvent.DOUBLE_CLICK, function(e:MouseEvent):void
																					{
																						//stop incorrect answer event from being triggering
																						incorrectAnswerTimer.reset();
																						
																						//open the object of interest's info pane
																						ObjectOfInterest(e.target).showInfoPane();
																					});
			
			//listen for when an object's info pane is being opened
			infoPane.addEventListener(MenuEvent.MENU_OPENED, function(e:MenuEvent):void	{	dispatchEvent(new MenuEvent(e.getTargetMenu(), MenuEvent.MENU_OPENED));	});
			
			//listen for when an object's info pane is being closed
			infoPane.addEventListener(MenuEvent.MENU_CLOSED, function(e:MenuEvent):void	{	dispatchEvent(new MenuEvent(e.getTargetMenu(), MenuEvent.MENU_CLOSED));	});
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
			if(solvableOOICount >= 0)
			{
				//if the maxium number of usable objects of interest has been reached, return a failure
				if(ooiUnused.length <= objectsOfInterest.length - solvableOOICount)
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
				if(objectsOfInterest[i].isHighlighted())
					objectsOfInterest[i].addHighlightToList(bitmapList, texturePointList, new Point(samplePoint.x, samplePoint.y), useFullsize);
		}
		
		//add all objects whose found images are visible to a list of bitmaps
		public function addObjectSolvedImagesToList(bitmapList:Array, texturePointList:Array, samplePoint:Point, useFullsize:Boolean = false)
		{
			for(var i:int = 0; i < objectsOfInterest.length; i++)
				if(objectsOfInterest[i].isFound())
					objectsOfInterest[i].addSolvedImageToList(bitmapList, texturePointList, new Point(samplePoint.x, samplePoint.y), useFullsize);
		}		
		
		public function getOOIAtIndex(index:int):ObjectOfInterest
		{
			//if the index is invalid match, return a failure
			if(index < 0 || index >= totalOOICount)
				return null;
			//otherwise, return the corresponding menu
			else
				return ObjectOfInterest(objectsOfInterest[index]);
		}
		public function getCurrentOOI():ObjectOfInterest		{	return currentOOI;					}
		public function getCurrentClue():String					{	return currentOOI.getClue();		}		
		public function getTotalOOICount():int					{	return totalOOICount;				}
		public function getSolvableOOICount():int					{	return solvableOOICount;				}
		
		public function setSolvableOOICount(count:int):void		{	solvableOOICount = count;				}
		public function setObjectMenu(theMenu:ObjectsMenu):void	{	objectsMenu = theMenu;				}
		
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