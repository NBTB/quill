﻿package
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
		private var menuCapacity:Number = 0;						//number of menus to fit across bounds
		private var menuOpenerSize:Point = null;					//dimensions of child menu openers
		private var menuContainer:DisplayObjectContainer = null;
		
		public var rewardCounter:Number = 0;						//???	/*TODO this should be a part of letter menu*/
		
		private static var menuOpenerTextFormat:TextFormat = new TextFormat("Gabriola", 30, 0xE5E5E5, 
																			null, null, null, null, null, 
																			TextFormatAlign.CENTER);
		
		//event types 
		public static const OPEN_MENU = "A menu has opened"
		public static const CLOSE_MENU = "A menu has closed"
		
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
			menuBackground.graphics.beginFill(0x2F2720);
			menuBackground.graphics.drawRect(0, 0, placementRect.width, placementRect.height);
			menuBackground.graphics.endFill();
		}
		
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
			var menuOpener:TextField = new TextField();
			menuOpener.defaultTextFormat = menuOpenerTextFormat;
			menuOpener.text = menuTitle;
			menuOpener.selectable = false;
			menuOpeners.push(menuOpener);			
			
			//position menu opener
			menuOpener.x = menuOpenerSize.x * (menuOpeners.length - 1);
			menuOpener.y = 0;
			menuOpener.width = menuOpenerSize.x;
			menuOpener.height = menuOpenerSize.y;
			
			//add menu opener to display list
			addChild(menuOpener);			
			
			//attach the menu to its opener
			menu.addOpener(menuOpener);			
			
			//listen for the opener being clicked
			menuOpener.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void	
																				{	
																					menu.openMenu();
																					dispatchEvent(new Event(OPEN_MENU));
																				});
			
			//listen for the mouse hovering over the opener and hovering out of the openers bounds
			menuOpener.addEventListener(MouseEvent.ROLL_OVER, menu.colorChange);
			menuOpener.addEventListener(MouseEvent.ROLL_OUT, menu.revertColor);			
			
			//listen for request to close child menus
			menu.addEventListener(BaseMenu.CLOSE_MENUS_REQUEST, function(e:Event):void	{	closeMenus();	});
			
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
			for(var i:int = 0; i < menus.length; i++)
			{
				var menu:BaseMenu = BaseMenu(menus[i]);
				if(!closeCaller || !menu.isObjectOpener(closeCaller))
				{					
					/*TODO this should go in BaseMenu's closeMenu*/
					menu.isOpen = false;
					menu.visible = false;
					menu.dispatchEvent(new Event(BaseMenu.MENU_CLOSED));
					dispatchEvent(new Event(CLOSE_MENU));
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
	}
}