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

		public function BaseMenu(xPos:int):void
		{
			this.addChild(menuBackground);
			this.addChild(closeMenuButton);
			isOpen = false;
			
			createBackground(xPos);
			
			closeMenuButton.addEventListener(MouseEvent.MOUSE_DOWN, closeMenu);
		}
		
		public function getBaseMenu(theMenu:MainMenu):void
		{
			theMainMenu = theMenu;
		}
		
		public function createBackground(xPos:int):void
		{
			//Set the background graphics
			menuBackground.graphics.lineStyle(1, 0x836A35);
			menuBackground.graphics.beginFill(0x2F2720);
			menuBackground.graphics.drawRect(xPos, 300, 200, 92.5);
			menuBackground.graphics.endFill();
			createCloseButton(xPos);
		}
		
		public function closeMenu(event:MouseEvent):void
		{
			theMainMenu.closeMenus();
		}
		
		public function createCloseButton(xPos):void
		{
			closeMenuButton.graphics.lineStyle(1, 0x000000);
			closeMenuButton.graphics.beginFill(0xFF0000);
			closeMenuButton.graphics.drawRect(xPos+180, 310, 10, 10);
			closeMenuButton.graphics.endFill();
		}
	}
}