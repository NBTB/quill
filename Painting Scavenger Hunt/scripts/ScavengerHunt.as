package
{
	import flash.display.MovieClip;
	import flash.events.*;
	import flash.ui.Keyboard;
	import flash.geom.Point;
	import flash.geom.Rectangle;
		
	public class ScavengerHunt extends MovieClip
	{
		var startGameListener:MenuListener;
		var paintingCanvas:PaintingCanvas = null;
		var ooiManager = null;
		var startUpScreen:SplashScreen;
		var mainMenu:MainMenu;
		var useTutorial:Boolean;
		private var zoomed:Boolean = false;
		private var magnifyingGlass:MagnifyingGlass;		
		
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
			addChild(mainMenu);
			
			//mask the magnifying glass so that it is not drawn beyond the painting
			magnifyingGlass.mask = paintingCanvas.getPaintingMask();
			
			//prepare new list of unused objects of interest and pick the first object
			ooiManager.resetUnusedOOIList();
			ooiManager.pickNextOOI();
			
			/*TODO this might go somewhere else*/
			//display first clue
			ooiManager.displayClue();
			
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
				
				
			/*TODO this should not go here (or even work like this), super temporary*/
			if(ooiManager.clueText.text != "" && ooiManager.clueText.text != OOIManager.wrongAnswer)
			{
				mainMenu.cluesMenu.clueText.text = ooiManager.clueText.text;
				mainMenu.cluesMenu.clueText.wordWrap = true;
			}
		}
		
		//handles the release of keys
		public function checkKeysUp(e:KeyboardEvent):void
		{
			//toggle magnifying glass
			if(e.keyCode == Keyboard.SPACE)
				toggleZoom();
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
	}
}