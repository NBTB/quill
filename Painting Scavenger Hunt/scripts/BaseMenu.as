package
{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.display.Shape;
	import flash.display.Sprite;
	import flash.events.MouseEvent;

	class BaseMenu extends MovieClip
	{
		var menuBackground:Shape = new Shape();
		var closeMenuButton:Sprite = new Sprite();
		var theMainMenu:MainMenu;
		
		var isOpen:Boolean;
		
		//event types
		public static const MENU_OPENED = "Menu Opened";
		public static const MENU_CLOSED = "Menu Closed";

		public function BaseMenu(xPos:int, yPos:int, widthVal:int, heightVal:int, theMenu:MainMenu):void
		{
			this.addChild(menuBackground);
			this.addChild(closeMenuButton);
			isOpen = false;
			
			createBackground(xPos, yPos, widthVal, heightVal);
			theMainMenu = theMenu;
			
			closeMenuButton.addEventListener(MouseEvent.MOUSE_DOWN, closeMenu);
		}
		
		public function closeMenu(event:MouseEvent):void
		{
			theMainMenu.closeMenus();
		}
		
		public function createBackground(xPos:int, yPos:int, widthVal:int, heightVal:int):void
		{
			//Set the background graphics
			menuBackground.graphics.lineStyle(1, 0x836A35);
			menuBackground.graphics.beginFill(0x2F2720);
			menuBackground.graphics.drawRect(xPos, yPos, widthVal, heightVal);
			menuBackground.graphics.endFill();
			createCloseButton(xPos, yPos, widthVal, heightVal);
		}
		
		public function createCloseButton(xPos:int, yPos:int, widthVal:int, heightVal:int):void
		{
			closeMenuButton.graphics.lineStyle(1, 0x000000);
			closeMenuButton.graphics.beginFill(0xFF0000);
			closeMenuButton.graphics.drawRect(xPos+width-20, yPos+10, 10, 10);
			closeMenuButton.graphics.endFill();
		}
	}
}