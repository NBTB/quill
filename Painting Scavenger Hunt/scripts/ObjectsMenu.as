package scripts
{
	import flash.display.*;
	import flash.events.*;
	import flash.geom.*;
	import flash.text.*;
	

	class ObjectsMenu extends BaseMenu
	{
		
		private var thisX:int;										//X position of this menu
		private var thisY:int;										//Y position of this menu
		private var thisWidth:int;									//Width of this menu
		private var numObjects:int;									//Number of objects in the painting
		public var curLink:int = 0;									//Which link is next to be updated
		private var linkFormat:TextFormat = new TextFormat();		//Formatting for the links
		public var linksArray:Array = null;							//Array which holds all of the links
		
		//Construct the objects menu, using the base x, y, width, height, and main menu as arguments.  Also sets up the linksArray.
		public function ObjectsMenu(xPos:int, yPos:int, widthVal:int, heightVal:int):void
		{
			//thisX = xPos;					
			thisWidth = widthVal;
			linksArray = new Array();
			super(xPos, yPos, widthVal, heightVal);			//As the objects menu makes it's own background based on the number of objects, send 0's to indicate the background doesn't need making.
		}
		
		//set the Object Manager, set up the initial size of the background for the object menu, then populate the menu with links to each object
		public function setObjectManager(ooiManager:OOIManager):void
		{
			//Determine how many objects are in the manager, and send manager a copy of this
			numObjects = ooiManager.objectsOfInterest.length;
			ooiManager.setObjectMenu(this);
			
			//Set up initial link formatting
			linkFormat.color = 0xFE5E5A;
			linkFormat.font = "Gabriola";
			linkFormat.size = 20;
			
			var tempLink:TextButton;			
			
			var objCount:int = 0;
			
			
			
			//Loop through as many objects as there are, creating non-functional links for each.
			while(objCount < numObjects)
			{
				tempLink = new TextButton(ooiManager.objectsOfInterest[objCount].getObjectName(), linkUnusableFormat, Number(linkUnusableFormat.color), Number(linkUnusableFormat.color), Number(linkUnusableFormat.color));
				tempLink.x = 10;
				tempLink.setHitbox(new Rectangle(-tempLink.x, 0, width - 30, tempLink.height));
				
				linksArray.push(tempLink);
				addContentToTail(tempLink);
				objCount++;
			}		
		}
		
		//An object was clicked for the first time, update the next link to display the object's info.
		public function objectClicked(ooi:ObjectOfInterest):void
		{
			//if there are any more unusable links in the list, find the object's name in the list
			if(curLink < linksArray.length)
			{
				//store name of uppermost, not usable link
				var tempObjName:String = linksArray[curLink].getText();			
				
				//search list
				var ooiName:String = ooi.getObjectName();
				for (var i:int = curLink; i < linksArray.length; i++)
				{
					//if the object name is found, swap the link texts and make the object's new link appear usable
					if (linksArray[i].getText() == ooiName)
					{
						var foundLink:TextButton = linksArray[curLink];
						foundLink.setText(ooiName);
						linksArray[i].setText(tempObjName);
						foundLink.setFormat(BaseMenu.linkUsableFormat);
						foundLink.setColor(TextButton.UP_STATE, textUpColor);
						foundLink.setColor(TextButton.OVER_STATE, textOverColor);
						foundLink.setColor(TextButton.DOWN_STATE, textDownColor);
						
						//Add event listeners to connect the link to the object's pane, close the window, and make the link appear purdy.
						foundLink.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void	
																						   {	
																								closeMenu();	
																								objectLinkClicked(ooi);	
																						   });
						foundLink.addEventListener(MouseEvent.ROLL_OVER, function(e:MouseEvent):void	{	ooi.showHighlight();	});
						foundLink.addEventListener(MouseEvent.ROLL_OUT, function(e:MouseEvent):void		{	ooi.hideHighlight();	});
						
						//move tracker  to next link in list
						curLink++;
					}
				}
			}
		}
		
		//find object of interest in list and make the name stand out in the list
		public function objectSolved(ooi:ObjectOfInterest)
		{
			//ensure that the object has been moved to the top of the list
			objectClicked(ooi);
			
			//accentuate the object's link in the list
			var ooiName:String = ooi.getObjectName();
			for(var i:int = 0; i < curLink; i++)
			{
				if(linksArray[i].getText() == ooiName)
				{
					linksArray[i].setFormat(BaseMenu.linkAccentuatedFormat);
				}
			}
		}
		
		//handle the event of an object of interest link being clicked
		private function objectLinkClicked(ooi:ObjectOfInterest):void
		{
			ooi.getInfoPane().addEventListener(MenuEvent.MENU_CLOSED, paneFromLinkClosed);
			ooi.showInfoPane();
			ooi.showHighlight();
		}
		
		//handle event of object of interest info pane being closed 
		private function paneFromLinkClosed(e:Event):void
		{
			e.target.removeEventListener(MenuEvent.MENU_CLOSED, paneFromLinkClosed);
			
			dispatchEvent(new MenuEvent(this, MenuEvent.SPECIAL_OPEN_REQUEST));
		}
	}
}