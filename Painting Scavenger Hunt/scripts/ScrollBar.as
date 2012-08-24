package scripts
{
	import flash.display.*;
	import flash.events.*;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	
	public class ScrollBar extends MovieClip
	{
		private var upButton:SimpleButton = null;				//button used for scrolling up
		private var downButton:SimpleButton = null;				//button used for scrolling down
		private var scroller:DraggableButton = null;			//indicates the current scroll distance and can be dragged
		private var contentHeight:Number = 0;					//total height of content
		private var visibleHeight:Number = 0;					//height visible at any given moment
		private var contentScrollSpeed:Number = 0;				//desired speed of content scolling
		private var movementSpeed:Number = 0;					//speed of scroller 
		private var movementFactor:Number = 0;					//factor of scroller movement (often 1 or -1)
		private var scrolledPercentage:Number = 0;				//portion of full scroll away from rest
		private var upDownButtonSize:Point = null;				//size of up and down buttons
		private var scrollerSize:Point = null;					//size of scroller
		private var scrollerDragged:Boolean = false;			//flag if scroller is being dragged
		private var scrollerBounds:Rectangle = null;			//bounding rectangle of scroller movement		
		protected var scrollerFillsGap:Boolean = false;			//flag if the scroll spans the gap between up and down buttons
		
		var myArrayListeners:Array=[];							//Array of Event Listeners in BaseMenu
		
		//event types
		public static const SCROLLED:String = "Scrolled";
		
		public function ScrollBar(fillableRect:Rectangle, style:ScrollBarStyle, contentHeight:Number = 0, visibleHeight:Number = 0, contentScrollSpeed:Number = 0)
		{
			//set location
			this.x = fillableRect.x;
			this.y = fillableRect.y;
			
			//store total content height and displayable height
			this.contentHeight = contentHeight;
			this.visibleHeight = visibleHeight;
			
			//determine dimensions of up and down buttons
			upDownButtonSize = new Point()
			upDownButtonSize.x = fillableRect.width;
			upDownButtonSize.y = upDownButtonSize.x;
			
			//place up button
			upButton = new SimpleButton();
			upButton.x = 0;
			upButton.y = 0;								
			addChild(upButton);
			
			//place down button
			downButton = new SimpleButton();
			downButton.rotation = 180;
			downButton.x = fillableRect.width;
			downButton.y = fillableRect.height;
			addChild(downButton);
			
			//determine dimensions of scroller
			scrollerSize = new Point()
			scrollerSize.x = fillableRect.width;
			scrollerSize.y = calculateScrollerHeight();
			
			//place scroller
			scroller = new DraggableButton();
			scroller.x = 0;
			scroller.y = upDownButtonSize.y;
			addChild(scroller);
			
			//create bounding rectangle between up and down buttons to be used in scroller dragging
			//note that fillableRect.width is used because this will be both the width and height of the up and down buttons
			var scrollerBoundsStart:Point = new Point (upButton.x, upButton.y + fillableRect.width);
			var scrollerBoundsEnd:Point = new Point (downButton.x, downButton.y - fillableRect.width);
			scrollerBounds = new Rectangle(scrollerBoundsStart.x, scrollerBoundsStart.y, 
														 0, scrollerBoundsEnd.y - scrollerBoundsStart.y);
			
			//store desired content scrolling speed and calcuate the speed of the scroller
			this.contentScrollSpeed = contentScrollSpeed;
			movementSpeed = calculateScrollSpeed();
			
			//attach button images
			updateUpDownButtonStates(style);
			updateScrollerStates(style);			
						
			//disable hand cursor on mouse over
			upButton.useHandCursor = false;
			downButton.useHandCursor = false;
			scroller.useHandCursor = false;
			
			//listen for updates to style changes
			style.addEventListener(ScrollBarStyle.UP_DOWN_BUTTON_STATES_CHANGED, function(e:Event):void	{	updateUpDownButtonStates(style);	});
			style.addEventListener(ScrollBarStyle.SCROLL_BUTTON_STATES_CHANGED, function(e:Event):void	{	updateScrollerStates(style);		});			
			
			//listen for being added to display list
			addEventListener(Event.ADDED_TO_STAGE, addedToStage);			
			
			//listen for new frames
			addEventListener(Event.ENTER_FRAME, enterFrame);
			
			//listen for up and down buttons being pressed
			upButton.addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent):void	{	moveScroller(-1);	});
			downButton.addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent):void	{	moveScroller(1);	});
			
			//listen for up and down buttons being releases
			upButton.addEventListener(MouseEvent.MOUSE_UP, function(e:MouseEvent):void		{	stopScroller();	});
			upButton.addEventListener(MouseEvent.MOUSE_OUT, function(e:MouseEvent):void		{	stopScroller();	});
			downButton.addEventListener(MouseEvent.MOUSE_UP, function(e:MouseEvent):void	{	stopScroller();	});
			downButton.addEventListener(MouseEvent.MOUSE_OUT, function(e:MouseEvent):void	{	stopScroller();	});
			
			//listen for scroller being pressed
			scroller.addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent):void	
																				   {	
																				  	 scroller.startDrag();	
																					 scrollerDragged = true;
																				   });
			
			//listen for scroller being released
			scroller.addEventListener(MouseEvent.MOUSE_UP, function(e:MouseEvent):void		
																				 {	
																				 	scroller.stopDrag();	
																					scrollerDragged = false;
																				 });			
		}
		
		private function addedToStage(e:Event)
		{
			//listen for mouse wheel movement
			stage.addEventListener(MouseEvent.MOUSE_WHEEL, function(e:MouseEvent):void
																	   {
																		   //only respond if visible and on the stage
																		   if(visible && stage)
																		   {
																			   //if the wheel is moved down, scroll down
																			   if(e.delta < 0)
																					moveScroller(1); 
																				//otherwise, if the wheel is moved up, scroll up
																			   	else if(e.delta > 0)
																					moveScroller(-1);
																				
																				//stop scroller after initial movement
																				stopScroller();																													
																		   }
																	   });
			//listen for mouse movement on stage
			stage.addEventListener(MouseEvent.MOUSE_MOVE, function(e:MouseEvent):void	
																				{
																					//if the primary mouse button is not down, stop dragging scroll bar
																					if(scrollerDragged && !e.buttonDown)
																					{
																						scroller.stopDrag();	
																						scrollerDragged = false;
																					}
																				});
		}
		
		private function enterFrame(e:Event)
		{			
			if(visible)
			{
				//clamp scoller to its bounds
				scroller.x = upButton.x;
				var maxScrollerHeight:Number = (downButton.y - downButton.height) - (upButton.y + upButton.height);
				if(scroller.height >= maxScrollerHeight)
				{
					scroller.height = maxScrollerHeight;
					scroller.y = upButton.y + upButton.height;
					scrollerFillsGap = true;
				}			
				else
				{
					scrollerFillsGap = false;
					if(scroller.x != scrollerBounds.x)
						scroller.x = scrollerBounds.x;
					if(scroller.y < scrollerBounds.y)
						scroller.y = scrollerBounds.y;
					else if(scroller.y > scrollerBounds.y + scrollerBounds.height - scroller.height)
						scroller.y = scrollerBounds.y + scrollerBounds.height - scroller.height;				
				}
				
				//if scroller is being dragged, track it
				if(scrollerDragged)
				{					
					//dispatch scroll event
					scrolledPercentage = calculateScrolledPercentage();
					dispatchEvent(new Event(SCROLLED));
				}
				
				//calculate the amount of movement
				var totalMovement:Number = movementSpeed * movementFactor * scrollerMoveableFactor();
				
				//if any movement is happening, update scroller and dispatch event
				if(totalMovement && !scrollerFillsGap)
				{
					scroller.y += totalMovement;
					scrolledPercentage = calculateScrolledPercentage();
					dispatchEvent(new Event(SCROLLED));
				}			
			}
		}
		
		private function moveScroller(movement:Number)
		{
			movementFactor = movement;
			scroller.y += movementSpeed * movementFactor * scrollerMoveableFactor();
			scrolledPercentage = calculateScrolledPercentage();
			dispatchEvent(new Event(SCROLLED));
		}
		
		private function stopScroller()
		{
			movementFactor = 0;
		}
		
		public function resetScroller()
		{
			scroller.y = upButton.y + upButton.height;
			scrolledPercentage = calculateScrolledPercentage();
			dispatchEvent(new Event(SCROLLED));
		}
		
		private function scrollerMoveableFactor()
		{
			//determine raw movement
			var moveable = movementSpeed * movementFactor;
			
			//if the movement is positive, check distance to down button
			if(moveable > 0)
				moveable = (downButton.y - downButton.height - (scroller.y + scroller.height)) / moveable;
			//otherwise if the movement is negative, check distance to up button
			else if(moveable < 0)
				moveable = ((upButton.y + upButton.height) - scroller.y) / moveable;
			//otherwise, fully moveable
			else
				moveable = 1;
			
			//clamp the moveable factor [0, 1]
			if(moveable < 0)
				moveable = 0;
			else if(moveable > 1)
				moveable = 1;
			
			return moveable;
		}
		
		private function updateUpDownButtonStates(style:ScrollBarStyle):void 
		{			
			//get states
			var upState:BitmapData = style.getUpDownButtonState(ScrollBarStyle.UP);
			var overState:BitmapData = style.getUpDownButtonState(ScrollBarStyle.OVER);
			var downState:BitmapData = style.getUpDownButtonState(ScrollBarStyle.DOWN);
			var hittestState:BitmapData = style.getUpDownButtonState(ScrollBarStyle.HITTEST);
		
			//update up button
			upButton.upState = new Bitmap(upState);
			upButton.overState = new Bitmap(overState);
			upButton.downState = new Bitmap(downState);
			upButton.hitTestState = new Bitmap(hittestState);
			upButton.width = upDownButtonSize.x;
			upButton.height = upDownButtonSize.y;
			
			//update down button
			downButton.upState = new Bitmap(upState);
			downButton.overState = new Bitmap(overState);
			downButton.downState = new Bitmap(downState);
			downButton.hitTestState = new Bitmap(hittestState);
			downButton.width = upDownButtonSize.x;
			downButton.height = upDownButtonSize.y;
		}
		
		private function updateScrollerStates(style:ScrollBarStyle):void
		{
			//get states
			var upState:BitmapData = style.getScrollerState(ScrollBarStyle.UP);
			var overState:BitmapData = style.getScrollerState(ScrollBarStyle.OVER);
			var downState:BitmapData = style.getScrollerState(ScrollBarStyle.DOWN);
			var hittestState:BitmapData = style.getScrollerState(ScrollBarStyle.HITTEST);
			
			///update scroller
			scroller.upState = new Bitmap(upState);
			scroller.overState = new Bitmap(overState);
			scroller.downState = new Bitmap(downState);
			scroller.hitTestState = new Bitmap(hittestState);
			scroller.width = scrollerSize.x;
			scroller.height = scrollerSize.y;
		}
		
		private function calculateScrollerHeight():Number
		{
			//calculate the distance between the up and down buttons
			var calcHeight:Number = downButton.y - downButton.height - (upButton.y + upDownButtonSize.y);
						
			//if both the total content height and displayable height are positive, use the ratio to determine scroller height
			if(contentHeight > 0 && visibleHeight > 0)
			{
				var visibleTotalRatio:Number = visibleHeight/contentHeight;				
				if(visibleTotalRatio < 1)
					calcHeight *= visibleTotalRatio;
			}
				
			return calcHeight;
		}
		
		private function calculateScrollSpeed():Number
		{
			//compute the two extremes that are reachable by the top of the scroll bar
			var startPoint:Number = upButton.y + upDownButtonSize.y;			
			var endPoint:Number = downButton.y - downButton.height - scrollerSize.y;
			
			//calculate the moveable space of the scroller
			var calcHeight:Number = endPoint - startPoint;
			
			//if both the total content height and content scroll speed are positive, use the ratio to determine scroller movement speed
			var speed:Number = 0;
			if(contentHeight > 0 && contentScrollSpeed > 0)
				speed = calcHeight * contentScrollSpeed/contentHeight;
				
			return speed;
		}
		
		private function calculateScrolledPercentage():Number
		{
			//compute the two extremes that are reachable by the top of the scroll bar
			var startPoint:Number = upButton.y + upDownButtonSize.y;			
			var endPoint:Number = downButton.y - downButton.height - scrollerSize.y;
			
			//if the end point is at or behind the start point, return invalid
			if(endPoint <= startPoint)
				return -1;
			
			//compute percentage of scroll
			var percentage = (scroller.y - startPoint) / (endPoint - startPoint)
			return percentage;
		}
		
		public function getContentHeight():Number		{	return contentHeight;		}
		public function getVisibleHeight():Number		{	return visibleHeight;		}
		public function getContentScrollSpeed():Number	{	return contentScrollSpeed;	}
		public function getScrolledPercentage():Number	{	return scrolledPercentage;	}
		
		public function setContentHeight(contentHeight:Number):void	
		{	
			//store new content height
			this.contentHeight = contentHeight;	
			
			//resize scroller reflect change in height
			scrollerSize.y = calculateScrollerHeight();
			scroller.height = scrollerSize.y;
			
			//calculate scroller movement speed
			movementSpeed = calculateScrollSpeed();
		}
		public function setVisibleHeight(visibleHeight:Number):void	
		{
			//store new visible height
			this.visibleHeight = visibleHeight;	
			
			//resize scroller reflect change in height
			scrollerSize.y = calculateScrollerHeight();
			scroller.height = scrollerSize.y;
		}		
		public function setContentScrollSpeed(contentScrollSpeed:Number):void	
		{
			//store new visible height
			this.contentScrollSpeed = contentScrollSpeed;	
			
			//calculate scroller movement speed
			movementSpeed = calculateScrollSpeed();
		}
		
		override public function addEventListener (type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void 
		{ 
			super.addEventListener (type, listener, useCapture, priority, useWeakReference);
			myArrayListeners.push({type:type, listener:listener, useCapture:useCapture});
		}
		
		function clearEvents():void 
		{
			for (var i:Number=0; i < myArrayListeners.length; i++) 
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