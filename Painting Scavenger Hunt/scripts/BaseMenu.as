package scripts
{
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	import flash.geom.*;
	
	public class BaseMenu extends MovieClip
	{
		protected var menuBackground:Shape = null;					//background of menu
		protected var menuMask:Shape = null;						//mask of menu to determine what is seen
		protected var pages:Array = null;							//list of content containers that mimic seperate pages of content
		protected var currentPage:int = -1;							//page to be displayed in menu
		protected var previousPageButton:TextButton = null;			//button to move to the previous page of the menu
		protected var nextPageButton:TextButton = null;				//button to move to the next page of the menu
		protected var closeMenuButton:SimpleButton = null;			//button to close window
		protected var scrollBar:ScrollBar = null;					//scroll bar used to scroll through pane content
		protected var paneDimensions:Point = null;					//visible dimensions of pane
		protected var openers:Array = null;							//list of objects that would cause the menu to open
		protected var isOpen:Boolean = false;						//flag if menu is open		
		protected var dragCap:Sprite = null;						//bar along the top of the menu that can be used for dragging
		protected var dragged:Boolean = false;						//flag when menu is being dragged
		var rewardCheck:Boolean = false;							//checks to see if the final reward has been one
		protected var baseX:int;									//menu original x position
		protected var baseY:int;									//menu original y position
		
		var myArrayListeners:Array=[];								//Array of Event Listeners in BaseMenu
		
		public static var menuColor:uint = 0;								//default color of menu background 	
		public static var menuBorderColor:uint = 0;							//default color of menu border 	
		public static var menuOpacity:Number = 1;							//default opacity of menu background 
		public static var titleFormat:TextFormat = null;					//text format for titles
		public static var bodyFormat:TextFormat = null;						//text format for body text
		public static var captionFormat:TextFormat = null;					//text format for captions
		public static var textButtonFormat:TextFormat = null;				//text format for up state text in buttons
		public static var linkUsableFormat:TextFormat = null;				//text format for usable links
		public static var linkUnusableFormat:TextFormat = null;				//text format for unusable links
		public static var linkAccentuatedFormat:TextFormat = null;			//text format for links that are special		
		public static var textUpColor:uint = 0;								//color of clickable text in up state
		public static var textOverColor:uint = 0;							//color of clickable text in over state
		public static var textDownColor:uint = 0;							//color of clickable text in down state
		protected static var closeButtonLoader:ButtonBitmapLoader = null;	//loader of close button images
		protected static var scrollBarStyle = null;							//style that holds images for scroll bars
		
		private static const DEFAULT_OPACITY:Number = -1;
		
		public static const FIRST_PAGE = 0;		//enumeration to conveniently reference the first page
		public static const LAST_PAGE = -1;		//enumeration to conveniently reference the last page
		

		//Sets up variables used by all the menus
		public function BaseMenu(xPos:int, yPos:int, widthVal:int, heightVal:int, closeable:Boolean = true, scrollable:Boolean = true, draggable:Boolean = true, opacity:Number = DEFAULT_OPACITY):void
		{			
			//flag the menu as closed
			isOpen = false;
			visible = false;
			
			//start new array of openers
			openers = new Array();
			
			//position menu
			this.x = xPos;
			this.y = yPos;
			
			//set original menu position
			baseX = xPos;
			baseY = yPos;
			
			//store pane dimensions
			paneDimensions = new Point(widthVal, heightVal);
			
			//draw background
			createBackground(widthVal, heightVal, opacity);
		
			//create previous button
			previousPageButton = new TextButton("Preivous", textButtonFormat, textUpColor, textOverColor, textDownColor);
			previousPageButton.x = 5;
			previousPageButton.y = heightVal - 5 - previousPageButton.height;
			addChild(previousPageButton);
			previousPageButton.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void	
																						{	
																							if(currentPage > 0)
																								changePage(currentPage - 1);	
																							rewardCheck = !rewardCheck
																						});
			
			//create next button
			nextPageButton = new TextButton("Next", textButtonFormat, textUpColor, textOverColor, textDownColor);
			nextPageButton.x = widthVal - 5 - nextPageButton.width;
			nextPageButton.y = heightVal - 5 - nextPageButton.height;
			addChild(nextPageButton);
			nextPageButton.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void	
																					{	
																						if(currentPage < pages.length - 1)
																							changePage(currentPage + 1);
																						rewardCheck = !rewardCheck
																					});
			
			//if the close button has not yet been loaded, do so now
			if(!closeButtonLoader)
			{
				closeButtonLoader = new ButtonBitmapLoader();
				closeButtonLoader.loadBitmaps(FileFinder.completePath(FileFinder.INTERFACE, "close button up.png"), FileFinder.completePath(FileFinder.INTERFACE, "close button over.png"), 
											  FileFinder.completePath(FileFinder.INTERFACE, "close button down.png"), FileFinder.completePath(FileFinder.INTERFACE, "close button hit.png"));
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
				upDownBitmapLoader.loadBitmaps(FileFinder.completePath(FileFinder.INTERFACE, "scroll bar up-down button up.png"), FileFinder.completePath(FileFinder.INTERFACE, "scroll bar up-down button over.png"), 
											   FileFinder.completePath(FileFinder.INTERFACE, "scroll bar up-down button down.png"), FileFinder.completePath(FileFinder.INTERFACE, "scroll bar up-down button hit.png"));
				
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
				scrollBitmapLoader.loadBitmaps(FileFinder.completePath(FileFinder.INTERFACE, "scroll bar scroller up.png"));															
			}
			
			//if closeable, create close button
			if(closeable)
			{
				//create rectangle for close button
				var closeButtonRect:Rectangle = new Rectangle(widthVal - 15, 5, 10, 10);
				
				//if the style has begun loading, listen of completion
				if(closeButtonLoader.isLoading())
				{
					closeButtonLoader.addEventListener(Event.COMPLETE, function(e:Event):void	{	createCloseButton(closeButtonRect);	});
				}
				//otherwise, use the loaded style
				else
				{
					createCloseButton(closeButtonRect);
				}
			}
			
			//if draggable add a drag cap
			if(draggable)
			{
				//create drag cap
				dragCap = new Sprite();
				dragCap.graphics.lineStyle(1, 0x836A35);
				dragCap.graphics.beginFill(menuColor);
				dragCap.graphics.drawRect(0, 0, widthVal, 20);
				dragCap.graphics.endFill();
				addChildAt(dragCap, getChildIndex(menuBackground) + 1);
				
				//listen for drag cap being grabbed and released
				dragCap.addEventListener(MouseEvent.MOUSE_DOWN, function(e:Event):void	
																				 {	
																				 	startDrag();
																					dragged = true;
																				 });
				dragCap.addEventListener(MouseEvent.MOUSE_UP, function(e:Event):void	
																			   {	
																			  		stopDrag(); 
																					dragged = false;
																			   });
				
				//listen for drag cap being added to stage
				dragCap.addEventListener(Event.ADDED_TO_STAGE, function(e:Event):void
																				{
																					//listen for mouse movement on stage
																					stage.addEventListener(MouseEvent.MOUSE_MOVE, function(e:MouseEvent):void	
																																						{
																																							//if the primary mouse button is not down, stop dragging
																																							if(dragged && !e.buttonDown)
																																							{
																																								stopDrag();	
																																								dragged = false;
																																							}
																																						});
																				});
			}	
			
			//if the menu is scrollable, create scroll bar
			if(scrollable)
			{
				//if the menu has a drag cap, less of the menu should be available for content
				var dragCapOffset:Number = 0;
				if(dragCap)
					dragCapOffset = dragCap.height;
				
				//create scroll bar
				scrollBar = new ScrollBar(new Rectangle(width - 20, 30, 10, height - 40), scrollBarStyle, 0, paneDimensions.y - dragCapOffset, 30);
				addChild(scrollBar);
				scrollBar.visible = false;
			}
			
			//draw mask
			menuMask = new Shape();
			menuMask.graphics.lineStyle(0);
			menuMask.graphics.beginFill(0x000000);
			if(!draggable)
				menuMask.graphics.drawRect(0, 0, paneDimensions.x, paneDimensions.y);
			else
				menuMask.graphics.drawRect(0, dragCap.height, paneDimensions.x, paneDimensions.y - dragCap.height);
			menuMask.graphics.endFill();
			addChild(menuMask);			
			
			//create list of pages and add first page
			pages = new Array();
			addPage();
		}
		
		//change the origin location for 
		public function changeOrigin(xPos:int, yPos:int)
		{
			baseX = xPos;
			baseY = yPos;
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
				//move back to original position
				x = baseX;
				y = baseY;
				
				//request the closure of other menus to avoid clutter and overlap
				dispatchEvent(new MenuEvent(this, MenuEvent.CLOSE_MENUS_REQUEST));
				
				//appear and open
				visible = true;
				isOpen = true;
				
				//if scroll bar exists, reset scroller position
				if(scrollBar)
					scrollBar.resetScroller();
				
				//announce being opened
				dispatchEvent(new MenuEvent(this, MenuEvent.MENU_OPENED));
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
				
				//if scroll bar exists, reset scroller position
				if(scrollBar)
					scrollBar.resetScroller();
				
				//announce being closed
				dispatchEvent(new MenuEvent(this, MenuEvent.MENU_CLOSED));
			}
			
			return true;
		}
		
		//Set the background graphics
		public function createBackground(widthVal:int, heightVal:int, opacity:Number = DEFAULT_OPACITY):void
		{
			menuBackground = new Shape();
			menuBackground.graphics.lineStyle(1, menuBorderColor);
			menuBackground.graphics.beginFill(menuColor);
			menuBackground.graphics.drawRect(0, 0, widthVal, heightVal);
			menuBackground.graphics.endFill();
			if(opacity < 0)
				menuBackground.alpha = menuOpacity;
			else
				menuBackground.alpha = opacity;
			addChildAt(menuBackground, 0);
		}
		
		public function changeBackgroundColor(newColor:uint, opacity:Number = DEFAULT_OPACITY):void
		{
			var widthVal = menuBackground.width;
			var heightVal = menuBackground.height;
			menuBackground.graphics.clear();
			menuBackground.graphics.lineStyle(1, menuBorderColor);
			menuBackground.graphics.beginFill(newColor);
			menuBackground.graphics.drawRect(0, 0, widthVal, heightVal);
			menuBackground.graphics.endFill();
			if(opacity < 0)
				menuBackground.alpha = menuOpacity;
			else
				menuBackground.alpha = opacity;
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
		
		public function addPage(pageNumber:int = LAST_PAGE)
		{
			//if the menu has a drag cap, less of the menu should be available for content
			var dragCapOffset:Number = 0;
			if(dragCap)
				dragCapOffset = dragCap.height;
			
			//create new content container to use a page
			var newPage:ContentContainer = new ContentContainer(10, new Rectangle(0, dragCapOffset, paneDimensions.x, paneDimensions.y - dragCapOffset), scrollBar, true);
			newPage.y += dragCapOffset;
			
			//if the page number is not array valid, add a new page to the end
			if(pageNumber < 0 || pageNumber > pages.length)
				pages.push(newPage);
			//otherwise, splice the new page in
			else
				pages.splice(pageNumber, 0, newPage);
			
			//switch to new page
			changePage(pageNumber);
		}
		
		public function changePage(pageNumber:int = LAST_PAGE)
		{
			//if the page number is not array valid, use the last page
			if(pageNumber < 0 || pageNumber > pages.length)
				pageNumber = pages.length - 1;
				
			//leave the old page
			if(currentPage >= 0)	
			{
				pages[currentPage].detachScrollBar();
				removeChild(pages[currentPage]);
			}
			
			//switch to desired page
			var focusPage:ContentContainer = pages[pageNumber];			
			focusPage.mask = menuMask;
			addChildAt(focusPage, getChildIndex(menuBackground) + 1);
			currentPage = pageNumber;	
						
			//if scroll bar exists, attach it to the page and reset scrolling
			if(scrollBar)
			{
				pages[currentPage].attachScrollBar(scrollBar);
				scrollBar.resetScroller();
			}
			
			//determine whether or not the previous page button should be shown
			previousPageButton.visible = currentPage > 0;
			
			//determine whether or not the next page button should be shown
			nextPageButton.visible = currentPage < pages.length - 1;
		}
		
		public function addContent(child:DisplayObject, pageNumber:int = LAST_PAGE, position:Point = null)
		{						
			//if the page number is not array valid, use the last page
			if(pageNumber < 0 || pageNumber > pages.length)
				pageNumber = pages.length - 1;
			
			//reference the given page
			var contentContainer:ContentContainer = pages[pageNumber];
		
			//position child and add it to the display list
			if(position)
			{
				child.x = position.x;
				child.y = position.y;
			}
						
			//add content to container
			contentContainer.addChild(child);	
		}
		
		public function addContentToHead(child:DisplayObject, pageNumber:int = FIRST_PAGE, displaceContent:Boolean = true)
		{			
			//if the page number is not array valid, use the last page
			if(pageNumber < 0 || pageNumber > pages.length)
				pageNumber = pages.length - 1;
			
			//reference the given page
			var contentContainer:ContentContainer = pages[pageNumber];		
				
			//add content to page
			contentContainer.addChildToHead(child, displaceContent);	
		}
		
		public function addContentToTail(child:DisplayObject, pageNumber:int = LAST_PAGE)
		{
			//if the page number is not array valid, use the last page
			if(pageNumber < 0 || pageNumber > pages.length)
				pageNumber = pages.length - 1;
			
			//reference the given page
			var contentContainer:ContentContainer = pages[pageNumber];		
			
			//add content to page
			contentContainer.addChildToTail(child);
		}
		
		public function removeContent(child:DisplayObject, pageNumber:int = LAST_PAGE)
		{			
			//container of given content
			var contentContainer:ContentContainer = null;
		
			//if no pageNumber was given attempt, attempt find the one that contains the child
			if(pageNumber < 0)
			{
				for(var i:int = 0; i < pages.length && ! contentContainer; i++)
					if(pages[i].contentResidesHere(child))
						contentContainer = pages[i];
			}
			//otherwise, if the given pageNumber contains the content, reference that page
			else if(pageNumber < pages.length && pages[pageNumber].contentResidesHere(child))
				contentContainer = pages[pageNumber];
			
			//if the content could not be found, return
			if(!contentContainer)
				return;			
			
			//remove content from container
			contentContainer.removeChild(child);
		}
		
		//mark object as a opener of this menu
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
		
		public function isMenuOpen():Boolean	{	return isOpen;	}
		
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