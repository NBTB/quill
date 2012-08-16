package
{
	import flash.display.*;
	import flash.events.*;
	import flash.ui.Keyboard;
	import flash.geom.Point;
	import flash.geom.Rectangle;	
	import flash.text.*;
	import flash.utils.Timer;
	import flash.ui.Mouse;
		
	public class ScavengerHunt extends MovieClip
	{
		private var importer:HuntImporter = null;				//importer used to load start-up and hunt
		private var startGameListener:MenuListener;				//Listener to determine when the main game should begin
		private var paintingCanvas:PaintingCanvas = null;		//The class that displays the painting 
		private var ooiManager:OOIManager = null;				//Object which keeps track of objects in the painting
		private var startUpScreen:SplashScreen;					//Splash screen which displays when program is first started
		private var mainMenu:MainMenu;							//The main menu displayed beneath the painting
		private var openedMenus:Array = null;					//list of currently open menus
		private var zoomed:Boolean = false;						//flag tracking whether or not the magnifying glass is active
		private var magnifyingGlass:MagnifyingGlass;			//magnifying glass used to enlarge portions of the scene
		private var magnifyButton:SimpleButton = null;			//button that toggles magnifying glass
		private var clueTimer:Timer = null;						//timer used to trigger the hiding of the clue textfield
		private var clueText:TextField = new TextField(); 		//textfield to hold a newly unlocked clue
		private var needNewClue:Boolean = false;				//flag that tracks whether or not a new clue is needed
		private var clueTextFormat:TextFormat;				 	//text format of the clue textfield
		private var pauseEvents:Boolean = false;				//flag if certain events should be paused
		public var ending:Ending;								//the menu displayed when you win
		
		var cluesMenu:CluesMenu = new CluesMenu(0, 0, 765, 55);
		var endGoalMenu:LetterMenu = new LetterMenu(765, 0, 500, 630);	
		
		//main menu titles
		private var helpMenuTitle:String = "Help";			//title of help menu
		private var cluesMenuTitle:String = "Clues";		//title of clues menu
		private var endGoalMenuTitle:String = "Letter";		//title of end goal menu
		private var objectsMenuTitle:String = "Objects";	//title of objects menu		
		private var restartMenuTitle:String = "Restart";	//title of restart menu
		
		var myArrayListeners:Array=[];						//Array of Event Listeners in BaseMenu
		
		//construct scavanger hunt
		public function ScavengerHunt():void
		{
			//initiator = theInitiator;		
			startMenu();			
		}
		
		//Begins the game, by first displaying the opening splash screen menus.  Also listens for when the splash screen is finished
		public function startMenu():void
		{						
			//load start-up information and listen for completion
			importer = new HuntImporter();
			importer.addEventListener(HuntImporter.START_UP_LOADED, function(e:Event):void
																					 {
																						startGameListener = new MenuListener();
																						startUpScreen = new SplashScreen(startGameListener);
																						
																						addChild(startUpScreen);
																						startGameListener.addEventListener(MenuListener.GAME_START, function(e:Event):void	{	initGame();	});
																					 });
			importer.importStartUp("start-up params.xml");
			
			
		}
		
		//When splash screen ends, set up the rest of the game.
		public function initGame():void
		{					
			//create in-game children that will handle specific interaction
			paintingCanvas = new PaintingCanvas(0, 56, 765, 574);
			ooiManager = new OOIManager(this, this);
			magnifyingGlass = new MagnifyingGlass();
			mainMenu = new MainMenu(new Rectangle(0, 574, 764, 55), 4, this);
			clueText = new TextField();
			magnifyButton = new SimpleButton();
			
			//setup clue text format
			clueTextFormat = new TextFormat("Times New Roman", 25, 0x40E0D0);
			clueTextFormat.align = TextFormatAlign.CENTER;
			
			//set clue textfield location and settings
			clueText.defaultTextFormat = clueTextFormat;
			clueText.wordWrap=true;
			clueText.x=150;
			clueText.y=90;
			clueText.width=474;
			clueText.visible = false;
			clueText.selectable = false;
			clueText.mouseEnabled = false;
			
			var magnifyButtonLoader:ButtonBitmapLoader = new ButtonBitmapLoader();
			magnifyButtonLoader.addEventListener(Event.COMPLETE, function(e:Event):void
																					   {
																						   //setup next clue button
																							magnifyButton = new SimpleButton(new Bitmap(magnifyButtonLoader.getUpImage()), 
																																new Bitmap(magnifyButtonLoader.getOverImage()), 
																																new Bitmap(magnifyButtonLoader.getDownImage()), 
																																new Bitmap(magnifyButtonLoader.getHittestImage()));
																							magnifyButton.x = 645;
																							magnifyButton.y = 581;
																							magnifyButton.width /= 5;
																							magnifyButton.height /= 5;
																							magnifyButton.visible = true;
																					   });
			magnifyButtonLoader.loadBitmaps("../assets/interface/magnify button up.png", "../assets/interface/magnify button over.png", 
											"../assets/interface/magnify button down.png", "../assets/interface/magnify button hittest.png");
			
			
			/*TODO menu creation and addition to main menu should be put in functions*/
			//create menus to appear in main menu
			var helpMenu:HelpMenu = new HelpMenu(5, 240, 120, 330);
			var objectsMenu:ObjectsMenu = new ObjectsMenu(370, 50, 170, 465);					
			var restartMenu:RestartMenu = new RestartMenu (200, 150, 375, 200);
			
			//load hunt information and listen for completion
			importer.addEventListener(Event.COMPLETE, function(e:Event):void{	startGame();	});
			importer.importHunt("scavenger hunt params.xml", paintingCanvas, ooiManager, magnifyingGlass, endGoalMenu, objectsMenu, startUpScreen);
			
			//add menus to main menu
			mainMenu.addChildMenu(helpMenu, helpMenuTitle);
			mainMenu.addChildMenu(objectsMenu, objectsMenuTitle);
			mainMenu.addChildMenu(restartMenu, restartMenuTitle);
			
			//create ending
			ending = new Ending(0, 0, stage.stageWidth, stage.stageHeight);
			ending.returnButton.addEventListener(MouseEvent.MOUSE_DOWN, returnBack);
		}
		
		//Actually begin the rest of the game
		public function startGame():void
		{			
			//remove pre-game children from display list
			removeChild(startUpScreen);
						
			//add in-game children to display list,
			//ensuring that they are tightly packed on the bottom layers
			var childIndex:int = 0;
			addChildAt(paintingCanvas, childIndex++);
			addChildAt(ooiManager, childIndex++);
			addChildAt(mainMenu, childIndex++);
			addChildAt(magnifyingGlass, childIndex++);
			addChildAt(clueText, childIndex++);	
			addChildAt(magnifyButton, childIndex++);
			
			addChild(endGoalMenu);				
			endGoalMenu.removeCloseButton();
			addChild(cluesMenu);			
			cluesMenu.removeCloseButton();
			
			//add listeners for when in-game children are clicked
			addDismissibleOverlayCloser(paintingCanvas);
			addDismissibleOverlayCloser(ooiManager);
			addDismissibleOverlayCloser(mainMenu);
			addDismissibleOverlayCloser(magnifyingGlass);
			addDismissibleOverlayCloser(magnifyButton);
			
			//make menus inside main menu displayable
			mainMenu.makeChildMenusDisplayable();	
			
			//give OOIManager reference to objects menu
			var objectsMenu:ObjectsMenu = ObjectsMenu(mainMenu.getMenu(objectsMenuTitle));
			objectsMenu.getObjectManager(ooiManager);	
			
			//listen for a request to open objects menu after object of interest info pane closure
			objectsMenu.addEventListener(MenuEvent.SPECIAL_OPEN_REQUEST, function(e:MenuEvent):void
																							 {
																								//if events that depend on all other menus being closed are allowed, open
																								if(!pauseEvents)
																									objectsMenu.openMenu();																								
																							 });
			
			
			
			//listen for restart
			RestartMenu(mainMenu.getMenu(restartMenuTitle)).addEventListener(RestartEvent.RESTART_GAME, function(e:RestartEvent):void	
																																{	
																																	dispatchEvent(e);	
																																	clearEvents();
																																});

			//create list of opened menus
			openedMenus = new Array();
			
			//mask the magnifying glass so that it is not drawn beyond the painting
			magnifyingGlass.mask = paintingCanvas.getPaintingMask();
			
			//create clue timer
			clueTimer = new Timer(10 * 1000, 1);
			
			//listen for the completion of the clue timer
			clueTimer.addEventListener(TimerEvent.TIMER, function(e:TimerEvent):void
																		  {
																			hideClueText();
																		  });			
			
			//prepare new list of unused objects of interest and pick the first object
			ooiManager.resetUnusedOOIList();
			var firstClue:String = ooiManager.pickNextOOI();
			cluesMenu.addClue(firstClue);
			
			//listen for correct answers to clues
			ooiManager.addEventListener(OOIManager.CORRECT, handleCorrectAnswer);
			
			//listen for incorrect answers to clues
			ooiManager.addEventListener(OOIManager.INCORRECT, handleIncorrectAnswer);
			
			//listen for an object of interest's info pan to open and close
			ooiManager.addEventListener(MenuEvent.MENU_OPENED, function(e:MenuEvent):void	{	menuOpened(e.getTargetMenu())	});
			ooiManager.addEventListener(MenuEvent.MENU_CLOSED, function(e:MenuEvent):void	{	menuClosed(e.getTargetMenu())	});
			
			//listen for a menu to open and close
			mainMenu.addEventListener(MenuEvent.MENU_OPENED, function(e:MenuEvent):void	{	menuOpened(e.getTargetMenu())	});
			mainMenu.addEventListener(MenuEvent.MENU_CLOSED, function(e:MenuEvent):void	{	menuClosed(e.getTargetMenu())	});
			
			//listen for the magnify button being clicked
			magnifyButton.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void	
																					{	
																						toggleZoom();
																					});
			
			
			//listen for new frame
			addEventListener(Event.ENTER_FRAME, checkEnterFrame);
			
			//listen for input events
			stage.focus = stage;
			stage.addEventListener(KeyboardEvent.KEY_UP, checkKeysUp);
		}		
		
		//handle new frame
		public function checkEnterFrame(e:Event):void
		{			
			//if the magnifying glass is being used, draw through its lens
            if(zoomed)
			{
                placeMagnifyingGlass(new Point(mouseX, mouseY));
			}
		}		
		
		//handles the release of keys
		public function checkKeysUp(e:KeyboardEvent):void
		{
			//toggle magnifying glass
			if(e.keyCode == Keyboard.SPACE)
			{
				closeDismissibleOverlays(magnifyButton);
				toggleZoom();
			}
		}
		
		//handle the openeing of a menu
		private function menuOpened(targetMenu:BaseMenu)
		{
			//disallow actions that depend on all menus being closed
			allowEventsOutsideMenu(false);
			
			//
			openedMenus.push(targetMenu);
		}
		
		//handle the closing of a menu
		private function menuClosed(targetMenu:BaseMenu)
		{
			//if the given menu is being tracking as open, remove it from the list
			var indexOfMenu = openedMenus.indexOf(targetMenu)
			if(indexOfMenu >= 0)
				openedMenus.splice(indexOfMenu, 1);
				
			//if all opened menus have been closed, allow actions that depend on all menus being closed
			if(openedMenus.length < 1)
				allowEventsOutsideMenu(true);
		}
		
		private function allowEventsOutsideMenu(allowEvents:Boolean):void
		{
			//flag the pause/unpause of certain events
			pauseEvents = !allowEvents;
						
			//if events are not allowed, setup special states
			if(!allowEvents)
			{
				hideClueText();
				toggleZoom(true, false);
				ooiManager.setAllOOIHitTestSuppression(true);
			}
			//otherwise, revert to normal states
			else
			{
				ooiManager.setAllOOIHitTestSuppression(false);
			}
		}
		
		//toggle use of magnifying glass
		public function toggleZoom(forceResult:Boolean = false, forceTo:Boolean = false):void
		{
			//if the result is to be forced, do so
			if(forceResult)
				zoomed = forceTo;
			//otherwise, toggle zoom
			else
				zoomed = !zoomed && !pauseEvents;
			
			//if zoom started, draw magnifying glass
			if(zoomed)
			{
				placeMagnifyingGlass(new Point(mouseX, mouseY));
				magnifyingGlass.visible = true;
			}
			//otherwise, remove magnifying glass
			else
			{
				magnifyingGlass.visible = false;
			}
		}	
		
		//place the magnifying glass over the scene and magnify affected bitmaps
		public function placeMagnifyingGlass(center:Point):void
		{
			//place the magnifying glass so that its center is within the canvas bounds
			var canvasBounds:Rectangle = new Rectangle(x + paintingCanvas.x, y + paintingCanvas.y, paintingCanvas.width, paintingCanvas.height);
			center = magnifyingGlass.place(center, canvasBounds);			
			
			//create arrays to pass to magnifying glass
			var bitmaps:Array = new Array();
			var texturePoints:Array = new Array();
			
			//add magnified canvas
			paintingCanvas.addPaintingToList(bitmaps, texturePoints, new Point(center.x - paintingCanvas.x, center.y - paintingCanvas.y), true);
			
			//add magnified object highlights
			ooiManager.addObjectHighlightsToList(bitmaps, texturePoints, center, true);
			
			//magnify
			magnifyingGlass.magnifyBitmaps(bitmaps, texturePoints);
		}
		
		//handle a correct answer to a clue
		private function handleCorrectAnswer(e:Event)
		{			
			//hide the current clue
			hideClueText();
			
			//post feedback
			postToClueText("Correct!");
		
			//close menus
			mainMenu.closeMenus();
		
			//attempt to pick the next object to hunt and retrieve its clue
			var nextClue:String = ooiManager.pickNextOOI();			
			
			//if a new clue was picked, display it and pass it to the clues menu
			if(nextClue)
			{				
				//add the piece of the end goal
				var completionRequirement:int = ooiManager.getUsableOOICount();
				endGoalMenu.unlockReward(completionRequirement, LetterMenu.NEXT_REWARD);
			
				//make the current clue old
				cluesMenu.outdateCurrentClue();
				
				//add new clue to clue menu
				cluesMenu.addClue(nextClue);
			}
			//otherwise, end the game
			else
			{
				//add a new page to the end goal menu and show final reward
				endGoalMenu.addPage();
				endGoalMenu.unlockFinalReward();				
				
				//post notification
				postToClueText(OOIManager.NO_CLUES_NOTIFY);
				
				//show ending
				addChild(ending);
			}
		}
		
		//handle a incorrect answer to a clue
		private function handleIncorrectAnswer(e:Event)
		{	
			postToClueText("Try Again");
		}
		
		//display the next clue
		private function showNextClue():void
		{
			//post the new clue to the clue textfield
			postToClueText(ooiManager.getCurrentClue());			
		}
		
		//display clue text in textfield on screen
		private function postToClueText(textToPost:String)
		{				
			//display notification
			clueText.visible = true;
			clueText.text = textToPost;
			
			//restart the clue hiding timer
			clueTimer.reset();
			clueTimer.start();
		}
		
		//reset clue time and hide the clue text box
		private function hideClueText()
		{
			
			clueTimer.reset();
			clueText.text = ""
			clueText.visible = false;
		}
		
		//add event listener to list that will trigger the closing of dismissible overlays
		private function addDismissibleOverlayCloser(closer:DisplayObject, eventType:String = MouseEvent.CLICK):void
		{
			closer.addEventListener(eventType, function(e:Event):void	{	closeDismissibleOverlays(e.target);	});
		}
		
		//close overlays that are to be dismissed by a click anywhere else on screen
		private function closeDismissibleOverlays(caller:Object):void
		{					
			//close all menus
			mainMenu.closeMenus(caller);
			
			//close captions and descriptions of all objects of interest
			ooiManager.hideAllOOIInfoPanes(caller);
		}
		
		override public function addEventListener (type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void 
		{ 
			super.addEventListener (type, listener, useCapture, priority, useWeakReference);
			myArrayListeners.push({type:type, listener:listener, useCapture:useCapture});
		}
		
		//in the end menu, hitting return will bring you back to the painting
		function returnBack(event:MouseEvent):void{
			removeChild(ending);
		}
		
		//in the end menu, if you click to view the letter, the end menu is closed and the letter menu is opened
		function viewLetter(event:MouseEvent):void
		{
			removeChild(ending);
			LetterMenu(mainMenu.getMenu(endGoalMenuTitle)).openMenu();
		}
		
		public function clearEvents():void 
		{
			ooiManager.clearEvents();
			startUpScreen.clearEvents();
			mainMenu.clearEvents();
			magnifyingGlass.clearEvents();
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