package
{
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.text.TextField;
	import flash.display.Shape;
	import flash.text.TextFormat;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;
	import flash.ui.Mouse;
	import flash.display.Sprite;

	class MainMenu extends MovieClip
	{
		var menuBackground:Shape = new Shape();						//The basic background image
		
		var menuButtonHelp:TextField = new TextField();				//Help Button
		var menuButtonClues:TextField = new TextField();			//Clues Button
		var menuButtonRestart:TextField = new TextField();			//Restart Button
		var menuButtonLetter:TextField = new TextField();			//Letter Button
		var menuButtonObjects:TextField = new TextField();			//Objects Button
		
		var recTransform:ColorTransform;							//Allows for changing of text colors.
				
		public var helpMenu:HelpMenu;								//Help menu
		public var cluesMenu:CluesMenu;								//Clues menu
		public var letterMenu:LetterMenu;							//Letter menu
		public var objectsMenu:ObjectsMenu;							//Objects menu
		public var restartMenu:RestartMenu;							//Restart menu
		
		public var letterRec:Shape;									//???
		public var rewardCounter:Number = 0;						//???
		
		var menuButtonFormat:TextFormat = new TextFormat();			//Formatting for the buttons
		
		var buttonY:int = 517;										//Y location of the menu
		
		//Create the main menu
		public function MainMenu(startWTutorial:Boolean/*, theInitiator:GameInitiator*/):void
		{			
			//Create the 5 sub-menus
			helpMenu = new HelpMenu(5, 350, 120, 165);
			cluesMenu = new CluesMenu(100, 400, 220, 115);
			letterMenu = new LetterMenu(75, 0, 600, 515);
			objectsMenu = new ObjectsMenu(370, 50, 170, 465);
			restartMenu = new RestartMenu (200, 150, 375, 200);
			
			//Add the buttons and background as children
			this.addChild(menuBackground);
			this.addChild(menuButtonHelp);
			this.addChild(menuButtonClues);
			this.addChild(menuButtonLetter);
			this.addChild(menuButtonObjects);
			this.addChild(menuButtonRestart);
			
			//add buttons as menu openers
			helpMenu.addOpener(menuButtonHelp);
			cluesMenu.addOpener(menuButtonClues);
			letterMenu.addOpener(menuButtonLetter);
			objectsMenu.addOpener(menuButtonObjects);			
			restartMenu.addOpener(menuButtonRestart);
			
			//Something to do with the letter.
			letterRec = new Shape();
			letterRec.graphics.beginFill(0x00CCFF); 
			letterRec.graphics.drawRect(422, buttonY, 162, 65); 
			letterRec.graphics.endFill();
			letterRec.visible = false;
			addChild(letterRec); 
			
			//Set up the background and button formatting
			createBackground();
			formatText();
			
			menuButtonHelp.selectable = false;
			menuButtonClues.selectable = false;
			menuButtonLetter.selectable = false;
			
			//restartMenu.addInitiator(theInitiator);
			
			//Add event listeners to the buttons to open their respective menus
			menuButtonHelp.addEventListener(MouseEvent.CLICK, clickHelpMenu);
			menuButtonClues.addEventListener(MouseEvent.CLICK, clickCluesMenu);
			menuButtonLetter.addEventListener(MouseEvent.CLICK, clickLetterMenu);
			menuButtonObjects.addEventListener(MouseEvent.CLICK, clickObjectsMenu);
			menuButtonRestart.addEventListener(MouseEvent.CLICK, clickRestartMenu);
			
			//listen for mouse movement to highlight menus
			menuButtonHelp.addEventListener(MouseEvent.ROLL_OVER, helpMenu.colorChange);
			menuButtonHelp.addEventListener(MouseEvent.ROLL_OUT, helpMenu.revertColor);			
			menuButtonClues.addEventListener(MouseEvent.ROLL_OVER, cluesMenu.colorChange);
			menuButtonClues.addEventListener(MouseEvent.ROLL_OUT, cluesMenu.revertColor);			
			menuButtonLetter.addEventListener(MouseEvent.ROLL_OVER, letterMenu.colorChange);
			menuButtonLetter.addEventListener(MouseEvent.ROLL_OUT, letterMenu.revertColor);			
			menuButtonObjects.addEventListener(MouseEvent.ROLL_OVER, objectsMenu.colorChange);
			menuButtonObjects.addEventListener(MouseEvent.ROLL_OUT, objectsMenu.revertColor);			
			menuButtonRestart.addEventListener(MouseEvent.ROLL_OVER, restartMenu.colorChange);
			menuButtonRestart.addEventListener(MouseEvent.ROLL_OUT, restartMenu.revertColor);
			
			//listen for when the main menu is added to the stage
			addEventListener(Event.ADDED_TO_STAGE, function(e:Event):void
																	{
																		//listen for request to close menus
																		helpMenu.addEventListener(BaseMenu.CLOSE_MENUS_REQUEST, function(e:Event):void	{	closeMenus();	});
																		cluesMenu.addEventListener(BaseMenu.CLOSE_MENUS_REQUEST, function(e:Event):void	{	closeMenus();	});
																		letterMenu.addEventListener(BaseMenu.CLOSE_MENUS_REQUEST, function(e:Event):void	{	closeMenus();	});
																		objectsMenu.addEventListener(BaseMenu.CLOSE_MENUS_REQUEST, function(e:Event):void	{	closeMenus();	});
																		restartMenu.addEventListener(BaseMenu.CLOSE_MENUS_REQUEST, function(e:Event):void	{	closeMenus();	});
																	});
		}
		
		//formatting for the menu buttons
		function formatText():void
		{
			menuButtonFormat.align = "center";
			menuButtonFormat.color = 0xE5E5E5;
			menuButtonFormat.font = "Gabriola";
			menuButtonFormat.size = 30;
			
			menuButtonHelp.y = buttonY;
			menuButtonHelp.x = 0;
			menuButtonHelp.height = 50;
			menuButtonHelp.width = 130;
			menuButtonHelp.text = "Help";
			menuButtonHelp.selectable = false;
			
			menuButtonClues.y = buttonY;
			menuButtonClues.x = 130;
			menuButtonClues.height = 50;
			menuButtonClues.width = 130;
			menuButtonClues.text = "Clues";
			menuButtonClues.selectable = false;
			
			menuButtonLetter.y = buttonY;
			menuButtonLetter.x = 260;
			menuButtonLetter.height = 50;
			menuButtonLetter.width = 130;
			menuButtonLetter.text = "Letter";
			menuButtonLetter.selectable = false;
			
			menuButtonObjects.y = buttonY;
			menuButtonObjects.x = 390;
			menuButtonObjects.height = 50;
			menuButtonObjects.width = 130;
			menuButtonObjects.text = "Objects";
			menuButtonObjects.selectable = false;
			
			menuButtonRestart.y = buttonY;
			menuButtonRestart.x = 520;
			menuButtonRestart.height = 50;
			menuButtonRestart.width = 130;
			menuButtonRestart.text = "Restart";
			menuButtonRestart.selectable = false;
			
			menuButtonHelp.setTextFormat(menuButtonFormat);
			menuButtonClues.setTextFormat(menuButtonFormat);
			menuButtonLetter.setTextFormat(menuButtonFormat);
			menuButtonObjects.setTextFormat(menuButtonFormat);
			menuButtonRestart.setTextFormat(menuButtonFormat);
		}
		
		//Get the object manager for the objects menu
		public function getObjectManager(ooiManager:OOIManager)
		{
			objectsMenu.getObjectManager(ooiManager);
		}
		
		//notifies the letter
		function letterNotifyer():void
		{
			
		}
				
		//Tells the cluesMenu which clue to activate, possibly redundant
		function activateClue():void
		{
			
		}
		
		//Open the clues menu
		function openCluesMenu():void
		{
			closeMenus();
			this.addChild(cluesMenu);
			cluesMenu.isOpen = true;
			cluesMenu.dispatchEvent(new Event(BaseMenu.MENU_OPENED));
		}
		
		//Tells the cluesMenu when to activate
		function clickCluesMenu(event:MouseEvent):void
		{
			openCluesMenu();
		}
		
		//Opens the letter menu
		function openLetterMenu():void
		{
			closeMenus();
			this.addChild(letterMenu);
			letterMenu.isOpen = true;
			letterMenu.dispatchEvent(new Event(BaseMenu.MENU_OPENED));
			
			//the first piece of letter is always available
			//if(letterMenu.pieces.length > 0)
			//	letterMenu.pieces[0].visible = true;
		
			//when a new letter piece is rewarded, make it visible in the lette menu
			for(var i:Number = 0; i < rewardCounter; i++)
			{
				//trace(letterMenu.pieces[i].pieceName);
				letterMenu.pieces[i].visible = true;							
			}
			//if the search is over, you find the hidden letter!
			//the other pieces become invisible 
			if(rewardCounter == 8 && letterMenu.pieces[7].visible == true)
			{
			
				letterMenu.nextButton.visible = true;
                letterMenu.pieces[0].visible = false; 
				letterMenu.pieces[1].visible = false; 
				letterMenu.pieces[2].visible = false; 
				letterMenu.pieces[3].visible = false; 
				letterMenu.pieces[4].visible = false; 
				letterMenu.pieces[5].visible = false; 
				letterMenu.pieces[6].visible = false; 			 
				
            
			}
		}
		
		//Tells the letterMenu when to activate
		function clickLetterMenu(event:MouseEvent):void
		{
			openLetterMenu();
		}
		
		//opens the help menu
		function openHelpMenu():void
		{
			closeMenus();
			this.addChild(helpMenu);
			helpMenu.isOpen = true;
			helpMenu.dispatchEvent(new Event(BaseMenu.MENU_OPENED));
		}
		
		//Tells the helpMenu when to activate
		function clickHelpMenu(event:MouseEvent):void
		{
			openHelpMenu();
		}
		
		//opens the objects menu
		function openObjectsMenu():void
		{
			closeMenus();
			this.addChild(objectsMenu);
			objectsMenu.isOpen = true;
			objectsMenu.dispatchEvent(new Event(BaseMenu.MENU_OPENED));
		}
		
		//Tells the objectsMenu when to activate
		function clickObjectsMenu(event:MouseEvent):void
		{
			openObjectsMenu();
		}
		
		//opens the restart menu
		function openRestartMenu():void
		{
			closeMenus();
			this.addChild(restartMenu);
			restartMenu.isOpen = true;
			restartMenu.dispatchEvent(new Event(BaseMenu.MENU_OPENED));
		}
		
		//tells the restartMenu when to activate
		function clickRestartMenu(event:MouseEvent):void
		{
			openRestartMenu();
		}
		
		//Close all open menus (except those connected to the optional closeCaller), so there's no overlap when a new one is opened.
		//Always called when a new menu is opened
		function closeMenus(closeCaller:Object = null):void
		{
			if (helpMenu.isOpen == true)
			{
				if(!closeCaller || !helpMenu.isObjectOpener(closeCaller))
				{
					helpMenu.isOpen = false;
					removeChild(helpMenu);
					helpMenu.dispatchEvent(new Event(BaseMenu.MENU_CLOSED));
				}
			}
			if (objectsMenu.isOpen == true)
			{
				if(!closeCaller || !objectsMenu.isObjectOpener(closeCaller))
				{
					objectsMenu.isOpen = false;
					removeChild(objectsMenu);
					objectsMenu.dispatchEvent(new Event(BaseMenu.MENU_CLOSED));
				}
			}
			if(cluesMenu.isOpen == true)
			{
				if(!closeCaller || !cluesMenu.isObjectOpener(closeCaller))
				{
					cluesMenu.isOpen = false;
					removeChild(cluesMenu);
					cluesMenu.dispatchEvent(new Event(BaseMenu.MENU_CLOSED));
				}
			}
			if(letterMenu.isOpen == true)
			{
				if(!closeCaller || !letterMenu.isObjectOpener(closeCaller))
				{
					letterMenu.isOpen = false;
					removeChild(letterMenu);
					letterMenu.dispatchEvent(new Event(BaseMenu.MENU_CLOSED));
				}
			}
			
			if(restartMenu.isOpen == true)
			{
				if(!closeCaller || !restartMenu.isObjectOpener(closeCaller))
				{
					restartMenu.isOpen = false;
					removeChild(restartMenu);
					restartMenu.dispatchEvent(new Event(BaseMenu.MENU_CLOSED));
				}
			}
		}
		
		//Set the background graphics
		function createBackground():void
		{
			//Set the background graphics
			menuBackground.graphics.lineStyle(1, 0x836A35);
			menuBackground.graphics.beginFill(0x2F2720);
			menuBackground.graphics.drawRect(0, buttonY, 764, 55);
			menuBackground.graphics.endFill();
		}
	}
}