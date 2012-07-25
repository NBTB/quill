﻿package
{
	import flash.display.*;
	import flash.events.*;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	
	public class ScrollBar extends MovieClip
	{
		private var upButton:SimpleButton = null;
		private var downButton:SimpleButton = null;
		private var scroller:SimpleButton = null;			//indicates the current scroll distance and can be dragged
		private var contentHeight:Number = 0;
		private var visibleHeight:Number = 0;
		private var contentScrollSpeed:Number = 0;				//desired speed of content scolling
		private var movementSpeed:Number = 0;					//speed of scroller 
		private var movementFactor:Number = 0;					//factor of scroller movement (often 1 or -1)
		private var scrolledPercentage:Number = 0;				//portion of full scroll away from rest
		private var upDownButtonSize:Point = null;
		private var scrollerSize:Point = null;
		
		//event types
		public static const SCROLLED:String = "Scrolled";
		
		public function ScrollBar(fillableRect:Rectangle, style:ScrollBarStyle, contentHeight:Number = 0, visibleHeight = 0, contentScrollSpeed = 0)
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
			downButton.x = 0;
			downButton.y = fillableRect.height - downButton.height;
			addChild(downButton);
			
			//determine dimensions of scroller
			scrollerSize = new Point()
			scrollerSize.x = fillableRect.width;
			scrollerSize.y = calculateScrollerHeight();
			
			//place scroller
			scroller = new SimpleButton();
			scroller.x = 0;
			scroller.y = upDownButtonSize.y;
			addChild(scroller);
			
			//store desired content scrolling speed and calcuate the speed of the scroller
			this.contentScrollSpeed = contentScrollSpeed;
			movementSpeed = calculateScrollSpeed();
			
			//make buttons use hand cursor when hovered over
			upButton.useHandCursor = true;
			downButton.useHandCursor = true;
			//scroller.useHandCursor = true;
			
			//attach button images
			updateUpDownButtonStates(style);
			updateScrollerStates(style);			
			
			//listen for updates to style changes
			style.addEventListener(ScrollBarStyle.UP_DOWN_BUTTON_STATES_CHANGED, function(e:Event):void	{	updateUpDownButtonStates(style);	});
			style.addEventListener(ScrollBarStyle.SCROLL_BUTTON_STATES_CHANGED, function(e:Event):void	{	updateScrollerStates(style);	});
			
			//listen for new frames
			addEventListener(Event.ENTER_FRAME, enterFrame);
			
			//listen for up and down buttons being pressed
			upButton.addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent):void	{	moveScroller(-1);	});
			downButton.addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent):void	{	moveScroller(1);	});
			
			//listen for up and down buttons being pressed
			upButton.addEventListener(MouseEvent.MOUSE_UP, function(e:MouseEvent):void		{	stopScroller();	});
			downButton.addEventListener(MouseEvent.MOUSE_UP, function(e:MouseEvent):void	{	stopScroller();	});
		}
		
		private function enterFrame(e:Event)
		{
			var totalMovement:Number = movementSpeed * movementFactor * scrollerMoveableFactor();
			if(totalMovement)
			{
				scroller.y += totalMovement;
				scrolledPercentage = calculateScrolledPercentage();
				dispatchEvent(new Event(SCROLLED));
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
		
		private function scrollerMoveableFactor()
		{
			//determine raw movement
			var moveable = movementSpeed * movementFactor;
			
			//if the movement is positive, check distance to down button
			if(moveable > 0)
				moveable = (downButton.y - (scroller.y + scroller.height)) / moveable;
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
			var calcHeight:Number = downButton.y - (upButton.y + upDownButtonSize.y);
						
			//if both the total content height and displayable height are positive, use the ratio to determine scroller height
			if(contentHeight > 0 && visibleHeight > 0)
				calcHeight *= visibleHeight/contentHeight;
				
			return calcHeight;
		}
		
		private function calculateScrollSpeed():Number
		{
			//compute the two extremes that are reachable by the top of the scroll bar
			var startPoint:Number = upButton.y + upDownButtonSize.y;			
			var endPoint:Number = downButton.y - scrollerSize.y;
			
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
			var endPoint:Number = downButton.y - scrollerSize.y;
			
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
	}
}