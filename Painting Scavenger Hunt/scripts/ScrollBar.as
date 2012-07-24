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
		private var scrollButton:SimpleButton = null;	
		private var contentHeight:Number = 0;
		private var upDownButtonSize:Point = null;
		private var scrollButtonSize:Point = null;
		
		//event types
		public static const SCROLLED:String = "Scrolled";
		
		public function ScrollBar(fillableRect:Rectangle, style:ScrollBarStyle, contentHeight:Number = 0)
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
			
			//create buttons
			updateUpDownButtonStates(style);
			updateScrollButtonStates(style);
			
			//store content height
			this.contentHeight = contentHeight;
			
			//listen for updates to style changes
			style.addEventListener(ScrollBarStyle.UP_DOWN_BUTTON_STATES_CHANGED, function(e:Event):void	{	updateUpDownButtonStates(style);	});
			style.addEventListener(ScrollBarStyle.SCROLL_BUTTON_STATES_CHANGED, function(e:Event):void	{	updateScrollButtonStates(style);	});
			
			/*TODO scrolling*/
		}
		
		private function updateUpDownButtonStates(style:ScrollBarStyle):void 
		{			
			//get states
			var upState:BitmapData = style.getUpDownButtonState(ScrollBarStyle.UP);
			var overState:BitmapData = style.getUpDownButtonState(ScrollBarStyle.OVER);
			var downState:BitmapData = style.getUpDownButtonState(ScrollBarStyle.DOWN);
			var hittestState:BitmapData = style.getUpDownButtonState(ScrollBarStyle.HITTEST);
		
			//update up button
			var upRect:Rectangle = new Rectangle(upButton.x, upButton.y, upButton.width, upButton.height);
			upButton.upState = new Bitmap(upState);
			upButton.overState = new Bitmap(overState);
			upButton.downState = new Bitmap(downState);
			upButton.hitTestState = new Bitmap(hittestState);
			upButton.width = upDownButtonSize.x;
			upButton.height = upDownButtonSize.y;
			
			//update down button
			var downRect:Rectangle = new Rectangle(downButton.x, downButton.y, downButton.width, downButton.height);
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
			
			return calcHeight;
		}
		
		public function getContentHeight():Number	{	return contentHeight;	}
		
		public function setContnetHeight(contentHeight:Number):void	
		{	
			//store new content height
			this.contentHeight = contentHeight;	
			
			//resize scroll button reflect change in height
			scrollButtonSize.y = calculateScrollButtonHeight();
			scrollButton.height = scrollButtonSize.y;
		}
	}
}