
package scripts
{
	import flash.display.*;
	import flash.events.*;
	import flash.ui.*;
	import flash.geom.*;	
	import flash.text.*;
	import flash.utils.Timer;
		
	import scripts.MouseWheel;
		
	public class ScavengerHunt extends MovieClip
	{
		private var importer:HuntImporter = null;						//importer used to load start-up and hunt
		private var paintingCanvas:PaintingCanvas = null;				//The class that displays the painting 
		private var ooiManager:OOIManager = null;						//Object which keeps track of objects in the painting
		private var mainMenu:MainMenu;									//The main menu displayed beneath the painting
		private var openedMenus:Array = null;							//list of currently open menus
		private var prepareZoom:Boolean = false;						//flag preperation for use of magnifying glass
		private var zoomed:Boolean = false;								//flag tracking whether or not the magnifying glass is active
		private var magnifyingGlass:MagnifyingGlass;					//magnifying glass used to enlarge portions of the scene
		private var magnifyButton:SimpleButton = null;					//button that toggles magnifying glass
		private var notificationTimer:Timer = null;						//timer used to trigger the hiding of the notification textfield
		private var notificationText:TextField = new TextField(); 		//textfield to hold notifications
		private var notificationTextFormat:TextFormat;					//text format of the notification textfield
		private var notificationTextColorNormal:ColorTransform = null;	//color of notification text in its normal state
		private var notificationTextColorNew:ColorTransform = null;		//color transform applied to notification text immediately after it is updated
		private var notificationTextColorFadeTime:int = 0;				//number of frames the notification text color takes to transition from new to normal
		private var notificationTextColorFades:int = 0;					//number of frames the notification text color has been fading
		private var pauseEvents:Boolean = false;						//flag if certain events should be paused
		private var menusDismissibleTimer:Timer = null;					//timer used to give buffer between opening a menu and being able to dismiss by clicking elsewhere
		private var menusDismissible:Boolean = false;					//flag when menus can be dismissed by clicking outside of them (close button is not affected)
		private var cluesMenu:CluesMenu = null;							//panel that contains clue
		private var endGoalMenu:EndGoalMenu = null;						//panel that contains end goal pieces
		private var ending:Ending = null;								//menu displayed when you win
		private var loadingMenu:LoadingMenu = null;						//pane displayed while loading
		private var introMenu:IntroMenu = null;							//overlay that introduces the game
		private var allSolved = false;									//flag if all clues have been solved
		private var allFound = false;									//flag if all objects of interest have been found
		
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
			//find specification files before preparing game
			importer = new HuntImporter();
			importer.addEventListener(HuntImporter.SPECS_AND_DIRECTORIES_FOUND, function(e:Event):void	{	startMenu()	});
			importer.findSpecFilesAndAssetDirectories("xml/importer.xml");			
		}
		
		//Begins the game, by first displaying the opening splash screen menus.  Also listens for when the splash screen is finished
		public function startMenu():void
		{								
			//load start-up information and listen for completion
			importer.addEventListener(HuntImporter.START_UP_LOADED, function(e:Event):void
																					 {				
																						loadingMenu = new LoadingMenu(0, 0, 1265, 630);
																						addChild(loadingMenu);
																						loadingMenu.openMenu();
																						//loadingMenu.addChild(loadingMenu.loadLoader);
																						initGame();																		
																					 });
			importer.importStartUp();			
		}
		
		//When splash screen ends, set up the rest of the game.
		public function initGame():void
		{														
			//Prevent the mouse from scrolling the webpage while the program is selected
			MouseWheel.capture();
					
			//create in-game children that will handle specific interaction
			paintingCanvas = new PaintingCanvas(0, 56, 765, 574);
			ooiManager = new OOIManager(this, this);
			magnifyingGlass = new MagnifyingGlass();
			mainMenu = new MainMenu(new Rectangle(0, 574, 764, 55), 4, this);
			notificationText = new TextField();
			magnifyButton = new SimpleButton();
			cluesMenu = new CluesMenu(0, 0, 765, 55);
			endGoalMenu = new EndGoalMenu(765, 0, 500, 630);			
			introMenu = new IntroMenu(30, 75, 700, 480);
			
			//define normal notification text color
			var normalRed:uint = 0x40;
			var normalGreen:uint = 0xE0;
			var normalBlue:uint = 0xD0;
			var normalAlpha:uint = 0xFF
			notificationTextColorNormal = new ColorTransform();	
			notificationTextColorNormal.color = (normalRed * 0x010000) + (normalGreen * 0x000100) + (normalBlue);
			
			//define offsets to apply when notification is new
			notificationTextColorNew = new ColorTransform(1, 1, 1, 1, 0x90 - normalRed, 0x90 - normalGreen, 0x90 - normalBlue);
			notificationTextColorFadeTime = 10;
			
			//setup clue text format
			notificationTextFormat = new TextFormat("Times New Roman", 25, notificationTextColorNormal.color);
			notificationTextFormat.align = TextFormatAlign.CENTER;
			
			//set clue textfield location and settings
			notificationText.defaultTextFormat = notificationTextFormat;
			notificationText.transform.colorTransform = notificationTextColorNormal;
			notificationText.wordWrap=true;
			notificationText.x=150;
			notificationText.y=90;
			notificationText.width=474;
			notificationText.visible = false;
			notificationText.selectable = false;
			notificationText.mouseEnabled = false;
			
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
			magnifyButtonLoader.loadBitmaps(FileFinder.completePath(FileFinder.INTERFACE, "magnify button up.png"), FileFinder.completePath(FileFinder.INTERFACE, "magnify button over.png"), 
											FileFinder.completePath(FileFinder.INTERFACE, "magnify button down.png"),FileFinder.completePath(FileFinder.INTERFACE, "magnify button hittest.png"));
			
			//create menus to appear in main menu
			var helpMenu:HelpMenu = new HelpMenu(40, 230, 120, 340);					
			var objectsMenu:ObjectsMenu = new ObjectsMenu(200, 105, 190, 465);	
			var restartMenu:RestartMenu = new RestartMenu (200, 150, 375, 200);
			
			//load hunt information and listen for completion (set a minimum load time to avoid a quick flash)
			var timerReady:Boolean = false;
			var loadReady:Boolean = false;
			var loadingTimer:Timer = new Timer(1000);
			loadingTimer.addEventListener(TimerEvent.TIMER, function(e:Event):void	
																		{
																			timerReady = true
																			if(timerReady && loadReady)
																				startGame();
																			loadingTimer.stop();
																			loadingTimer = null;
																		});
			loadingTimer.start();
			importer.addEventListener(Event.COMPLETE, function(e:Event):void
																	   {
																		  	loadReady = true
																			if(timerReady && loadReady)
																				startGame();
																	   });
			importer.importHunt(paintingCanvas, ooiManager, magnifyingGlass, endGoalMenu);			
			
			//add menus to main menu
			mainMenu.addChildMenu(helpMenu, helpMenuTitle);
			mainMenu.addChildMenu(objectsMenu, objectsMenuTitle);
			mainMenu.addChildMenu(restartMenu, restartMenuTitle);
			
			//create ending
			ending = new Ending(200, 150, 450, 300);
			ending.visible = false;
			addChild(ending);
		}
		
		//Actually begin the rest of the game
		public function startGame():void
		{					
			//remove pre-game children from display list
			loadingMenu.closeMenu();
									
			//add in-game children to display list,
			//ensuring that they are tightly packed on the bottom layers
			var childIndex:int = 0;
			addChildAt(paintingCanvas, childIndex++);
			addChildAt(ooiManager, childIndex++);
			addChildAt(mainMenu, childIndex++);
			addChildAt(magnifyingGlass, childIndex++);
			addChildAt(notificationText, childIndex++);	
			addChildAt(magnifyButton, childIndex++);
			addChildAt(endGoalMenu, childIndex++);	
			addChildAt(cluesMenu, childIndex++);		
			
			//add click listeners to in-game children to dismiss other menus
			addDismissibleOverlayCloser(paintingCanvas);
			addDismissibleOverlayCloser(ooiManager);
			addDismissibleOverlayCloser(mainMenu);
			addDismissibleOverlayCloser(magnifyingGlass);
			addDismissibleOverlayCloser(magnifyButton);
			addDismissibleOverlayCloser(cluesMenu);
			addDismissibleOverlayCloser(endGoalMenu);
			
			//add menu open listeners to pop-up menus that direct children to dismiss other menus
			addDismissibleOverlayCloser(introMenu, MenuEvent.MENU_OPENED);
			addDismissibleOverlayCloser(ending, MenuEvent.MENU_OPENED);
			
			//add menu open listeners to menus in main menu to dismiss other menus
			var menuCount = mainMenu.getMenuCount();
			for(var m:int = 0; m < menuCount; m++)
				addDismissibleOverlayCloser(mainMenu.getMenuAtIndex(m), MenuEvent.MENU_OPENED);
				
			//add menu open listeners to object of interest info panes to dismiss other menus
			var ooiCount = ooiManager.getTotalOOICount();
			for(var o:int = 0; o < ooiCount; o++)
				addDismissibleOverlayCloser(ooiManager.getOOIAtIndex(o).getInfoPane(), MenuEvent.MENU_OPENED);
			
			//open clues and end goal menus
			cluesMenu.openMenu();
			endGoalMenu.openMenu();
			
			//make menus inside main menu displayable
			mainMenu.makeChildMenusDisplayable();	
			
			//give OOIManager reference to objects menu
			var objectsMenu:ObjectsMenu = ObjectsMenu(mainMenu.getMenu(objectsMenuTitle));
			objectsMenu.setObjectManager(ooiManager);	
			
			//listen for a request to open objects menu after object of interest info pane closure
			objectsMenu.addEventListener(MenuEvent.SPECIAL_OPEN_REQUEST, function(e:MenuEvent):void
																							 {
																								//if events that depend on all other menus being closed are allowed, open
																								if(!pauseEvents && !prepareZoom)
																									objectsMenu.openMenu();																								
																							 });
			
			//listen for a request to open help menu after instructions closure
			var helpMenu:HelpMenu = HelpMenu(mainMenu.getMenu(helpMenuTitle));
			helpMenu.addEventListener(MenuEvent.SPECIAL_OPEN_REQUEST, function(e:MenuEvent):void
																							 {
																								//if events that depend on all other menus being closed are allowed, open
																								if(!pauseEvents && !prepareZoom)
																									helpMenu.openMenu();																								
																							 });

			//create list of opened menus
			openedMenus = new Array();
			
			//mask the magnifying glass so that it is not drawn beyond the painting
			magnifyingGlass.mask = paintingCanvas.getPaintingMask();
			
			//create notification timer
			notificationTimer = new Timer(5000, 1);
			
			//listen for the completion of the notification timer
			notificationTimer.addEventListener(TimerEvent.TIMER, function(e:TimerEvent):void	{	hideNotificationText();	});			
			
			//create menu dismissible timer
			menusDismissibleTimer = new Timer(500);
			menusDismissible = true;
			
			//listen for the completion of the menu dismissible timer
			menusDismissibleTimer.addEventListener(TimerEvent.TIMER, function(e:TimerEvent):void	{	menusDismissible = true;	});						
			
			//listen for correct answers to clues
			ooiManager.addEventListener(OOIManager.CORRECT, handleCorrectAnswer);
			
			//listen for incorrect answers to clues
			ooiManager.addEventListener(OOIManager.INCORRECT, handleIncorrectAnswer);
			
			//listen for all objects being found
			ooiManager.addEventListener(OOIManager.ALL_OBJECTS_FOUND, handleAllObjectsFound);
			
			//listen for an object of interest's info pane to open and close
			ooiManager.addEventListener(MenuEvent.MENU_OPENED, function(e:MenuEvent):void	{	menuOpened(e.getTargetMenu());	});
			ooiManager.addEventListener(MenuEvent.MENU_CLOSED, function(e:MenuEvent):void	{	menuClosed(e.getTargetMenu());	});
			
			//listen for a menu to open and close
			mainMenu.addEventListener(MenuEvent.MENU_OPENED, function(e:MenuEvent):void	{	menuOpened(e.getTargetMenu());	});
			mainMenu.addEventListener(MenuEvent.MENU_CLOSED, function(e:MenuEvent):void	{	menuClosed(e.getTargetMenu());	});
			
			//listen for ending pane to open and close
			ending.addEventListener(MenuEvent.MENU_OPENED, function(e:MenuEvent):void	{	forceInteractionWithMenu(e.getTargetMenu());	});
			ending.addEventListener(MenuEvent.MENU_CLOSED, function(e:MenuEvent):void	
																				{	
																					forceInteractionWithMenu(e.getTargetMenu());	
																					allSolved = true
																					if(allFound && allSolved)
																						unlockHiddenPiece();
																				});
			
			//listen for restart menu to open and close
			var restartMenu:RestartMenu = RestartMenu(mainMenu.getMenu(restartMenuTitle));
			restartMenu.addEventListener(MenuEvent.MENU_OPENED, function(e:MenuEvent):void	{	forceInteractionWithMenu(e.getTargetMenu());	});
			restartMenu.addEventListener(MenuEvent.MENU_CLOSED, function(e:MenuEvent):void	{	forceInteractionWithMenu(e.getTargetMenu());	});
			
			//listen for the magnify button being clicked
			magnifyButton.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void	{	toggleZoom();	});
			
			//listen for intro menu being opened and close		
			introMenu.addEventListener(MenuEvent.MENU_OPENED, function(e:MenuEvent):void	{	forceInteractionWithMenu(e.getTargetMenu());	});
			introMenu.addEventListener(MenuEvent.MENU_CLOSED, function(e:MenuEvent):void	
																				   {	
																				   		//allow interaction beyond menu as it closes
																				   		forceInteractionWithMenu(e.getTargetMenu());	
																						
																						//prepare new list of unused objects of interest and pick the first object
																						ooiManager.resetUnusedOOIList();
																						var firstClue:String = ooiManager.pickNextOOI();
																						cluesMenu.addClue(firstClue);
																						
																						//show unlocked content
																						endGoalMenu.showRewards();
																				   });
			
			//open intro menu			
			addChild(introMenu);	
			introMenu.openMenu();			
			
			//unlock the first pieces of the end goal (remain hidden for now)
			endGoalMenu.hideRewards();
			endGoalMenu.unlockReward(ooiManager.getSolvableOOICount() + 1, EndGoalMenu.NEXT_REWARD);
			
			//listen for new frame
			addEventListener(Event.ENTER_FRAME, checkEnterFrame);
			
			//listen for input events
			stage.focus = stage;
			stage.addEventListener(KeyboardEvent.KEY_UP, checkKeysUp);
		}		
		
		//handle new frame
		public function checkEnterFrame(e:Event):void
		{			
			//if a notification present and new, fade it partially
			if(notificationText.visible && notificationTextColorFades <= notificationTextColorFadeTime)
			{
				var fadeRatio:Number = (Number(notificationTextColorFades) / notificationTextColorFadeTime);
				var invFadeRatio:Number = 1 - fadeRatio;
				notificationText.textColor = notificationTextColorNormal.color;
				notificationText.transform.colorTransform = new ColorTransform(1, 1, 1, 1,	notificationTextColorNormal.redOffset * fadeRatio + notificationTextColorNew.redOffset * invFadeRatio,
																							notificationTextColorNormal.greenOffset * fadeRatio + notificationTextColorNew.greenOffset * invFadeRatio, 
																							notificationTextColorNormal.blueOffset * fadeRatio + notificationTextColorNew.blueOffset * invFadeRatio, 0);
				notificationTextColorFades++;
			}
						
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
			
			//if the given menu is being not already being tracked as open, track it
			var indexOfMenu = openedMenus.indexOf(targetMenu)
			if(indexOfMenu >= 0)
				openedMenus.push(targetMenu);			
		}
		
		//handle the closing of a menu
		private function menuClosed(targetMenu:BaseMenu)
		{
			//if the given menu is being tracked as open, remove it from the list
			var indexOfMenu = openedMenus.indexOf(targetMenu)
			if(indexOfMenu >= 0)
				openedMenus.splice(indexOfMenu, 1);
				
			//if all opened menus have been closed, allow actions that depend on all menus being closed
			if(openedMenus.length < 1)
				allowEventsOutsideMenu(true);
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
				prepareZoom = false;
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
			ooiManager.addObjectFoundImagesToList(bitmaps, texturePoints, center, true);
			ooiManager.addObjectHighlightsToList(bitmaps, texturePoints, center, true);
			
			//magnify
			magnifyingGlass.magnifyBitmaps(bitmaps, texturePoints);
		}
		
		//handle a correct answer to a clue
		private function handleCorrectAnswer(e:Event)
		{			
			//hide the current clue
			hideNotificationText();

			//show the hunted object's found image
			var foundObject = ooiManager.getCurrentOOI();
			if(foundObject)
				foundObject.showFoundImage();
		
			//add the piece of the end goal
			var completionRequirement:Number = ooiManager.getSolvableOOICount() + 1;
			endGoalMenu.unlockReward(completionRequirement, EndGoalMenu.NEXT_REWARD);
		
			//attempt to pick the next object to hunt and retrieve its clue
			var nextClue:String = ooiManager.pickNextOOI();			
			
			//if a new clue was picked, display it and pass it to the clues menu
			if(nextClue)
			{							
				//make the current clue old
				cluesMenu.outdateCurrentClue();
				
				//add new clue to clue menu
				cluesMenu.addClue(nextClue);
				
				//post correct answer notification
				postNotification("Correct!\nYou unlocked a piece of the letter.");
			}
			//otherwise, end the game
			else
			{											
				//make the current clue old
				cluesMenu.outdateCurrentClue();
				
				//show ending
				ending.openMenu();
			}
			
			
		}
		
		//handle a incorrect answer to a clue
		private function handleIncorrectAnswer(e:Event)
		{	
			postNotification("Try Again");
		}
		
		//handle all objects being found
		private function handleAllObjectsFound(e:Event)
		{	
			allFound = true
			if(allFound && allSolved)
				unlockHiddenPiece();
			
		}
		
		//unlock the hidden piece of the end goal
		private function unlockHiddenPiece()
		{
			//add a new page to the end goal menu and show final reward		
			endGoalMenu.addPage();
			endGoalMenu.unlockFinalReward();			
			postNotification("You found a hidden letter!");
		}
		
		//display notification in textfield on screen
		private function postNotification(textToPost:String)
		{				
			//display notification
			notificationText.visible = true;
			notificationText.text = textToPost;
			
			//start fading
			notificationTextColorFades = 0;
			
			//restart the clue hiding timer
			notificationTimer.reset();
			notificationTimer.start();
		}
		
		//reset notification time and hide the notification textfield
		private function hideNotificationText()
		{
			
			notificationTimer.reset();
			notificationText.text = ""
			notificationText.visible = false;
		}
		
		//add event listener to list that will trigger the closing of dismissible overlays
		private function addDismissibleOverlayCloser(closer:DisplayObject, eventType:String = MouseEvent.CLICK):void
		{
			closer.addEventListener(eventType, function(e:Event):void	{	closeDismissibleOverlays(e.target);	});
		}
		
		//close overlays that are to be dismissed by a click anywhere else on screen
		private function closeDismissibleOverlays(caller:Object):void
		{					
			if(menusDismissible)
			{
				//if the magnify button is calling for the dismissal, give magnfying glass priority
				if(caller == magnifyButton)
					prepareZoom = true;
				
				//close all menus attached to main menu
				mainMenu.closeMenus(caller);
				
				//close captions and descriptions of all objects of interest
				ooiManager.hideAllOOIInfoPanes(caller);				
				
				//do not allow menus to be dismissed for a short duration
				menusDismissible = false;
				menusDismissibleTimer.start();
			}
		}
		
		override public function addEventListener (type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void 
		{ 
			super.addEventListener (type, listener, useCapture, priority, useWeakReference);
			myArrayListeners.push({type:type, listener:listener, useCapture:useCapture});
		}
		
		//in the end menu, if you click to view the letter, the end menu is closed and the letter menu is opened
		function viewLetter(event:MouseEvent):void
		{
			removeChild(ending);
			EndGoalMenu(mainMenu.getMenu(endGoalMenuTitle)).openMenu();
		}
		
		//based on the given menu being open or closed, enter or exit restricted state where only that menu should be interactive
		private function forceInteractionWithMenu(targetMenu)
		{
			//track ending's open status
			var othersEnabled = !targetMenu.isMenuOpen();
			
			//if menu is opened remove painting interactivity
			if(!othersEnabled)
			{
				menuOpened(targetMenu);	
				paintingCanvas.updatePaintingMode(PaintingCanvas.NON_INTERACTIVE);
			}
			//otherwise, restore painting interactivity
			else
			{
				menuClosed(targetMenu);	
				paintingCanvas.updatePaintingMode(PaintingCanvas.INTERACTIVE);
			}
			
			//enable/disable interaction with other children
			ooiManager.mouseEnabled = othersEnabled;
			ooiManager.mouseChildren = othersEnabled;
			mainMenu.mouseEnabled = othersEnabled;
			mainMenu.mouseChildren = othersEnabled;
			cluesMenu.mouseEnabled = othersEnabled;
			cluesMenu.mouseChildren = othersEnabled;
			endGoalMenu.mouseEnabled = othersEnabled;
			endGoalMenu.mouseChildren = othersEnabled;
			magnifyButton.mouseEnabled = othersEnabled;
			
			//enable target menu
			targetMenu.mouseEnabled = true;
			targetMenu.mouseChildren = true;
			
			//enable/disable dismissibility of menus
			menusDismissibleTimer.reset();
			menusDismissible = othersEnabled;
		}
		
		private function allowEventsOutsideMenu(allowEvents:Boolean):void
		{
			//flag the pause/unpause of certain events
			pauseEvents = !allowEvents;
						
			//if events are not allowed, setup special states
			if(!allowEvents)
			{
				hideNotificationText();
				toggleZoom(true, false);
				ooiManager.setAllOOIHitTestSuppression(true);
			}
			//otherwise, revert to normal states
			else
			{
				ooiManager.setAllOOIHitTestSuppression(false);
			}
		}
		
		public function clearEvents():void 
		{
			ooiManager.clearEvents();
			loadingMenu.clearEvents();
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