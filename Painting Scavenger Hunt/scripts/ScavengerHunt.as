﻿package
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
		var useTutorial:Boolean;
		private var zoomed:Boolean = false;
		private var magnifyingGlass:MagnifyingGlass;
		
		public function ScavengerHunt():void
		{	
			
			startMenu();	
			
			
		}
		
		public function startMenu():void
		{
			
			startGameListener = new MenuListener();
			startUpScreen = new SplashScreen(startGameListener);
			
			addChild(startUpScreen);
			startGameListener.addEventListener(MenuListener.GAME_START, gameStart);
			useTutorial = startUpScreen.useTut;
			
			
		}
		
		public function gameStart(e:Event):void
		{
			removeChild(startUpScreen);	
			
						
			
			//create canvas to fill stage
			paintingCanvas = new PaintingCanvas(0, 0, stage.stageWidth, stage.stageHeight);
			addChild(paintingCanvas);
			
			//listen for input events
			stage.focus = stage;
			addEventListener(MouseEvent.MOUSE_MOVE, checkMouseMove);
			stage.addEventListener(KeyboardEvent.KEY_UP, checkKeysUp);
			
			//create magnifying glass
			magnifyingGlass = new MagnifyingGlass();
			
			//Does the user want the tutorial when the game starts up?
			mainMenu = new MainMenu(startUpScreen.useTut);
			addChild(mainMenu);
			
			//import hunt parameters
			var importer:HuntImporter = new HuntImporter();
			importer.importHunt("scavenger hunt params.xml", paintingCanvas, magnifyingGlass);
		}		
	
		public function checkMouseMove(e:MouseEvent):void
		{			
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