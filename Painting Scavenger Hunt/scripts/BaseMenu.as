package
{
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	import flash.geom.*;
	
	public class BaseMenu extends MovieClip
	{
		protected var menuBackground:Shape = null;					//background of menu
		protected var menuMask:Shape = null;						//mask of menu to determine what is seen
		protected var contentContainer:MovieClip = null;			//container of display objects that populate the pane
		protected var closeMenuButton:SimpleButton = null;			//button to close window
		protected var scrollBar:ScrollBar = null;					//scroll bar used to scroll through pane content
		protected var contentStartPoint:Point = null;				//top-leftmost point of content
		protected var contentEndPoint:Point = null;					//bottom-rightmost point of content
		protected var scrollPoint:Point = null;						//translation of pane content due to scrolling
		protected var paneDimensions:Point = null;					//visible dimensions of pane
		protected var openers:Array = null;							//list of objects that would cause the menu to open
		protected var isOpen:Boolean;								//flag if menu is open
		
		var myArrayListeners:Array=[];								//Array of Event Listeners in BaseMenu
		
		protected static var titleFormat:TextFormat = new TextFormat("Arial", 30, 0xffffffff);
		protected static var bodyFormat:TextFormat = new TextFormat("Arial", 20, 0xffffffff);
		protected static var captionFormat:TextFormat = new TextFormat("Arial", 20, 0xffffffff, null, true);
		protected static var closeButtonLoader:ButtonBitmapLoader = null;
		protected static var menuColor:uint;
		
		private static var scrollBarStyle = null;		
		
		//event types
		public static const MENU_OPENED = "Menu Opened";
		public static const MENU_CLOSED = "Menu Closed";
		public static const CLOSE_MENUS_REQUEST = "Close all menus";

		//Sets up variables used by all the menus
		public function BaseMenu(xPos:int, yPos:int, widthVal:int, heightVal:int, menusColor:uint):void
		{			
			//create rectangle for close button
			var closeButtonRect:Rectangle = new Rectangle(widthVal - 20, 10, 10, 10);
			
			menuColor = menusColor;
			
			//if the close button style has not yet been loaded, do so now
			if(!closeButtonLoader)
			{
				closeButtonLoader = new ButtonBitmapLoader();
				closeButtonLoader.addEventListener(Event.COMPLETE, function(e:Event):void	{	createCloseButton(closeButtonRect);	});
				closeButtonLoader.loadBitmaps("../assets/interface/close button up.png", "../assets/interface/close button over.png", 
											  "../assets/interface/close button down.png", "../assets/interface/close button hit.png");
			}
			//otherwise if the style has begun loading, listen of completion
			else if(closeButtonLoader.isLoading())
			{
				closeButtonLoader.addEventListener(Event.COMPLETE, function(e:Event):void	{	createCloseButton(closeButtonRect);	});
			}
			//otherwise, use the loaded style
			else
			{
				createCloseButton(closeButtonRect);
			}
		
			//if the scroll bar style has not yet been loaded, do so now
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
				upDownBitmapLoader.loadBitmaps("../assets/interface/scroll bar up-down button up.png", "../assets/interface/scroll bar up-down button over.png", 
											   "../assets/interface/scroll bar up-down button down.png", "../assets/interface/scroll bar up-down button hit.png");
				
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
				scrollBitmapLoader.loadBitmaps("../assets/interface/scroll bar scroller up.png");															
			}
			
			//Add the background and close button, and make sure it's open
			//this.addChild(menuBackground);
			//this.addChild(closeMenuButton);
			isOpen = false;
			
			//start new array of openers
			openers = new Array();
			
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
			
			//If the variables read in are not 0, create the background.  Otherwise, let the subclass handle it.
			if (xPos != 0 || yPos != 0 || widthVal != 0 || heightVal != 0)
			{
				createBackground(xPos, yPos, widthVal, heightVal);
			}
						
			//create content container
			contentContainer = new MovieClip();
			contentContainer.mask = menuMask;
			addChild(contentContainer);
			
			//create close button
			//closeMenuButton = new Sprite();
			//addChild(closeMenuButton);
			//createCloseButton(xPos, yPos, widthVal, heightVal);
			
			//create scroll bar
			scrollBar = new ScrollBar(new Rectangle(width - 20, 50, 10, height - 100), scrollBarStyle, contentContainer.height, paneDimensions.y, 20);
			addChild(scrollBar);
			
			//currently no scrolling is available
			scrollBar.visible = false;
			contentStartPoint = new Point(0, 0);
			contentEndPoint = new Point(0, 0);
			scrollPoint = new Point(0, 0);
																							
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
		
		//attempt to open this menu and return result
		public function openMenu():Boolean
		{
			//if the menu is already open, return a failure
			if(isOpen)
				return false;
			//otherwise, open now
			else
			{
				//request the closure of other menus to avoid clutter and overlap
				dispatchEvent(new Event(CLOSE_MENUS_REQUEST));
				
				//appear and open
				visible = true;
				isOpen = true;
				
				//announce being opened
				dispatchEvent(new Event(MENU_OPENED));
			}
			
			return true
		}
		
		//attempt to open this menu and return result
		public function closeMenu():Boolean
		{
			//if the menu is not already open, return a failure
			if(!isOpen)
				return false;
			//otherwise, close
			if(isOpen)
			{
				//disappear and close
				visible = false;
				isOpen = false;
				
				//announce being closed
				dispatchEvent(new Event(MENU_CLOSED));
			}
			
			return true;
		}
		
		//Set the background graphics
		public function createBackground(xPos:int, yPos:int, widthVal:int, heightVal:int):void
		{
			menuBackground.graphics.lineStyle(1, 0x836A35);
			menuBackground.graphics.beginFill(menuColor);
			menuBackground.graphics.drawRect(0, 0, widthVal, heightVal);
			menuBackground.graphics.endFill();
		}
		
		//Create the button used to close the menu
		public function createCloseButton(placementRect):void
		{
			//create close button
			closeMenuButton = new SimpleButton(new Bitmap(closeButtonLoader.getUpImage()), 
											   new Bitmap(closeButtonLoader.getOverImage()), 
											   new Bitmap(closeButtonLoader.getDownImage()), 
											   new Bitmap(closeButtonLoader.getHittestImage()));
			
			//position close button
			closeMenuButton.x = placementRect.x;
			closeMenuButton.y = placementRect.y;
			closeMenuButton.width = placementRect.width;
			closeMenuButton.height = placementRect.height;
			addChild(closeMenuButton);
			
			//listen for close button click
			closeMenuButton.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void
																						 {
																							  closeMenu();
																						 });
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
		
		public function addOpener(opener:Object)
		{
			openers.push(opener);
		}
		
		//determine if the given object is an opener of the menu
		public function isObjectOpener(opener:Object)
		{
			//if no opener was given, return a false
			if(!opener)
				return false;
			
			//check caller against list of openers
			var isOpener = false;
			for(var i:int = 0; i < openers.length && ! isOpener; i++)
				isOpener = (opener == openers[i])
				
			return isOpener;
		}
		
		//determine if mouse is in menu bounds
		public function isMouseInBounds()
		{
			return (parent && hitTestPoint(parent.mouseX, parent.mouseY));
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
		
		//changes the text color of the menu buttons to identify which one you're moused over
		public function colorChange(event:MouseEvent):void 
		{
			var sender:TextField=event.target as TextField;
			var myColor:ColorTransform=sender.transform.colorTransform;
			myColor.color=0xCC9933;
			sender.transform.colorTransform=myColor;
		}
		
		//reverts the buttons back to their original colors
		public function revertColor(event:MouseEvent):void 
		{
			var sender:TextField=event.target as TextField;
			var myColor:ColorTransform=sender.transform.colorTransform;	
			myColor.color=0xE5E5E5;		
			sender.transform.colorTransform=myColor;
		}
		
		public function getContentStartPoint():Point	{	return contentStartPoint;	}
		public function getContentEndPoint():Point		{	return contentEndPoint;	}
		public function getMenuColor():uint				{	return menuColor;		}
		
		public static function getTitleFormat():TextFormat		{	return titleFormat;		}
		public static function getBodyFormat():TextFormat		{	return bodyFormat;		}
		public static function getCaptionFormat():TextFormat	{	return captionFormat;	}
		
		
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