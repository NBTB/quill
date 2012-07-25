package
{
	import flash.display.*;
	import flash.events.*;
	import flash.geom.Rectangle;
	import flash.geom.Point;
	
	public class ScrollBar extends MovieClip
	{
		private var upButton:SimpleButton = null;
		private var downButton:SimpleButton = null;
		private var scrollButton:SimpleButton = null;			//indicates the current scroll distance and can be dragged (also call scroller)
		private var contentHeight:Number = 0;
		private var visibleHeight:Number = 0;
		private var movementSpeed:Number = 0;
		private var movementFactor:Number = 0;
		private var upDownButtonSize:Point = null;
		private var scrollButtonSize:Point = null;
		
		//event types
		public static const SCROLLED:String = "Scrolled";
		
		public function ScrollBar(fillableRect:Rectangle, style:ScrollBarStyle, contentHeight:Number = 0, visibleHeight = 0)
		{
			//set location
			this.x = fillableRect.x;
			this.y = fillableRect.y;
			
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
			
			//determine dimensions of scroll button
			scrollButtonSize = new Point()
			scrollButtonSize.x = fillableRect.width;
			scrollButtonSize.y = calculateScrollButtonHeight();
			
			//place scroll button
			scrollButton = new SimpleButton();
			scrollButton.x = 0;
			scrollButton.y = upDownButtonSize.y;
			addChild(scrollButton);
			
			upButton.useHandCursor = true;
			
			//create buttons
			updateUpDownButtonStates(style);
			updateScrollButtonStates(style);
			
			//store content height
			this.contentHeight = contentHeight;
			
			//listen for updates to style changes
			style.addEventListener(ScrollBarStyle.UP_DOWN_BUTTON_STATES_CHANGED, function(e:Event):void	{	updateUpDownButtonStates(style);	});
			style.addEventListener(ScrollBarStyle.SCROLL_BUTTON_STATES_CHANGED, function(e:Event):void	{	updateScrollButtonStates(style);	});
			
			//listen for new frames
			addEventListener(Event.ENTER_FRAME, enterFrame);
			
			//listen for up and down buttons being pressed
			upButton.addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent):void	{	moveScroller(-1);	});
			downButton.addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent):void	{	moveScroller(1);	});
			
			//listen for up and down buttons being pressed
			upButton.addEventListener(MouseEvent.MOUSE_UP, function(e:MouseEvent):void		{	stopScroller();	});
			downButton.addEventListener(MouseEvent.MOUSE_UP, function(e:MouseEvent):void	{	stopScroller();	});
			
			
			
			movementSpeed = 5;
		}
		
		private function enterFrame(e:Event)
		{
			scrollButton.y += movementSpeed * movementFactor * scrollerMoveableFactor();
		}
		
		private function moveScroller(movement:Number)
		{
			movementFactor = movement;
			scrollButton.y += movementSpeed * movementFactor * scrollerMoveableFactor();
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
				moveable = (downButton.y - (scrollButton.y + scrollButton.height)) / moveable;
			//otherwise if the movement is negative, check distance to up button
			else if(moveable < 0)
				moveable = ((upButton.y + upButton.height) - scrollButton.y) / moveable;
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
		
		private function updateScrollButtonStates(style:ScrollBarStyle):void
		{
			//get states
			var upState:BitmapData = style.getScrollButtonState(ScrollBarStyle.UP);
			var overState:BitmapData = style.getScrollButtonState(ScrollBarStyle.OVER);
			var downState:BitmapData = style.getScrollButtonState(ScrollBarStyle.DOWN);
			var hittestState:BitmapData = style.getScrollButtonState(ScrollBarStyle.HITTEST);
			
			///update scroll button
			scrollButton.upState = new Bitmap(upState);
			scrollButton.overState = new Bitmap(overState);
			scrollButton.downState = new Bitmap(downState);
			scrollButton.hitTestState = new Bitmap(hittestState);
			scrollButton.width = scrollButtonSize.x;
			scrollButton.height = scrollButtonSize.y;
		}
		
		private function calculateScrollButtonHeight():Number
		{
			//calculate the distance between the up and down buttons
			var calcHeight:Number = downButton.y - (upButton.y + upDownButtonSize.y);
			
			//if the content height is greater than zero, divide the calculated height by it
			if(contentHeight > 0)
				calcHeight /= contentHeight;
			
			//temporary
			calcHeight /= 2;
			
			return calcHeight;
		}
		
		public function getContentHeight():Number	{	return contentHeight;	}
		
		public function setContentHeight(contentHeight:Number):void	
		{	
			//store new content height
			this.contentHeight = contentHeight;	
			
			//resize scroll button reflect change in height
			scrollButtonSize.y = calculateScrollButtonHeight();
			scrollButton.height = scrollButtonSize.y;
		}
	}
}