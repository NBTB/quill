package
{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;

	class BaseMenu extends MovieClip
	{
		var menuBackground:Shape = new Shape();			//
		var closeMenuButton:Sprite = new Sprite();		//
		var theMainMenu:MainMenu;						//
		
		var isOpen:Boolean;								//
		
		//event types
		public static const MENU_OPENED = "Menu Opened";
		public static const MENU_CLOSED = "Menu Closed";

		//Sets up variables used by all the menus
		public function BaseMenu(xPos:int, yPos:int, widthVal:int, heightVal:int, theMenu:MainMenu):void
		{
			//Add the background and close button, and make sure it's open
			this.addChild(menuBackground);
			this.addChild(closeMenuButton);
			isOpen = false;
			
			//If the variables read in are not 0, create the background.  Otherwise, let the subclass handle it.
			if (xPos != 0 || yPos != 0 || widthVal != 0 || heightVal != 0)
			{
				createBackground(xPos, yPos, widthVal, heightVal);
			}
			
			//Connection to the root menu
			theMainMenu = theMenu;
			
			//Close button
			closeMenuButton.addEventListener(MouseEvent.MOUSE_DOWN, closeMenu);
		}
		
		//Shut.  Down.  Everything.  (Well, menus, that is.)
		public function closeMenu(event:MouseEvent):void
		{
			theMainMenu.closeMenus();
		}
		
		//Set the background graphics
		public function createBackground(xPos:int, yPos:int, widthVal:int, heightVal:int):void
		{
			menuBackground.graphics.lineStyle(1, 0x836A35);
			menuBackground.graphics.beginFill(0x2F2720);
			menuBackground.graphics.drawRect(xPos, yPos, widthVal, heightVal);
			menuBackground.graphics.endFill();
			createCloseButton(xPos, yPos, widthVal, heightVal);
		}
		
		//Create the button used to close the menu
		public function createCloseButton(xPos:int, yPos:int, widthVal:int, heightVal:int):void
		{
			closeMenuButton.graphics.lineStyle(1, 0x000000);
			closeMenuButton.graphics.beginFill(0xFF0000);
			closeMenuButton.graphics.drawRect(xPos+width-20, yPos+10, 10, 10);
			closeMenuButton.graphics.endFill();
		}
	}
}