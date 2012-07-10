package
{
	import flash.display.*;
	import flash.events.*;
	import flash.ui.*;	
	import flash.geom.Point;
	import flash.geom.Matrix;
	import flash.net.URLRequest;
	
	public class ObjectOfInterest extends MovieClip
	{
		private var objectName:String = null;
		private var hitmapFilename = null;
		private var outlineFilename = null;
		private var hitmap:Bitmap = null;
		private var outline:Bitmap = null;
		private var fullsizeOutline:Bitmap = null;
		public var clue:String = null;
		private var scaleFactor:Number = 1;
		private var mousedOver:Boolean = false;
		
		public function ObjectOfInterest(objectName:String, hitmapFilename:String, outlineFilename:String, x:Number, y:Number, scaleFactor:Number = 1)
		{
			//set object name
			this.objectName = objectName;
			
			//store locations of hitmap and outline image files
			this.hitmapFilename = hitmapFilename;
			this.outlineFilename = outlineFilename;
			
			//set coordinates
			this.x = x;
			this.y = y;
			
			//store clue
			this.clue = clue;
			
			//store scale to be used when loading bitmaps
			if(scaleFactor  <= 0)
				scaleFactor = 1;
			this.scaleFactor = scaleFactor;
			
			//prevent object from capturing mouse input initially
			mouseEnabled = false;
			mouseChildren = false;
			
			//track the start of a new frame
			addEventListener(Event.ENTER_FRAME, enterFrame);
		}
		
		public function enterFrame(e:Event)
		{
			if(parent)
			{
				if(hitTest(new Point(parent.mouseX, parent.mouseY)))
				{
					if(!mousedOver)
					{
						dispatchEvent(new MouseEvent(MouseEvent.MOUSE_OVER));
						mousedOver = true;
					}
				}
				else
				{
					if(mousedOver)
					{
						dispatchEvent(new MouseEvent(MouseEvent.MOUSE_OUT));
						mousedOver = false;
					}
				}
			}												  
		}
		
		public function loadComponents():void
		{
			loadHitmap();
			loadOutline();
		}
		
		
		
		private function loadHitmap():void
		{
			var hitmapLoader:Loader = new Loader();
			hitmapLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event):void   
																							 {	
																							 	var tempHitmap:Bitmap = Bitmap(LoaderInfo(e.target).content);	
																								hitmap = new Bitmap(new BitmapData(tempHitmap.bitmapData.width * scaleFactor, tempHitmap.bitmapData.height * scaleFactor, true, 0x00000000));
																								hitmap.bitmapData.draw(tempHitmap, new Matrix(scaleFactor, 0, 0, scaleFactor));
																								tempHitmap.bitmapData.dispose();
																								if(hitmap && outline)
																									dispatchEvent(new Event(Event.COMPLETE)); 
																							 });
			hitmapLoader.load(new URLRequest(hitmapFilename));
		}
		
		private function loadOutline():void
		{
			var outlineLoader:Loader = new Loader();
			outlineLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event):void	
																							  {	
																							  	outline = Bitmap(LoaderInfo(e.target).content);
																								outline.width *= scaleFactor;
																								outline.height *= scaleFactor;
																								fullsizeOutline = new Bitmap(outline.bitmapData);
																								addChild(outline);
																								if(hitmap && outline)
																									dispatchEvent(new Event(Event.COMPLETE)); 
																							  });
			outlineLoader.load(new URLRequest(outlineFilename));
		}
				
		public function hitTest(testPoint:Point, alphaThreshold:Number = 1):Boolean
		{
			//if the test point is within in the hitmap's bounding box, prepare to test against pixels
			if(hitTestPoint(testPoint.x, testPoint.y))
			{
				//if no hitmap exists, return failure
				if(!hitmap)
					return false;
				
				//if the given point makes contact with the hitmap, return a success
				if(hitmap.bitmapData.hitTest(new Point(x, y), alphaThreshold, testPoint))
					return true;
			}
			
			//by default return a failure
			return false;
		}
		
		public function addOutlineToList(bitmapList:Array, texturePointList:Array, samplePoint:Point, useFullsize:Boolean = false)
		{
			//if flagged to use fullsize outline, add it to the bitmap list
			if(useFullsize)
				bitmapList.push(fullsizeOutline);
			//otherwise, add the scaled outline
			else
				bitmapList.push(outline);
			
			//add texture coordinates to the texture coordinate list
			var objectTexturePoint:Point = new Point();
			objectTexturePoint.x = (samplePoint.x - outline.x) / outline.width;
			objectTexturePoint.y = (samplePoint.y - outline.y) / outline.height;
			texturePointList.push(objectTexturePoint);
		}
		
		public function showOutline():void				{	outline.visible = true;		}
		public function hideOutline():void				{	outline.visible = false;	}
		public function isOutlined():Boolean			{	return outline.visible;		}
		
		public function getObjectName():String			{	return this.objectName;			}
		public function getHitmap():Bitmap				{	return this.hitmap;				}
		public function getOutline():Bitmap				{	return this.outline;			}
		public function getFullsizeOutline():Bitmap		{	return this.fullsizeOutline;	}
	}
}