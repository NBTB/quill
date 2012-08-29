package scripts
{
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	import flash.geom.*;
	import flash.ui.Mouse;
	
	public class MainMenu extends MovieClip
	{
		private var menuBackground:Shape = new Shape();				//the basic background image
		private var menus:Array = null;								//list of child menus
		private var menuOpeners:Array = null;						//list of child menu opening textfield-buttons
		private var menuTitles:Array = null;						//list of menu names
		private var menuCapacity:int = 0;							//number of menus to fit across bounds
		private var menuCount:int = 0;								//total number of child menus
		private var menuOpenerSize:Point = null;					//dimensions of child menu openers
		private var menuContainer:DisplayObjectContainer = null;	//container of menu panes
		
		var myArrayListeners:Array=[];								//Array of Event Listeners in BaseMenu
		
		//text format of menu opening buttons
		/*private static var menuOpenerTextFormat:TextFormat = new TextFormat("Gabriola", 30, 0xE5E5E5, 
																			null, null, null, null, null, 
																			TextFormatAlign.CENTER);*/
		
		//event types 
		public static const OPEN_MENU = "A menu has opened"			//dispatched when a child menu opens
		public static const CLOSE_MENU = "A menu has closed"		//dispatched when a child menu closes
		
		//construct main menu in a given area, to allow access to a number of menus, and display menus under a given parent
		public function MainMenu(placementRect:Rectangle, menuCapacity:int, menuContainer:DisplayObjectContainer = null)
		{			
			//create arrays for menus, openers, and titles
			menus = new Array();
			menuOpeners = new Array();
			menuTitles = new Array();
			
			//set position
			x = placementRect.x;
			y = placementRect.y;
			
			//store menu capacity (invalid values will default to 1)
			if(menuCapacity < 1)
				menuCapacity = 1;
			this.menuCapacity = menuCapacity;			
			
			//calculate the width of child menu openers
			menuOpenerSize = new Point;
			menuOpenerSize.x = placementRect.width / menuCapacity;
			menuOpenerSize.y = placementRect.height;
			
			//store menu container (use this as default)
			if(!menuContainer)
				menuContainer = this;
			this.menuContainer = menuContainer;
			
			//Set the background graphics
			menuBackground.graphics.lineStyle(1, 0x836A35);
			menuBackground.graphics.beginFill(BaseMenu.menuColor);
			menuBackground.graphics.drawRect(0, 0, placementRect.width, placementRect.height);
			menuBackground.graphics.endFill();
			addChild(menuBackground);
		}
		
		//add menu to the list and give access to it via the menu bar
		public function addChildMenu(menu:BaseMenu, menuTitle:String):Boolean
		{
			//check if the given name is taken already
			var nameUsed:Boolean = false;
			for(var i:int = 0; i < menuTitles.length && !nameUsed; i++)
				nameUsed = (menuTitle == String(menuTitles[i]));
			
			//if the given name is taken, return a failure
			if(nameUsed)
				return false;
			
			//add the menu and menu name to respective lists
			menus.push(menu);
			menuTitles.push(menuTitle);
			
			//create menu opener button using the menu's title
			var menuOpener:TextButton = new TextButton(menuTitle, BaseMenu.textButtonFormat, BaseMenu.textUpColor, BaseMenu.textOverColor, BaseMenu.textDownColor);
			menuOpeners.push(menuOpener);			
			
			//position menu opener
			menuOpener.x = menuOpenerSize.x * ((menuOpeners.length - 1) + 0.5) - menuOpener.width/2;
			menuOpener.y = 0;		
			
			//add menu opener to display list
			addChild(menuOpener);			
			
			//attach the menu to its opener
			menu.addOpener(menuOpener);			
			
			//listen for the opener being clicked
			menuOpener.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void	{	menu.openMenu()	});
			
			//listen for request to close child menus
			menu.addEventListener(MenuEvent.CLOSE_MENUS_REQUEST, function(e:MenuEvent):void	{	closeMenus();	});
			
			//listen for menu opening
			menu.addEventListener(MenuEvent.MENU_OPENED, function(e:MenuEvent):void	{	dispatchEvent(new MenuEvent(e.getTargetMenu(), MenuEvent.MENU_OPENED));	});
			
			//listen for menu closing
			menu.addEventListener(MenuEvent.MENU_CLOSED, function(e:MenuEvent):void	{	dispatchEvent(new MenuEvent(e.getTargetMenu(), MenuEvent.MENU_CLOSED));	});
			
			menuCount++;
			return true;
		}
		
		//add child menus to menu container so that they can be displayed
		public function makeChildMenusDisplayable()
		{
			for(var i:int = 0; i < menus.length; i++)
			{
				menuContainer.addChild(BaseMenu(menus[i]));
				BaseMenu(menus[i]).visible = false;
			}
		}
		
		//close all open menus (except those connected to the optional closeCaller), so there's no overlap when a new one is opened
		public function closeMenus(closeCaller:Object = null):void
		{			
			var anyMenusClosed:Boolean = false;
			for(var i:int = 0; i < menus.length; i++)
			{
				var menu:BaseMenu = BaseMenu(menus[i]);
				if(!closeCaller || (!menu.isObjectOpener(closeCaller) && closeCaller != menu))
				{				
					menu.closeMenu();
				}
			}
		}
		
		//retrieve a child menu based on name
		public function getMenu(menuTitle:String):BaseMenu
		{
			//attempt to find matching name in list
			var menuIndex = -1;
			for(var i:int = 0; i < menuTitles.length && menuIndex < 0; i++)
				if(menuTitle == String(menuTitles[i])) 
					menuIndex = i;
					
			//if no match was found, return a failure
			if(menuIndex < 0)
				return null;
			//otherwise, return the corresponding menu
			else
				return BaseMenu(menus[menuIndex]);
		}
		
		//retrieve a child menu based at a given index
		public function getMenuAtIndex(index:int):BaseMenu
		{
			//if the index is invalid match, return a failure
			if(index < 0 || index >= menuCount)
				return null;
			//otherwise, return the corresponding menu
			else
				return BaseMenu(menus[index]);
		}
		
		public function getMenuCount():int	{	return menuCount;	};
		
		override public function addEventListener (type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void 
		{ 
			super.addEventListener (type, listener, useCapture, priority, useWeakReference);
			myArrayListeners.push({type:type, listener:listener, useCapture:useCapture});
		}
		
		function clearEvents():void 
		{
			//instruct child menus to clear event listeners
			for (var m:Number = 0; m < menus.length; m++)
			{
				BaseMenu(menus[m]).clearEvents();
			}
			
			//clear event listeners
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