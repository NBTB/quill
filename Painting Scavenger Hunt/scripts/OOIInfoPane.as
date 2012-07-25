package
{
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class OOIInfoPane extends MovieClip
	{
		private var menuBackground:Shape = null;					//background of menu
		private var menuMask:Shape = null;							//mask of menu to determine what is seen
		private var contentContainer:MovieClip = null;				//container of display objects that populate the pane
		private var closeMenuButton:Sprite = null;					//button to close window
		private var scrollBar = null;								//scroll bar used to scroll through pane content
		private var scrollPoint:Point = null;						//translation of pane content due to scrolling
		private var paneDimensions:Point = null;					//visible dimensions of pane
		
		private static var titleFormat:TextFormat = new TextFormat("Arial", 30, 0xffffffff);
		private static var bodyFormat:TextFormat = new TextFormat("Arial", 20, 0xffffffff);
		private static var captionFormat:TextFormat = new TextFormat("Arial", 20, 0xffffffff, null, true);
		
		private static var scrollBarStyle = null;
		
		//event types
		public static const OPEN_PANE = "Open Pane";
		public static const CLOSE_PANE = "Close Pane";
		
		public function OOIInfoPane(x:Number, y:Number, width:Number, height:Number)
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
			
			//position pane
			this.x = x;
			this.y = y;
			
			//store pane dimensions
			paneDimensions = new Point(width, height);
			
			//draw background
			menuBackground = new Shape();
			menuBackground.graphics.lineStyle(1, 0x836A35);
			menuBackground.graphics.beginFill(0x2F2720);
			menuBackground.graphics.drawRect(0, 0, paneDimensions.x, paneDimensions.y);
			menuBackground.graphics.endFill();
			addChildAt(menuBackground, 0);
			
			//draw mask
			menuMask = new Shape();
			menuMask.graphics.lineStyle(0);
			menuMask.graphics.beginFill(0x000000);
			menuMask.graphics.drawRect(0, 0, paneDimensions.x, paneDimensions.y);
			menuMask.graphics.endFill();
			addChild(menuMask);
			
			//create content container
			contentContainer = new MovieClip();
			contentContainer.mask = menuMask;
			addChild(contentContainer);
			
			//create close button
			closeMenuButton = new Sprite();
			addChild(closeMenuButton);
			createCloseButton();
			
			//create scroll bar
			scrollBar = new ScrollBar(new Rectangle(width - 20, 50, 10, height - 100), scrollBarStyle, contentContainer.height, paneDimensions.y, 20);
			addChild(scrollBar);
			
			//currently no scrolling is available
			scrollBar.visible = false;
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
		
		private function createCloseButton():void
		{
			closeMenuButton.graphics.lineStyle(1, 0x000000);
			closeMenuButton.graphics.beginFill(0xFF0000);
			closeMenuButton.graphics.drawRect(width - 20, 10, 10, 10);
			closeMenuButton.graphics.endFill();
		}
				
		private function closeMenu():void
		{
			dispatchEvent(new Event(CLOSE_PANE));
		}
		
		public function addListChild(child:DisplayObject, position:Point = null)
		{				
			//position child and add it to the display list
			if(position)
			{
				child.x = position.x;
				child.y = position.y;
			}
						
			//add child to content container
			contentContainer.addChild(child);
			
			//update scroll bar
			scrollBar.setContentHeight(contentContainer.height);
							
			//if the bottom-rightmost point exceeds the pane's own dimensions, make scrolling possible
			if(contentContainer.height > paneDimensions.y)
				scrollBar.visible = true;			
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
		
		public static function getTitleFormat():TextFormat		{	return titleFormat;		}
		public static function getBodyFormat():TextFormat		{	return bodyFormat;		}
		public static function getCaptionFormat():TextFormat	{	return captionFormat;	}
	}
}