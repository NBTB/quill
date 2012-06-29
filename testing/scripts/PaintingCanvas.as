package
{
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.xml.*;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	import MagnifyingGlass;
	
	public class PaintingCanvas extends MovieClip
	{
		var canvasWidth:Number;
		var canvasHeight:Number;
		private var painting:Bitmap = null;
		private var fullsizePainting:Bitmap = null;
		private var zoomed:Boolean = false;
		private var magnifyingGlass:MagnifyingGlass;
		private var paintingMask:Shape;
		
		public function PaintingCanvas(x:Number, y:Number, canvasWidth:Number, canvasHeight:Number, magnifyingGlassZoom:Number = 1, magnifyingGlassRadius:Number = 100) : void
		{			
			//store location and size (do not actually scale canvas)
			this.x = x;
			this.y = y;
			this.canvasWidth = canvasWidth;
			this.canvasHeight = canvasHeight;
			
			//create magnifying glass
			magnifyingGlass = new MagnifyingGlass(magnifyingGlassZoom, magnifyingGlassRadius);
			
			//prepare to be added to stage
			addEventListener(Event.ADDED_TO_STAGE, addedToStage);
		}
		
		public function addedToStage(e:Event)
		{
			//listen for input
			stage.addEventListener(KeyboardEvent.KEY_DOWN, checkKeysUp);
			addEventListener(MouseEvent.MOUSE_MOVE, checkMouseMove);
		}
		
		public function displayPainting(painting:Bitmap)
		{
			//create bitmap from file and make a copy that will not be scaled
			this.painting = painting;
			fullsizePainting = new Bitmap(painting.bitmapData);
			
			//adjust painting to fit the width of the container
			var scale:Number = canvasWidth / painting.width;
			painting.width *= scale;
			painting.height *= scale;
			
			//add bitmap to container
			addChild(painting);
			
			//create mask around painting
			paintingMask = new Shape();
			paintingMask.graphics.beginFill(0xffffff, 1);
			paintingMask.graphics.drawRect(painting.x, painting.y, painting.width, painting.height);
			paintingMask.graphics.endFill();
			addChild(paintingMask)
			
			//mask the magnifying glass so that it is not drawn beyond the painting
			magnifyingGlass.mask = paintingMask;
		}
		
		public function checkKeysUp(e:KeyboardEvent) : void
		{
			if(e.keyCode == Keyboard.SPACE)
				toggleZoom();
		}
		
		public function checkMouseMove(e:MouseEvent) : void
		{
			if(zoomed)
				placeMagnifyingGlass(mouseX, mouseY);
		}
		
		public function toggleZoom() : void
		{
			//toggle zoom
			zoomed = !zoomed;
			
			//if zoom started, draw magnifying glass
			if(zoomed)
			{
				placeMagnifyingGlass(mouseX, mouseY);
				addChild(magnifyingGlass);
			}
			//if zoom ended, remove magnifying glass
			else
			{
				removeChild(magnifyingGlass);
			}
			
		}
		
		public function placeMagnifyingGlass(centerX:Number, centerY:Number) : void
		{
			//clmap the magnifying glass to the boundaries of the painting
			var minX:Number = x + painting.x;
			var maxX:Number = x + painting.x + painting.width;
			var minY:Number = y + painting.y;
			var maxY:Number = y + painting.y + painting.height;
			if(centerX < minX)
				centerX = minX;
			else if(centerX > maxX)
				centerX = maxX;
			if(centerY < minY)
				centerY = minY;
			else if(centerY > maxY)
				centerY = maxY;
			
			//position magnfying glass
			magnifyingGlass.x = centerX;
			magnifyingGlass.y = centerY;
			
			//calculate the texture coordinates of the magnified center
			var s:Number = (centerX - painting.x - x) / painting.width;
			var t:Number = (centerY - painting.y - y) / painting.height;
			
			//magnify
			magnifyingGlass.magnifyBitmap(fullsizePainting, s, t);
		}
	}
}