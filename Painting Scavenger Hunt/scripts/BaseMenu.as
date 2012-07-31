package
{
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	import flash.geom.*;

	class BaseMenu extends MovieClip
	{
		protected var menuBackground:Shape = null;					//background of menu
		protected var menuMask:Shape = null;						//mask of menu to determine what is seen
		protected var contentContainer:MovieClip = null;			//container of display objects that populate the pane
		protected var closeMenuButton:Sprite = null;				//button to close window
		protected var scrollBar:ScrollBar = null;					//scroll bar used to scroll through pane content
		protected var contentStartPoint:Point = null;				//top-leftmost point of content
		protected var contentEndPoint:Point = null;					//bottom-rightmost point of content
		protected var scrollPoint:Point = null;						//translation of pane content due to scrolling
		protected var paneDimensions:Point = null;					//visible dimensions of pane
		
		protected static var titleFormat:TextFormat = new TextFormat("Arial", 30, 0xffffffff);
		protected static var bodyFormat:TextFormat = new TextFormat("Arial", 20, 0xffffffff);
		protected static var captionFormat:TextFormat = new TextFormat("Arial", 20, 0xffffffff, null, true);
		
		private static var scrollBarStyle = null;
		var theMainMenu:MainMenu;
		
		var isOpen:Boolean;
		
		//event types
		public static const MENU_OPENED = "Menu Opened";
		public static const MENU_CLOSED = "Menu Closed";

		public function BaseMenu(xPos:int, yPos:int, widthVal:int, heightVal:int, theMenu:MainMenu):void
		{
			//if the scroll bar style has not yet been setup, do so now
			if(!scrollBarStyle)
			{
				//create new style
				scrollBarStyle = new ScrollBarStyle();
				
				//load bitmaps to be used by up and down buttons
				var upDownBitmapLoader:ButtonBitmapLoader = new ButtonBitmapLoader();
				upDownBitmapLoader.addEventListener(Event.COMPLETE, function(e:Event):void
																					 {
																						//address loader
																						var bitmapLoader:ButtonBitmapLoader = ButtonBitmapLoader(e.target);
																						
																						//store up-down button states
																						scrollBarStyle.setUpDownButtonState(ScrollBarStyle.UP, bitmapLoader.getUpImage());
																						scrollBarStyle.setUpDownButtonState(ScrollBarStyle.OVER, bitmapLoader.getOverImage());
																						scrollBarStyle.setUpDownButtonState(ScrollBarStyle.DOWN, bitmapLoader.getDownImage());
																						scrollBarStyle.setUpDownButtonState(ScrollBarStyle.HITTEST, bitmapLoader.getHittestImage());								
																					 });
				upDownBitmapLoader.loadBitmaps("../assets/scrollbar up-down button up.png");
				
				//load bitmaps to be used by scroller
				var scrollBitmapLoader:ButtonBitmapLoader = new ButtonBitmapLoader();
				scrollBitmapLoader.addEventListener(Event.COMPLETE, function(e:Event):void
																					 {
																						//address loader
																						var bitmapLoader:ButtonBitmapLoader = ButtonBitmapLoader(e.target);
																						
																						//store up-down button states
																						scrollBarStyle.setScrollerState(ScrollBarStyle.UP, bitmapLoader.getUpImage());
																						scrollBarStyle.setScrollerState(ScrollBarStyle.OVER, bitmapLoader.getOverImage());
																						scrollBarStyle.setScrollerState(ScrollBarStyle.DOWN, bitmapLoader.getDownImage());
																						scrollBarStyle.setScrollerState(ScrollBarStyle.HITTEST, bitmapLoader.getHittestImage());	
																					 });
				scrollBitmapLoader.loadBitmaps("../assets/scrollbar scroller up.png");				
			}
			
			//this.addChild(menuBackground);
			//this.addChild(closeMenuButton);
			isOpen = false;
			
			//position menu
			this.x = xPos;
			this.y = yPos;
			
			//store pane dimensions
			paneDimensions = new Point(widthVal, heightVal);
			
			//draw background
			menuBackground = new Shape();
			addChildAt(menuBackground, 0);
			
			//draw mask
			menuMask = new Shape();
			menuMask.graphics.lineStyle(0);
			menuMask.graphics.beginFill(0x000000);
			menuMask.graphics.drawRect(0, 0, paneDimensions.x, paneDimensions.y);
			menuMask.graphics.endFill();
			addChild(menuMask);
			
			createBackground(paneDimensions.x, paneDimensions.y);
			theMainMenu = theMenu;
			
			//create content container
			contentContainer = new MovieClip();
			contentContainer.mask = menuMask;
			addChild(contentContainer);
			
			//create close button
			closeMenuButton = new Sprite();
			addChild(closeMenuButton);
			createCloseButton(widthVal, heightVal);
			
			//create scroll bar
			scrollBar = new ScrollBar(new Rectangle(width - 20, 50, 10, height - 100), scrollBarStyle, contentContainer.height, paneDimensions.y, 20);
			addChild(scrollBar);
			
			//currently no scrolling is available
			//scrollBar.visible = false;
			contentStartPoint = new Point(0, 0);
			contentEndPoint = new Point(0, 0);
			scrollPoint = new Point(0, 0);
			
			//listen for close button click
			closeMenuButton.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void
																						 {
																							  closeMenu();
																						 });
																							
			//listen for the scrolling of the scroll bar
			scrollBar.addEventListener(ScrollBar.SCROLLED, function(e:Event):void
																			{
																				//compute how much content must be scrolled 
																				var scrollFactor = scrollBar.getScrolledPercentage();
																				scrollFactor *= contentContainer.height;
																				scrollFactor -= scrollPoint.y;
																				
																				//scroll content
																				scrollContent(new Point(0, scrollFactor));
																			});
		}
		
		protected function closeMenu():void
		{
			theMainMenu.closeMenus();
		}
		
		public function createBackground(widthVal:int, heightVal:int):void
		{
			//Set the background graphics
			menuBackground.graphics.lineStyle(1, 0x836A35);
			menuBackground.graphics.beginFill(0x2F2720);
			menuBackground.graphics.drawRect(0, 0, widthVal, heightVal);
			menuBackground.graphics.endFill();
		}
		
		public function createCloseButton(widthVal:int, heightVal:int):void
		{
			closeMenuButton.graphics.lineStyle(1, 0x000000);
			closeMenuButton.graphics.beginFill(0xFF0000);
			closeMenuButton.graphics.drawRect(width-20, 10, 10, 10);
			closeMenuButton.graphics.endFill();
		}
		
		public function addListChild(child:DisplayObject, position:Point = null)
		{				
			//position child and add it to the display list
			if(position)
			{
				child.x = position.x;
				child.y = position.y;
			}
						
			//if the new content is the first content, update the content start point			
			if(contentContainer.numChildren < 1)
			{
				contentStartPoint.x = child.y;
				contentStartPoint.y = child.x;
			}
			//otherwise if the new content appears before all other content, update the content start point
			else
			{
				if(child.x < contentStartPoint.x)
					contentStartPoint.x = child.x;
				if(child.y < contentStartPoint.y)
					contentStartPoint.y = child.y;
			}
			
			//add child to content container
			contentContainer.addChild(child);
			
			//ensure that end point is current
			contentEndPoint.x = contentStartPoint.x + contentContainer.width;
			contentEndPoint.y = contentStartPoint.y + contentContainer.height;
			
			//update scroll bar
			scrollBar.setContentHeight(contentContainer.height);
							
			//if the bottom-rightmost point exceeds the pane's own dimensions, make scrolling possible
			if(contentContainer.height > paneDimensions.y)
				scrollBar.visible = true;			
		}
		
		public function addListChildToTail(child:DisplayObject)
		{
			addListChild(child, new Point(contentStartPoint.x, contentEndPoint.y));
		}
		
		private function scrollContent(distance:Point):void
		{
			//move content
			contentContainer.x -= distance.x;
			contentContainer.y -= distance.y;
			
			//update total scroll distance
			scrollPoint.x += distance.x;
			scrollPoint.y += distance.y;			
		}
		
		public function getContentStartPoint():Point	{	return contentStartPoint;	}
		public function getContentEndPoint():Point	{	return contentEndPoint;	}
	}
}