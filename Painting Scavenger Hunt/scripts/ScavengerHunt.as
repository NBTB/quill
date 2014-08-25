
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
		private var magnifyingGlass:MagnifyingGlass = null;				//magnifying glass used to enlarge portions of the scene
		private var magnifyButton:SimpleButton = null;					//button that toggles magnifying glass
		private var magnifyButtonBg:Sprite = null;						//background for magnifyButton
		private var firstLetterBg:Sprite = null;						//background for first letter
        private var secondLetterBg:Sprite = null;                       //background for second letter (hidden end goal)
		private var notificationTimer:Timer = null;						//timer used to trigger the hiding of the notification textfield
		private var notificationText:TextField = null; 					//textfield to hold notifications
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
		private var letterVisible:Boolean = false;
		private var ending:Ending = null;								//menu displayed when you win
		private var loadingMenu:LoadingMenu = null;						//pane displayed while loading
		private var introMenu:IntroMenu = null;							//overlay that introduces the game
		private var toggleLetterButton:TextButton = null;
		private var goalReached = false;								//flag if the normal goal has been completed (not including hidden goals)
		private var stageSize:Point = null;								//size of stage (web deployment has issues with stage's stageWidth and stageHeight properties)
		private var canvasRect = null;									//rectangle to hold canvas
		private var clueProgress = null;								//Progress meter for clues found
		private var clueProgressText = null;							//Label text for progress meter
		private var letterCaption = null;								//Label for inventory
		private var textF = null;										//Progress meter label textformat
		private var FULLSIZE_LETTER_X = null;							//X-Position of fullsize letters
		private var inventoryCaptions = null;							//Captions for player items

		//main menu titles
		private var helpMenuTitle:String = "Help";			//title of help menu
		private var cluesMenuTitle:String = "Clues";		//title of clues menu
		private var endGoalMenuTitle:String = "Letter";		//title of end goal menu
		private var objectsMenuTitle:String = "Objects";	//title of objects menu
		private var restartMenuTitle:String = "Restart";	//title of restart menu

		//construct scavanger hunt
		public function ScavengerHunt():void
		{
			//create stage size and canvas rectangle
			stageSize = new Point();
			canvasRect = new Rectangle();

			//find specification files before preparing game
			importer = new HuntImporter();
			importer.addEventListener(HuntImporter.SPECS_AND_DIRECTORIES_FOUND, function(e:Event):void	{	loadStartUp()	});
			importer.findSpecFilesAndAssetDirectories("xml/importer.xml", stageSize, canvasRect);

			addEventListener(Event.REMOVED_FROM_STAGE, function(e:Event):void
																		{
																			BaseMenu.disposeOfBitmaps();
																		});
		}

		//load the initial parameters of the game
		public function loadStartUp():void
		{
			//load start-up information and listen for completion
			importer.addEventListener(HuntImporter.START_UP_LOADED, function(e:Event):void
																					 {
																						loadingMenu = new LoadingMenu(0, 0, stageSize.x, stageSize.y);
																						addChild(loadingMenu);
																						loadingMenu.openMenu();
																						initGame();
																					 });
			importer.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent):void
																					 {
																						loadingMenu = new LoadingMenu(0, 0, stageSize.x, stageSize.y);
																						addChild(loadingMenu);
																						loadingMenu.openMenu();
																						loadingMenu.fail();
																					 });
			importer.importStartUp();
		}

		//when initial loading ends, set up the rest of the game
		public function initGame():void
		{
			//prevent the mouse from scrolling the webpage while the program is selected
			MouseWheel.capture();

			//create in-game children that will handle specific interaction
			paintingCanvas = new PaintingCanvas(canvasRect.x, canvasRect.y, canvasRect.width, canvasRect.height);
			ooiManager = new OOIManager(this, this);
			magnifyingGlass = new MagnifyingGlass();
			cluesMenu = new CluesMenu(0, canvasRect.y + canvasRect.height, canvasRect.width, 77);
			introMenu = new IntroMenu(canvasRect.width, canvasRect.y, 430, stageSize.y);
			mainMenu = new MainMenu(new Rectangle(canvasRect.width, canvasRect.height, introMenu.width, 77), 3, this);
			notificationText = new TextField();
			clueProgressText = new TextField();
			letterCaption = new TextField();
			endGoalMenu = new EndGoalMenu(canvasRect.width + 10, 435, 1800, 630);
			clueProgress = new ProgressBar(350, 35,endGoalMenu.getCluesNotUnlocked(), endGoalMenu.getCluesUnlocked());
			ending = new Ending(canvasRect.x + 150, canvasRect.y + 100, canvasRect.width - 300, canvasRect.height - 300);

			//create color transforms for notification text
			notificationTextColorNormal = new ColorTransform();
			notificationTextColorNew = new ColorTransform();

			//split canvas into segments half the size of a main menu segement for use in menu positioning
			var menuInterval:Number = canvasRect.width / (mainMenu.getMenuCapacity() * 2);
			clueProgress.x = introMenu.x + 50;
			clueProgress.y = 400;
			clueProgressText.width = clueProgress.width;
			clueProgressText.x = introMenu.x + 25;
			clueProgressText.y = 335;

			//Add inventory background to letter
			firstLetterBg = new Sprite();
            secondLetterBg = new Sprite();

			magnifyButton = new SimpleButton();

			var magnifyButtonLoader:ButtonBitmapLoader = new ButtonBitmapLoader();
			magnifyButtonLoader.addEventListener(Event.COMPLETE, function(e:Event):void
			   {
				   //setup next clue button
					magnifyButton = new SimpleButton(new Bitmap(magnifyButtonLoader.getUpImage()),
													new Bitmap(magnifyButtonLoader.getOverImage()),
													new Bitmap(magnifyButtonLoader.getDownImage()),
													new Bitmap(magnifyButtonLoader.getHittestImage()));
					magnifyButton.x = 890;
					magnifyButton.y = 500;
					magnifyButtonBg = new Sprite();
					magnifyButtonBg.graphics.moveTo(magnifyButton.x, magnifyButton.y);
					magnifyButtonBg.graphics.beginFill(0xa9997f, 1);
					magnifyButtonBg.graphics.drawRoundRect(magnifyButton.x - 10, magnifyButton.y - 10, 120, 120, 5, 5);
					magnifyButtonBg.graphics.endFill();
					magnifyButton.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void {
						closeDismissibleOverlays(null);
						toggleZoom();
					});
			   });
			magnifyButtonLoader.loadBitmaps(FileFinder.completePath(FileFinder.INTERFACE, "magnifying_glass.png"), FileFinder.completePath(FileFinder.INTERFACE, "magnifying_glass_over.png"),
											FileFinder.completePath(FileFinder.INTERFACE, "magnifying_glass.png"),FileFinder.completePath(FileFinder.INTERFACE, "magnifying_glass.png"));

			//create menus to appear in main menu
			var helpMenu:HelpMenu = new HelpMenu(canvasRect.width + menuInterval - 200, mainMenu.y - 275, 120, 270, new Rectangle(canvasRect.x + 30, canvasRect.y + 30, canvasRect.width - 60, canvasRect.height - 60));
			var objectsMenu:ObjectsMenu = new ObjectsMenu(helpMenu.x + 150, mainMenu.y - 470, 190, 465);
			var restartMenu:RestartMenu = new RestartMenu (canvasRect.x + 200, canvasRect.y + 100, canvasRect.width - 400, canvasRect.height - 350);

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
			importer.importHunt(paintingCanvas, ooiManager, magnifyingGlass, endGoalMenu, notificationTextColorNormal, notificationTextColorNew);

			//add menus to main menu
			mainMenu.addChildMenu(helpMenu, helpMenuTitle);
			mainMenu.addChildMenu(objectsMenu, objectsMenuTitle);
			mainMenu.addChildMenu(restartMenu, restartMenuTitle);

		}

		//begin the game
		public function startGame():void
		{
			//remove pre-game children from display list
			loadingMenu.closeMenu();

			//add in-game children to display list,
			//ensuring that they are tightly packed on the bottom layers
			var childIndex:int = 0;
			addChildAt(paintingCanvas, childIndex++);
			addChildAt(ooiManager, childIndex++);
			addChildAt(magnifyingGlass, childIndex++);
			addChildAt(notificationText, childIndex++);
			addChildAt(cluesMenu, childIndex++);
			addChildAt(introMenu, childIndex++);
			addChildAt(magnifyButtonBg, childIndex++);
			addChildAt(magnifyButton, childIndex++);
			addChildAt(clueProgress, childIndex++);
			addChildAt(clueProgressText, childIndex++);
			addChildAt(letterCaption, childIndex++);
			addChildAt(firstLetterBg, childIndex++);
            addChildAt(secondLetterBg, childIndex++);
			addChildAt(endGoalMenu, childIndex++);
			addChildAt(mainMenu, childIndex++);

			//add click listeners to in-game children to dismiss other menus
			addDismissibleOverlayCloser(paintingCanvas);
			addDismissibleOverlayCloser(ooiManager);
			addDismissibleOverlayCloser(mainMenu);
			addDismissibleOverlayCloser(magnifyingGlass);
			addDismissibleOverlayCloser(cluesMenu);
			addDismissibleOverlayCloser(endGoalMenu);

			//add menu open listeners to pop-up menus that direct children to dismiss other menus
			addDismissibleOverlayCloser(introMenu, MenuEvent.MENU_OPENED);
			addDismissibleOverlayCloser(ending, MenuEvent.MENU_OPENED);

			//add menu open listeners to menus in main menu to dismiss other menus
			var menuCount = mainMenu.getMenuCount();
			for(var m:int = 0; m < menuCount; m++)
				addDismissibleOverlayCloser(mainMenu.getMenuAtIndex(m), MenuEvent.MENU_OPENED);

			//open clues and end goal menus
			cluesMenu.openMenu();
			endGoalMenu.openMenu();

			//open intro menu
			introMenu.initText();
			introMenu.init();
			introMenu.openMenu();

			//make menus inside main menu displayable
			mainMenu.makeChildMenusDisplayable();


			//create array of caption objects for each inventory item
			inventoryCaptions = new Array();
			inventoryCaptions[0] = new OOICaption("Magnifying Glass", "A tool to see things better", "Click or press space to zoom in");
			inventoryCaptions[1] = new OOICaption("Letter", EndGoalMenu.goalOverlayText, "Click to zoom in");
			inventoryCaptions[2] = new OOICaption("Letter", EndGoalMenu.hiddenOverlayText, "Click to zoom in");

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
																					//allow normal interaction
																					forceInteractionWithMenu(e.getTargetMenu());

																					//flag the normal goal as being reached
																					goalReached = true

																					//if more clues remain, show a new one
																					var nextClue:String = ooiManager.pickNextOOI();
																					if(nextClue)
																						cluesMenu.addClue(nextClue);
																				});

			//listen for restart menu to open and close
			var restartMenu:RestartMenu = RestartMenu(mainMenu.getMenu(restartMenuTitle));
			restartMenu.addEventListener(MenuEvent.MENU_OPENED, function(e:MenuEvent):void	{	forceInteractionWithMenu(e.getTargetMenu());	});
			restartMenu.addEventListener(MenuEvent.MENU_CLOSED, function(e:MenuEvent):void	{	forceInteractionWithMenu(e.getTargetMenu());	});

			//Overlay letter on right side of screen when it's fullsize
			FULLSIZE_LETTER_X = 700;

			//Add inventory captions, but keep them invisible and off-stage for now
			for each (var item in inventoryCaptions) {
				addChild(item);
				item.mouseEnabled = false;
				item.mouseChildren = false;
			}
			//Add caption to magnifying glass
			magnifyButton.addEventListener(MouseEvent.MOUSE_OVER, function(e:MouseEvent):void	{	showInventoryCaption(0);	});
			magnifyButton.addEventListener(MouseEvent.MOUSE_OUT, function(e:MouseEvent):void	{	hideInventoryCaption(0);	});
			//Zoom our menu on click, be sure to hide the letter captions
			endGoalMenu.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void	{	endGoalMenu.scaleMenu(FULLSIZE_LETTER_X, 0, canvasRect.width + 190, 503); endGoalMenu.moveSecondLetter(); hideInventoryCaption(1); hideInventoryCaption(2);	});
			//Add hover events for each piece in the letter (except the last one) to show the caption for the first letter
			//We'll add the event listener for the last one (which is hidden) when it gets unlocked
			for(var i = 0; i < endGoalMenu.getPieces().length - 1; i++) {
				var piece = endGoalMenu.getPieces()[i];
				piece.addEventListener(MouseEvent.MOUSE_OVER, function(e:MouseEvent):void	{	if(endGoalMenu.x != FULLSIZE_LETTER_X) showInventoryCaption(1);   });
				piece.addEventListener(MouseEvent.MOUSE_OUT, function(e:MouseEvent):void	{	hideInventoryCaption(1);	});
			}

			//calculate color offsets between new and normal notification colors (seperate components of color within unsigned integer)
			var normalRed:uint = (notificationTextColorNormal.color & 0xFF0000)/0x010000;
			var normalGreen:uint = (notificationTextColorNormal.color & 0x00FF00)/0x000100;
			var normalBlue:uint = (notificationTextColorNormal.color & 0x0000FF)/0x000001;
			var newRed:uint = (notificationTextColorNew.color & 0xFF0000)/0x010000;
			var newGreen:uint = (notificationTextColorNew.color & 0x00FF00)/0x000100;
			var newBlue:uint = (notificationTextColorNew.color & 0x0000FF)/0x000001;
			notificationTextColorNew.redOffset = newRed - normalRed;
			notificationTextColorNew.greenOffset = newGreen - normalGreen;
			notificationTextColorNew.blueOffset = newBlue - normalBlue;

			//define new to normal notification fade timer
			notificationTextColorFadeTime = 10;

			//setup clue text format
			notificationTextFormat = new TextFormat(BaseMenu.titleFormat.font, BaseMenu.titleFormat.size,  notificationTextColorNormal.color,
													BaseMenu.titleFormat.bold, BaseMenu.titleFormat.italic, BaseMenu.titleFormat.underline,
													null, null, TextFormatAlign.CENTER);

			//set notification textfield location and settings
			notificationText.defaultTextFormat = notificationTextFormat;
			notificationText.transform.colorTransform = notificationTextColorNormal;
			notificationText.wordWrap=true;
			notificationText.x = paintingCanvas.x + 150;
			notificationText.y = paintingCanvas.y + 50;
			notificationText.width = paintingCanvas.width - 300;
			notificationText.visible = false;
			notificationText.selectable = false;
			notificationText.mouseEnabled = false;
			notificationText.embedFonts = true;

			ooiManager.resetUnusedOOIList();
			var firstClue:String = ooiManager.pickNextOOI();
			cluesMenu.addClue(firstClue);

			//show unlocked content
			endGoalMenu.showRewards();

			//add ending
			ending.closeMenu();
			addChild(ending);

			//unlock the first pieces of the end goal (remain hidden for now)
			//endGoalMenu.hideRewards();
			for(var r:int = 0; r < EndGoalMenu.freeRewardCount; r++)
				endGoalMenu.unlockReward();

			//Initially hide letter, use can click to view it
			//endGoalMenu.closeMenu();

			//listen for new frame
			addEventListener(Event.ENTER_FRAME, checkEnterFrame);

			//listen for input events
			stage.focus = stage;
			stage.addEventListener(KeyboardEvent.KEY_UP, checkKeysUp);

			//Objects aren't hoverable unless we do this
			//Temporary solution
			helpMenu.openMenu();
			helpMenu.closeMenu();
			endGoalMenu.scaleMenu(FULLSIZE_LETTER_X, 35, canvasRect.width + 190, 503);

			firstLetterBg.graphics.moveTo(endGoalMenu.x, endGoalMenu.y);
			firstLetterBg.graphics.beginFill(0xa9997f, 1);
			firstLetterBg.graphics.drawRoundRect(endGoalMenu.x - 22, endGoalMenu.y - 13, 120, 120, 5, 5);
			firstLetterBg.graphics.endFill();

			//Initially set progress bar
			clueProgressText.text = "Clues Found: " + endGoalMenu.getCluesLeft();
			clueProgressText.selectable = false;
            clueProgressText.embedFonts = true;
			clueProgressText.defaultTextFormat = BaseMenu.altIntroFormat;
			clueProgressText.setTextFormat(BaseMenu.altIntroFormat);
			clueProgress.draw(endGoalMenu.getCluesNotUnlocked(), endGoalMenu.getCluesUnlocked());

			//Set up inventory label
			letterCaption.selectable = false;
            letterCaption.embedFonts = true;
			letterCaption.defaultTextFormat = BaseMenu.altIntroFormat;
			letterCaption.setTextFormat(BaseMenu.altIntroFormat);
			letterCaption.x = clueProgressText.x;
			letterCaption.y = 440;
            letterCaption.height = 30;
			letterCaption.text= "Inventory";
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

            //Move and toggle visiblity of inventory OOICaptions
            //TODO: This should be done where all the other ones are
            if(inventoryCaptions != null && inventoryCaptions.length > 0) {
                for each (var item in inventoryCaptions){
                    var maxWidth:Number = (stage != null) ? stage.stageWidth : 100; //sometimes stage can be null, gg AS3
                    item.mouseEnabled = false;
                    item.x = (mouseX + item.width + 40 >= maxWidth) ? mouseX - item.width - 20 : mouseX + 20;
                    item.y = mouseY - (item.height / 2);
                }
            }

		}

		//handles the release of keys
		public function checkKeysUp(e:KeyboardEvent):void
		{
			//toggle magnifying glass
			if(e.keyCode == Keyboard.SPACE)
			{
				closeDismissibleOverlays(null);
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
			if(indexOfMenu < 0)
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
			ooiManager.addObjectSolvedImagesToList(bitmaps, texturePoints, center, true);
			ooiManager.addObjectHighlightsToList(bitmaps, texturePoints, center, true);

			//magnify
			magnifyingGlass.magnifyBitmaps(bitmaps, texturePoints);
		}

		//handle a correct answer to a clue
		private function handleCorrectAnswer(e:Event)
		{

            //Uncommenting this will make you instantly win the game on the first unlock
            //unlockHiddenPiece();

			//hide the current clue
			hideNotificationText();

			//show the hunted object's found image
			var foundObject = ooiManager.getCurrentOOI();
			if(foundObject)
				foundObject.showSolvedImage();

			//add the piece of the end goal
			var rewardNotification:String = endGoalMenu.unlockReward();
			//Update progress bar and text
			clueProgress.draw(endGoalMenu.getCluesNotUnlocked(), endGoalMenu.getCluesUnlocked());
			clueProgressText.text = "Clues Found: " + endGoalMenu.getCluesLeft();

			//if the most recent reward was the last normal reward, display ending
			if(!goalReached && endGoalMenu.allNormalPiecesAwarded())
			{
				//make the current clue old
				cluesMenu.outdateCurrentClue();
				//show ending
				ending.openMenu();
			}
			//otherwise pick the next clue
			else
			{
				//attempt to pick the next object to hunt and retrieve its clue
				var nextClue:String = ooiManager.pickNextOOI();

				//if a new clue was picked, display it and pass it to the clues menu
				if(nextClue)
				{
					//make the current clue old
					cluesMenu.outdateCurrentClue();

					//add new clue to clue menu
					cluesMenu.addClue(nextClue);

					//post notification of correct answer
					var correctNotification:String = "Correct!\n";
					if(rewardNotification)
						postNotification(correctNotification + rewardNotification);
					else
						postNotification(correctNotification);
				}
				//otherwise show hidden reward
				else
				{
					//make the current clue old
					cluesMenu.outdateCurrentClue();

					//unlock the hidden reward
					unlockHiddenPiece();
				}
			}
		}


		//handle a incorrect answer to a clue
		private function handleIncorrectAnswer(e:Event)
		{
			postNotification("Try Again");
		}

		//unlock the hidden piece of the end goal
		private function unlockHiddenPiece()
		{
			FULLSIZE_LETTER_X = 200;
			//add a new page to the end goal menu and show final reward
			postNotification(endGoalMenu.unlockFinalReward());
			//make the current clue old
			cluesMenu.outdateCurrentClue();

			//congratulate player of truly finishing the gamse
			cluesMenu.addClue(CluesMenu.congratulations);

            endGoalMenu.getLastPiece().addEventListener(MouseEvent.MOUSE_OVER, function(e:MouseEvent):void	{	if(endGoalMenu.x != FULLSIZE_LETTER_X) showInventoryCaption(2);   });
            endGoalMenu.getLastPiece().addEventListener(MouseEvent.MOUSE_OUT, function(e:MouseEvent):void	{	hideInventoryCaption(2);	});

            secondLetterBg.graphics.moveTo(endGoalMenu.x, endGoalMenu.y);
            secondLetterBg.graphics.beginFill(0xa9997f, 1);
            secondLetterBg.graphics.drawRoundRect(endGoalMenu.x + 113, endGoalMenu.y - 13, 120, 120, 5, 5);
            secondLetterBg.graphics.endFill();
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

		private function showInventoryCaption(index:int) {
			if(index is int)
				inventoryCaptions[index].visible = true;
		}

		private function hideInventoryCaption(index:int) {
			if(index is int)
				inventoryCaptions[index].visible = false;
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

		//set whether or not events outside of a menu are allowed
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
	}
}
