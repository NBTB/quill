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
		var startGameListener:MenuListener;
		var paintingCanvas:PaintingCanvas = null;
		var ooiManager = null;
		var startUpScreen:SplashScreen;
		var mainMenu:MainMenu;									
		var useTutorial:Boolean;								
		private var zoomed:Boolean = false;						//flag tracking whether or not the magnifying glass is active
		private var magnifyingGlass:MagnifyingGlass;			//magnifying glass used to enlarge portions of the scene
		private var clueTimer:Timer = null;						//timer used to trigger the hiding of the clue textfield
		private var clueText:TextField = new TextField(); 		//textfield to hold a newly unlocked clue
		private var needNewClue:Boolean = false;				//flag that tracks whether or not a new clue is needed
		//private var nextClueButtonImage:Sprite = null;
		//private var nextClueButton:SimpleButton = null;
		private var nextClueButton:Sprite = null;
		
		private var clueTextFormat:TextFormat;				 	//text format of the clue textfield
		
		//construct scavanger hunt
		public function ScavengerHunt():void
		{	
			//show start menu
			startMenu();			
		}
				
		public function startMenu():void
		{
			startGameListener = new MenuListener();
			startUpScreen = new SplashScreen(startGameListener);
			
			addChild(startUpScreen);
			startGameListener.addEventListener(MenuListener.GAME_START, function(e:Event):void	{	initGame()	});
			useTutorial = startUpScreen.useTut;
		}
		
		public function initGame():void
		{			
			//create in-game children that will handle specific interaction
			paintingCanvas = new PaintingCanvas(0, 0, stage.stageWidth, stage.stageHeight);
			ooiManager = new OOIManager();
			magnifyingGlass = new MagnifyingGlass();
			mainMenu = new MainMenu(startUpScreen.useTut);
			clueText = new TextField();
			//nextClueButtonImage = new Sprite();
			//nextClueButton = new SimpleButton(nextClueButtonImage);
			
			
			//setup clue text format
			clueTextFormat = new TextFormat("Edwardian Script ITC", 25, 0x40E0D0);
			clueTextFormat.align = TextFormatAlign.CENTER;
			
			//set clue textfield location and settings
			clueText.defaultTextFormat = clueTextFormat;
			clueText.wordWrap=true;
			clueText.x=66;
			clueText.y=60;
			clueText.width=474;
			clueText.visible = false;
			clueText.mouseEnabled = false;
			
			//setup next clue button states
			/*nextClueButtonImage.graphics.lineStyle(1, 0x836A35);
			nextClueButtonImage.graphics.beginFill(0xffff00);
			nextClueButtonImage.graphics.drawRect(0, 0, 20, 20);
			nextClueButtonImage.graphics.endFill();	
			
			//position and next clue button
			nextClueButton.x = 280;
			nextClueButton.y = 360;
			nextClueButton.visible = false;*/
			
			/*TODO this should be made to work with a SimpleButton containing this sprite*/
			nextClueButton = new Sprite();
			nextClueButton.graphics.lineStyle(1, 0x836A35);
			nextClueButton.graphics.beginFill(0xffff00);
			nextClueButton.graphics.drawRect(0, 0, 20, 20);
			nextClueButton.graphics.endFill();	
			nextClueButton.x = 280;
			nextClueButton.y = 360;
			nextClueButton.visible = true;
			
			//load hunt information and listen for completion
			var importer:HuntImporter = new HuntImporter();
			importer.addEventListener(Event.COMPLETE, function(e:Event):void{	startGame();	});
			importer.importHunt("scavenger hunt params.xml", paintingCanvas, ooiManager, magnifyingGlass);
		}
		
		public function startGame():void
		{
			//remove start up menu from display list
			removeChild(startUpScreen);							
			
			//add in-game children to display list
			addChild(paintingCanvas);
			addChild(ooiManager);
			addChild(magnifyingGlass);
			addChild(clueText);	
			addChild(nextClueButton);
			addChild(mainMenu);
			
			//mask the magnifying glass so that it is not drawn beyond the painting
			magnifyingGlass.mask = paintingCanvas.getPaintingMask();
			
			//create clue timer
			clueTimer = new Timer(3 * 1000, 1);
			
			//listen for the completion of the clue timer
			clueTimer.addEventListener(TimerEvent.TIMER, function(e:TimerEvent):void
																		  {
																			//reset clue time and hide the clue text box
																			clueTimer.reset();
																			clueText.text = ""
																			clueText.visible = false;
																		  });
			
			//prepare new list of unused objects of interest and pick the first object
			ooiManager.resetUnusedOOIList();
			var firstClue:String = ooiManager.pickNextOOI();
			mainMenu.cluesMenu.addClue(firstClue);
			
			//listen for correct answers to clues
			ooiManager.addEventListener(OOIManager.CORRECT, handleCorrectAnswer);
			
			//listen for incorrect answers to clues
			ooiManager.addEventListener(OOIManager.INCORRECT, handleIncorrectAnswer);
			
			//listen for the next clue button being clicked
			nextClueButton.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void	{	showNextClue();	});
			
			//listen for the clues menu being opened
			mainMenu.cluesMenu.addEventListener(BaseMenu.MENU_OPENED, function(e:Event):void	
																					   {
																						   //if the next clue button is visible, hide it 
																						   //the clue will appear in the clues menu
																						   if(nextClueButton.visible)
																						   	nextClueButton.visible = false;
																					   });
			
			//listen for input events
			stage.focus = stage;
			addEventListener(MouseEvent.MOUSE_MOVE, checkMouseMove);
			stage.addEventListener(KeyboardEvent.KEY_UP, checkKeysUp);
		}		
		
		//handle movement of mouse
		public function checkMouseMove(e:MouseEvent):void
		{			
			//if the magnifying glass is being used, draw through its lens
			if(zoomed)
				placeMagnifyingGlass(new Point(paintingCanvas.mouseX, paintingCanvas.mouseY));
		}
		
		//handles the release of keys
		public function checkKeysUp(e:KeyboardEvent):void
		{
			//toggle magnifying glass
			if(e.keyCode == Keyboard.SPACE)
				toggleZoom();
				
			//get next clue
			/*if(e.charCode == 67 || e.charCode == 99) //c key 
			{
				if(needNewClue)
				{
					
					//attempt to pick the next object to hunt and retrieve its clue
					var nextClue:String = ooiManager.pickNextOOI();
					
					//if a new clue was picked, display it and pass it to the clues menu
					if(nextClue)
					{
						postToClueText(nextClue);
						mainMenu.cluesMenu.addClue(nextClue);
					}
					//otherwise, notify the user that the hunt has been completed
					else
						postToClueText(OOIManager.NO_CLUES_NOTIFY);
						
					//a new clue is no longer needed 
					needNewClue = false;
				}
			}*/
		}
		
		//toggle use of magnifying glass
		public function toggleZoom():void
		{
			//toggle zoom
			zoomed = !zoomed;
			
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
			magnifyingGlass.place(center, canvasBounds);
			
			//create arrays to pass to magnifying glass
			var bitmaps:Array = new Array();
			var texturePoints:Array = new Array();
			
			//add magnified canvas
			paintingCanvas.addPaintingToList(bitmaps, texturePoints, center, true);
			
			//add magnified object outlines
			ooiManager.addObjectOutlinesToList(bitmaps, texturePoints, center, true);
			
			//magnify
			magnifyingGlass.magnifyBitmaps(bitmaps, texturePoints);
		}
		
		//handle a correct answer to a clue
		private function handleCorrectAnswer(e:Event)
		{	
			//close menus
			mainMenu.closeMenus();
		
			//attempt to pick the next object to hunt and retrieve its clue
			var nextClue:String = ooiManager.pickNextOOI();			
			
			//if a new clue was picked, display it and pass it to the clues menu
			if(nextClue)
			{
				//show next clue button
				nextClueButton.visible = true;
				
				//add new clue to clue menu
				mainMenu.cluesMenu.addClue(nextClue);
			}
			//otherwise, notify the user that the hunt has been completed
			else
				postToClueText(OOIManager.NO_CLUES_NOTIFY);
				
			//make the current clue old
			mainMenu.cluesMenu.outdateCurrentClue();
		}
		
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
		
		private function postToClueText(textToPost:String)
		{
			//display notification
			clueText.visible = true;
			clueText.text = textToPost;
			
			//restart the clue hiding timer
			clueTimer.reset();
			clueTimer.start();
		}
	}
}