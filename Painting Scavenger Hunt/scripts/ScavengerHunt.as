package
{
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.MouseEvent;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import HuntImporter;
	import PaintingCanvas;
	import MagnifyingGlass;
		
	public class ScavengerHunt extends MovieClip
	{
		var startGameListener:MenuListener;
		var paintingCanvas:PaintingCanvas = null;
		var startUpScreen:SplashScreen;
		var mainMenu:MainMenu;
		private var zoomed:Boolean = false;
		private var magnifyingGlass:MagnifyingGlass;
		
		public function ScavengerHunt():void
		{	
			//Add the event listeners for the mouse and keyboard, to be used during the main painting.
			//addEventListener(Event.ADDED_TO_STAGE, addedToStage);
			
			//Program starts
			startMenu();
		}
		
		public function startMenu():void
		{
			//Listener that updates when the game is started
			startGameListener = new MenuListener();
			
			//Start up screen 
			startUpScreen = new SplashScreen(startGameListener);
			addChild(startUpScreen);
			
			//If the game has started, go to the main game function
			startGameListener.addEventListener(MenuListener.GAME_START, gameStart);			
		}
		
		public function gameStart(e:Event):void
		{
						
			//listen for input
			addEventListener(MouseEvent.MOUSE_MOVE, checkMouseMove);
			stage.addEventListener(KeyboardEvent.KEY_UP, checkKeysUp);
			
			//create canvas to fill stage
			paintingCanvas = new PaintingCanvas(0, 0, stage.stageWidth, stage.stageHeight);
			addChild(paintingCanvas);			
			
			//create magnifying glass
			magnifyingGlass = new MagnifyingGlass();
			
			//import hunt parameters
			var importer:HuntImporter = new HuntImporter();
			importer.importHunt("scavenger hunt params.xml", paintingCanvas, magnifyingGlass);
			
			//Does the user want the tutorial when the game starts up?
			mainMenu = new MainMenu(startUpScreen.useTut);
			addChild(mainMenu);
			
			//Remove the splash screen, since the user has started the game.
			removeChild(startUpScreen);

		}
		
		//has 
		/*public function addedToStage(e:Event)
		{
			//listen for input
			addEventListener(MouseEvent.MOUSE_MOVE, checkMouseMove);
			stage.addEventListener(KeyboardEvent.KEY_UP, checkKeysUp);						
		}*/
	
		public function checkMouseMove(e:MouseEvent):void
		{
			
			//outline any objects of interest that are moused over
			paintingCanvas.outlineObjectsAtPoint(new Point(paintingCanvas.mouseX, paintingCanvas.mouseY));
			
			//if the magnifying glass is being used, draw through its lens
			if(zoomed)
				placeMagnifyingGlass(new Point(paintingCanvas.mouseX, paintingCanvas.mouseY));
		}
		
		public function checkKeysUp(e:KeyboardEvent):void
		{
			//toggle magnifying glass
			if(e.keyCode == Keyboard.SPACE)
				toggleZoom();
		}
		
		public function toggleZoom():void
		{
			//toggle zoom
			zoomed = !zoomed;
			
			//if zoom started, draw magnifying glass
			if(zoomed)
			{
				placeMagnifyingGlass(new Point(paintingCanvas.mouseX, paintingCanvas.mouseY));
				addChild(magnifyingGlass);
			}
			//otherwise, remove magnifying glass
			else
			{
				removeChild(magnifyingGlass);
			}
		}	
		
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
			paintingCanvas.addObjectOutlinesToList(bitmaps, texturePoints, center, true);
			
			//magnify
			magnifyingGlass.magnifyBitmaps(bitmaps, texturePoints);
		}
	}
}