package
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.text.TextField;
	import flash.display.Shape;
	import flash.events.MouseEvent;
	import flash.text.TextFormat;
	import flash.geom.ColorTransform;

	class ObjectsMenu extends BaseMenu
	{
		
		private var thisX:int;										//X position of this menu
		private var thisY:int;										//Y position of this menu
		private var thisWidth:int;									//Width of this menu
		private var numObjects:int;									//Number of objects in the painting
		private var curLink:int = 0;								//Which link is next to be updated
		private var linkFormat:TextFormat = new TextFormat();		//Formatting for the links
		private var linksArray:Array = null;						//Array which holds all of the links
		
		//Construct the objects menu, using the base x, y, width, height, and main menu as arguments.  Also sets up the linksArray.
		public function ObjectsMenu(xPos:int, yPos:int, widthVal:int, heightVal:int):void
		{
			//thisX = xPos;					
			//thisWidth = widthVal;
			linksArray = new Array();
			super(xPos, yPos, widthVal, heightVal);			//As the objects menu makes it's own background based on the number of objects, send 0's to indicate the background doesn't need making.
		}
		
		//get the Object Manager, set up the initial size of the background for the object menu, then populate the menu with links to each object
		public function getObjectManager(ooiManager:OOIManager):void
		{
			//Determine how many objects are in the manager, and send manager a copy of this
			numObjects = ooiManager.objectsOfInterest.length;
			ooiManager.getObjectMenu(this);
			
			//Determine location of menu, then create background
			//thisY = 515-(numObjects*42);
			//createBackground(thisX, thisY, thisWidth, numObjects * 42);
			
			//Set up initial link formatting
			linkFormat.align = "center";
			linkFormat.color = 0xFE5E5A;
			linkFormat.font = "Gabriola";
			linkFormat.size = 20;
			
			var tempLink:TextField;			
			
			var objCount:int = 0;
			
			//Loop through as many objects as there are, creating non-functional links for each.
			while(objCount < numObjects)
			{
				objCount ++;
				tempLink = new TextField;
				tempLink.x = thisX + 20;
				tempLink.y = thisY - 20 + (40*objCount);
				tempLink.height = 35;
				tempLink.width = thisWidth - 40;
				tempLink.text = "???";
				tempLink.selectable = false;
				tempLink.setTextFormat(linkFormat);
				linksArray.push(tempLink);
				addContent(tempLink);
			}		
		}
		
		//An object was clicked for the first time, update the next link to display the object's info.
		public function objectClicked(ooi:ObjectOfInterest):void
		{
			linkFormat.color = 0xE5E5E5;
			linkFormat.align = "left";
			linksArray[curLink].text = ooi.getObjectName();
			linksArray[curLink].setTextFormat(linkFormat);
			
			//Add event listeners to connect the link to the object's pane, close the window, and make the link appear purdy.
			linksArray[curLink].addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent):void	{	objectLinkClicked(ooi);	});
			linksArray[curLink].addEventListener(MouseEvent.MOUSE_DOWN, function(e:Event):void	{	closeMenu();	});
			linksArray[curLink].addEventListener(MouseEvent.ROLL_OVER, function(e:MouseEvent):void
																							 {
																								 colorChange(e);
																								 ooi.showHighlight();
																							 });
			linksArray[curLink].addEventListener(MouseEvent.ROLL_OUT, function(e:MouseEvent):void
																							 {
																								 revertColor(e);
																								 ooi.hideHighlight();
																							 });
			
			curLink++;
		}
		
		//handle the event of a object of interest link being clicked
		private function objectLinkClicked(ooi:ObjectOfInterest):void
		{
			ooi.getInfoPane().addEventListener(MenuEvent.MENU_CLOSED, paneFromLinkClosed);
			ooi.showInfoPane();
			ooi.showHighlight();
		}
		
		private function paneFromLinkClosed(e:Event):void
		{
			e.target.removeEventListener(MenuEvent.MENU_CLOSED, paneFromLinkClosed);
			
			dispatchEvent(new MenuEvent(this, MenuEvent.SPECIAL_OPEN_REQUEST));
		}
	}
}