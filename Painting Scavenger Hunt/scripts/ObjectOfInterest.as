package
{
	import flash.display.MovieClip;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.geom.Point;
	import flash.geom.Matrix;
	import flash.events.Event;
	import flash.net.URLRequest;
	
	public class ObjectOfInterest extends MovieClip
	{
		private var objectName:String = null;
		private var hitmapFilename = null;
		private var outlineFilename = null;
		private var hitmap:Bitmap = null;
		private var outline:Bitmap = null;
		private var fullsizeHitmap:Bitmap = null;
		private var fullsizeOutline:Bitmap = null;
		
		public function ObjectOfInterest(objectName:String, hitmapFilename:String, outlineFilename:String, x:Number, y:Number)
		{
			this.objectName = objectName;
			this.hitmapFilename = hitmapFilename;
			this.outlineFilename = outlineFilename;
			this.x = x;
			this.y = y;
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
																							 	hitmap = Bitmap(LoaderInfo(e.target).content);	
																								hitmap.x = x;
																								hitmap.y = y;
																								fullsizeHitmap = new Bitmap(hitmap.bitmapData);
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
																								outline.x = x;
																								outline.y = y;
																								fullsizeOutline = new Bitmap(outline.bitmapData);
																								if(hitmap && outline)
																									dispatchEvent(new Event(Event.COMPLETE)); 
																							  });
			outlineLoader.load(new URLRequest(outlineFilename));
		}
		
		public function scaleBitmaps(scaleFactor:Number)
		{
			if(hitmap)
			{
				hitmap.width *= scaleFactor;
				hitmap.height *= scaleFactor;
			}
			if(outline)
			{
				outline.width *= scaleFactor;
				outline.height *= scaleFactor;
			}
		}
		
		public function hitTest(testPoint:Point, alphaThreshold:Number = 1):Boolean
		{
			//if the test point is within in the hitmap's bounding box, prepare to test against pixels
			if(hitmap.hitTestPoint(testPoint.x, testPoint.y))
			{
				//if no hitmap exists, return failure
				if(!hitmap)
					return false;
				
				//create a temporary hitmap to be used in contact detection, fill it will transparent pixels for now
				var testHitMap:Bitmap = new Bitmap(new BitmapData(hitmap.width, hitmap.height, true, 0x00000000));
				
				//draw the original hitmap into the duplicate, scaling the actual pixel data to fit the duplicate
				//this is done because the dimensions of the hitmap and its internal pixel data may not be identical, the duplicate's dimensions will be identical
				testHitMap.bitmapData.draw(hitmap, new Matrix(hitmap.width/hitmap.bitmapData.width, 0, 0, hitmap.height/hitmap.bitmapData.height));
				
				//align the duplicate with the original
				testHitMap.x = hitmap.x;
				testHitMap.y = hitmap.y;
				
				//if the test point hits any pixel whose opacity meets or exceeds the given threshod, return a success
				if(testHitMap.bitmapData.hitTest(new Point(testHitMap.x, testHitMap.y), alphaThreshold, testPoint))
					return true;
				
				//dispose of the data used by the temporary hitmap
				testHitMap.bitmapData.dispose();
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
		public function getFullsizeHitmap():Bitmap		{	return this.fullsizeHitmap;		}
		public function getFullsizeOutline():Bitmap		{	return this.fullsizeOutline;	}
	}
}