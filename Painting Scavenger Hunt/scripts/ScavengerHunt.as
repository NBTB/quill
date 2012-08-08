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
		private var startGameListener:MenuListener;				//Listener to determine when the main game should begin
		private var paintingCanvas:PaintingCanvas = null;		//The class that displays the painting 
		private var ooiManager:OOIManager = null;				//Object which keeps track of objects in the painting
		private var startUpScreen:SplashScreen;					//Splash screen which displays when program is first started
		private var mainMenu:MainMenu;							//The main menu displayed beneath the painting
		private var zoomed:Boolean = false;						//flag tracking whether or not the magnifying glass is active
		private var magnifyingGlass:MagnifyingGlass;			//magnifying glass used to enlarge portions of the scene
		private var magnifyButton:SimpleButton = null;			//button that toggles magnifying glass
		private var clueTimer:Timer = null;						//timer used to trigger the hiding of the clue textfield
		private var clueText:TextField = new TextField(); 		//textfield to hold a newly unlocked clue
		private var needNewClue:Boolean = false;				//flag that tracks whether or not a new clue is needed
		private var nextClueButton:SimpleButton = null;			//notification button that appears when the next clue becomes available
		private var newRewardButton:SimpleButton = null;		//notification button that appears when a new reward is unlocked
		private var clueTextFormat:TextFormat;				 	//text format of the clue textfield
		private var pauseEvents:Boolean = false;				//flag if certain events should be paused
		
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
			startGameListener = new MenuListener();
			startUpScreen = new SplashScreen(startGameListener);
			
			addChild(startUpScreen);
			startGameListener.addEventListener(MenuListener.GAME_START, function(e:Event):void	{	initGame()	});
		}
		
		//When splash screen ends, set up the rest of the game.
		public function initGame():void
		{			
			//create in-game children that will handle specific interaction
			paintingCanvas = new PaintingCanvas(0, 0, stage.stageWidth, stage.stageHeight);
			ooiManager = new OOIManager();
			magnifyingGlass = new MagnifyingGlass();
			mainMenu = new MainMenu(new Rectangle(0, 517, 764, 55), 6, this);
			clueText = new TextField();
			magnifyButton = new SimpleButton();
			nextClueButton = new SimpleButton();
			newRewardButton = new SimpleButton();
						
			//setup clue text format
			clueTextFormat = new TextFormat("Edwardian Script ITC", 25, 0x40E0D0);
			clueTextFormat.align = TextFormatAlign.CENTER;
			
			//set clue textfield location and settings
			clueText.defaultTextFormat = clueTextFormat;
			clueText.wordWrap=true;
			clueText.x=150;
			clueText.y=90;
			clueText.width=474;
			clueText.visible = false;
			clueText.selectable = false;
			
			var notificationButtonLoader:ButtonBitmapLoader = new ButtonBitmapLoader();
			notificationButtonLoader.addEventListener(Event.COMPLETE, function(e:Event):void
																					   {
																						   //setup next clue button
																							nextClueButton = new SimpleButton(new Bitmap(notificationButtonLoader.getUpImage()), 
																																new Bitmap(notificationButtonLoader.getOverImage()), 
																																new Bitmap(notificationButtonLoader.getDownImage()), 
																																new Bitmap(notificationButtonLoader.getHittestImage()));
																							nextClueButton.x = 185;
																							nextClueButton.y = 500;
																							nextClueButton.width /= 5;
																							nextClueButton.height /= 5;
																							nextClueButton.visible = false;
																							
																							//setup new reward button
																							newRewardButton = new SimpleButton(new Bitmap(notificationButtonLoader.getUpImage()), 
																																new Bitmap(notificationButtonLoader.getOverImage()), 
																																new Bitmap(notificationButtonLoader.getDownImage()), 
																																new Bitmap(notificationButtonLoader.getHittestImage()));
																							newRewardButton.x = 315
																							newRewardButton.y = 500;
																							newRewardButton.width /= 5;
																							newRewardButton.height /= 5;
																							newRewardButton.visible = false;
																					   });
			notificationButtonLoader.loadBitmaps("../assets/interface/notification button up.png", "../assets/interface/notification button over.png", 
												 "../assets/interface/notification button down.png", "../assets/interface/notification button hittest.png");
			
			var magnifyButtonLoader:ButtonBitmapLoader = new ButtonBitmapLoader();
			magnifyButtonLoader.addEventListener(Event.COMPLETE, function(e:Event):void
																					   {
																						   //setup next clue button
																							magnifyButton = new SimpleButton(new Bitmap(magnifyButtonLoader.getUpImage()), 
																																new Bitmap(magnifyButtonLoader.getOverImage()), 
																																new Bitmap(magnifyButtonLoader.getDownImage()), 
																																new Bitmap(magnifyButtonLoader.getHittestImage()));
																							magnifyButton.x = 685;
																							magnifyButton.y = 520;
																							magnifyButton.width /= 5;
																							magnifyButton.height /= 5;
																							magnifyButton.visible = true;
																					   });
			magnifyButtonLoader.loadBitmaps("../assets/interface/magnify button up.png", "../assets/interface/magnify button over.png", 
											"../assets/interface/magnify button down.png", "../assets/interface/magnify button hittest.png");
			
			
			/*TODO menu creation and addition to main menu should be put in functions*/
			//create menus to appear in main menu
			var helpMenu:HelpMenu = new HelpMenu(5, 350, 120, 165);
			var cluesMenu:CluesMenu = new CluesMenu(100, 400, 220, 115);
			var endGoalMenu:LetterMenu = new LetterMenu(75, 0, 600, 515);	
			var objectsMenu:ObjectsMenu = new ObjectsMenu(370, 50, 170, 465);					
			var restartMenu:RestartMenu = new RestartMenu (200, 150, 375, 200);
			
			//load hunt information and listen for completion
			var importer:HuntImporter = new HuntImporter();
			importer.addEventListener(Event.COMPLETE, function(e:Event):void{	startGame();	});
			importer.importHunt("scavenger hunt params.xml", paintingCanvas, ooiManager, magnifyingGlass, endGoalMenu, objectsMenu);
			
			//add menus to main menu
			mainMenu.addChildMenu(helpMenu, helpMenuTitle);
			mainMenu.addChildMenu(cluesMenu, cluesMenuTitle);
			mainMenu.addChildMenu(endGoalMenu, endGoalMenuTitle);	/*TODO should be read in from XML file*/
			mainMenu.addChildMenu(objectsMenu, objectsMenuTitle);
			mainMenu.addChildMenu(restartMenu, restartMenuTitle);				
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
			addChildAt(nextClueButton, childIndex++);
			addChildAt(newRewardButton, childIndex++);
			
			//make menus inside main menu displayable
			mainMenu.makeChildMenusDisplayable();	
			
			//give OOIManager reference to objects menu
			ObjectsMenu(mainMenu.getMenu(objectsMenuTitle)).getObjectManager(ooiManager);	
			
			//listen for restart
			RestartMenu(mainMenu.getMenu(restartMenuTitle)).addEventListener(RestartEvent.RESTART_GAME, function(e:RestartEvent):void	
																																{	
																																	dispatchEvent(e);	
																																	clearEvents();
																																});
			
			//add listeners for when in-game children are clicked
			for(var i = 0; i < this.numChildren; i++)
				addDismissibleOverlayCloser(this.getChildAt(i));
			
			//mask the magnifying glass so that it is not drawn beyond the painting
			magnifyingGlass.mask = paintingCanvas.getPaintingMask();
			
			//create clue timer
			clueTimer = new Timer(10 * 1000, 1);
			
			//listen for the completion of the clue timer
			clueTimer.addEventListener(TimerEvent.TIMER, function(e:TimerEvent):void
																		  {
																			hideClueText();
																		  });
			
			//reference the clues and end goal menus
			var cluesMenu:CluesMenu = CluesMenu(mainMenu.getMenu(cluesMenuTitle));
			var endGoalMenu:LetterMenu = LetterMenu(mainMenu.getMenu(endGoalMenuTitle));
			
			//prepare new list of unused objects of interest and pick the first object
			ooiManager.resetUnusedOOIList();
			var firstClue:String = ooiManager.pickNextOOI();
			cluesMenu.addClue(firstClue);
			
			//post first clue
			postToClueText(firstClue);
			nextClueButton.visible = false;
			
			//post first clue
			postToClueText(firstClue);
			nextClueButton.visible = false;
			
			//listen for correct answers to clues
			ooiManager.addEventListener(OOIManager.CORRECT, handleCorrectAnswer);
			
			//listen for incorrect answers to clues
			ooiManager.addEventListener(OOIManager.INCORRECT, handleIncorrectAnswer);
			
			//listen for an object of interest's info pan to open and close
			ooiManager.addEventListener(BaseMenu.MENU_OPENED, function(e:Event):void	{	allowEventsOutsideMenu(false);	});
			ooiManager.addEventListener(BaseMenu.MENU_CLOSED, function(e:Event):void	{	allowEventsOutsideMenu(true);	});
			
			//listen for the next clue button being clicked
			nextClueButton.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void	
																					{	
																						mainMenu.closeMenus();
																						showNextClue();	
																					});
			
			//listen for the clues menu being opened
			cluesMenu.addEventListener(BaseMenu.MENU_OPENED, function(e:Event):void	
																					   {
																							//if the next clue button is visible, hide it 
																							//the clue will appear in the clues menu
																							if(nextClueButton.visible)
																						   		nextClueButton.visible = false;
																					   });
			
			//listen for the new reward button being clicked
			newRewardButton.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void	
																					{	
																						endGoalMenu.openMenu();
																					});
			
						//listen for the reward menu being opened
			endGoalMenu.addEventListener(BaseMenu.MENU_OPENED, function(e:Event):void
																						{
																						   //if the new reward button is visible, hide it 
																						   //the new reward is being viewed
																						   if(newRewardButton.visible)
																								newRewardButton.visible = false;
																					   	});
			
			//listen for a menu to open and close
			mainMenu.addEventListener(BaseMenu.MENU_OPENED, function(e:Event):void	{	allowEventsOutsideMenu(false);	});
			mainMenu.addEventListener(BaseMenu.MENU_CLOSED, function(e:Event):void	{	allowEventsOutsideMenu(true);	});
			
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
                placeMagnifyingGlass(new Point(paintingCanvas.mouseX, paintingCanvas.mouseY));
			}
		}		
		
		//handles the release of keys
		public function checkKeysUp(e:KeyboardEvent):void
		{
			//toggle magnifying glass
			if(e.keyCode == Keyboard.SPACE)
				toggleZoom();
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
				placeMagnifyingGlass(new Point(paintingCanvas.mouseX, paintingCanvas.mouseY));
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
			paintingCanvas.addPaintingToList(bitmaps, texturePoints, center, true);
			
			//add magnified object highlights
			ooiManager.addObjectHighlightsToList(bitmaps, texturePoints, center, true);
			
			//magnify
			magnifyingGlass.magnifyBitmaps(bitmaps, texturePoints);
		}
		
		//handle a correct answer to a clue
		private function handleCorrectAnswer(e:Event)
		{	
			//reference the clues and end goal menus
			var cluesMenu:CluesMenu = CluesMenu(mainMenu.getMenu(cluesMenuTitle));
			var endGoalMenu:LetterMenu = LetterMenu(mainMenu.getMenu(endGoalMenuTitle));
		
			//hide the current clue
			hideClueText();
		
			//close menus
			mainMenu.closeMenus();
		
			//add the piece of the end goal
			var completionRequirement:int = ooiManager.getUsableOOICount();
			if(endGoalMenu.unlockReward(completionRequirement, LetterMenu.NEXT_REWARD))
					newRewardButton.visible = true;
					
			/*if(mainMenu.rewardCounter > completionRequirement)
			{
				mainMenu.rewardCounter = completionRequirement;
			}
			else
			{
				mainMenu.rewardCounter++;
			}*/
		
			//attempt to pick the next object to hunt and retrieve its clue
			var nextClue:String = ooiManager.pickNextOOI();			
			
			//if a new clue was picked, display it and pass it to the clues menu
			if(nextClue)
			{
				//show next clue button
				nextClueButton.visible = true;
				
				//add new clue to clue menu
				cluesMenu.addClue(nextClue);
			}
			//otherwise, notify the user that the hunt has been completed
			else
				postToClueText(OOIManager.NO_CLUES_NOTIFY);
				
			//make the current clue old
			cluesMenu.outdateCurrentClue();
		}
		
		//display the next clue
		private function showNextClue():void
		{
			//post the new clue to the clue textfield
			postToClueText(ooiManager.getCurrentClue());			
			
			//hide the next clue button
			nextClueButton.visible = false;
		}
		
		//handle an incorrect answer to a clue
		private function handleIncorrectAnswer(e:Event)
		{
			//notify the user that the answer was incorrect
			//postToClueText(OOIManager.WRONG_ANSWER_NOTIFY);
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
			closer.addEventListener(eventType, closeDismissibleOverlays);
		}
		
		//close overlays that are to be dismissed by a click anywhere else on screen
		private function closeDismissibleOverlays(e:MouseEvent):void
		{					
			//close all menus
			mainMenu.closeMenus(e.target);
			
			//close captions and descriptions of all objects of interest
			ooiManager.hideAllOOIInfoPanes(e.target);
		}
		
		override public function addEventListener (type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void 
		{ 
			super.addEventListener (type, listener, useCapture, priority, useWeakReference);
			myArrayListeners.push({type:type, listener:listener, useCapture:useCapture});
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