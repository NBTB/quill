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
		protected var pages:Array = null;							//list of content containers that mimic seperate pages of content
		protected var currentPage:int = -1;							//page to be displayed in menu
		protected var previousPageButton:TextField = null;			//button to move to the previous page of the menu
		protected var nextPageButton:TextField = null;				//button to move to the next page of the menu
		protected var closeMenuButton:SimpleButton = null;			//button to close window
		protected var scrollBar:ScrollBar = null;					//scroll bar used to scroll through pane content
		protected var paneDimensions:Point = null;					//visible dimensions of pane
		protected var openers:Array = null;							//list of objects that would cause the menu to open
		protected var isOpen:Boolean;								//flag if menu is open
		
		
		var myArrayListeners:Array=[];								//Array of Event Listeners in BaseMenu
		
		public static var menuColor:uint = 0x010417;				//color of menu backgroun /*TODO should be read-in through XML*/
		protected static var titleFormat:TextFormat = new TextFormat("Arial", 30, 0xffffffff);
		protected static var bodyFormat:TextFormat = new TextFormat("Arial", 20, 0xffffffff);
		protected static var captionFormat:TextFormat = new TextFormat("Arial", 20, 0xffffffff, null, true);
		protected static var closeButtonLoader:ButtonBitmapLoader = null;
		protected static var scrollBarStyle = null;		
		
		public static const FIRST_PAGE = 0;		//enumeration to conveniently reference the first page
		public static const LAST_PAGE = -1;		//enumeration to conveniently reference the last page
		
		//event types
		public static const MENU_OPENED = "Menu Opened";
		public static const MENU_CLOSED = "Menu Closed";
		public static const CLOSE_MENUS_REQUEST = "Close all menus";
		public static const SPECIAL_OPEN_REQUEST = "Open menu under special circumstances"

		//Sets up variables used by all the menus
		public function BaseMenu(xPos:int, yPos:int, widthVal:int, heightVal:int):void
		{			
			//create previous and next page buttons
			previousPageButton = new TextField();
			previousPageButton.text = "Previous";
			addChild(previousPageButton);
			nextPageButton = new TextField();
			nextPageButton.text = "Previous";
			addChild(nextPageButton);
					
			//create rectangle for close button
			var closeButtonRect:Rectangle = new Rectangle(widthVal - 20, 10, 10, 10);
			
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
			
			//flag the menu as closed
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
						
			//create scroll bar
			scrollBar = new ScrollBar(new Rectangle(width - 20, 30, 10, height - 40), scrollBarStyle, 0, paneDimensions.y, 20);
			addChild(scrollBar);
			
			//create list of pages and add first page
			pages = new Array();
			addPage();
			
			//currently no scrolling is available
			scrollBar.visible = false;
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
				
				//reset scroller position
				scrollBar.resetScroller();
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
		
		public function addPage(pageNumber:int = LAST_PAGE)
		{
			//create new content container to use a page
			var newPage:ContentContainer = new ContentContainer(10, new Rectangle(0, 0, paneDimensions.x, paneDimensions.y), scrollBar, true);
			
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
				removeChild(pages[currentPage]);
				
			//switch to desired page
			var focusPage:ContentContainer = pages[pageNumber];			
			focusPage.mask = menuMask;
			addChild(focusPage);
			currentPage = pageNumber;
			
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
		
		public function addContentToTail(child:DisplayObject, pageNumber:int = LAST_PAGE, displaceContent:Boolean = false)
		{
			//if the page number is not array valid, use the last page
			if(pageNumber < 0 || pageNumber > pages.length)
				pageNumber = pages.length - 1;
			
			//reference the given page
			var contentContainer:ContentContainer = pages[pageNumber];		
			
			//add content to page
			contentContainer.addChildToTail(child, displaceContent);
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