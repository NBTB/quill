package
{
	import flash.display.MovieClip;
	import flash.display.Bitmap;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.geom.Point;
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
			hitmap.width *= scaleFactor;
			hitmap.height *= scaleFactor;
			outline.width *= scaleFactor;
			outline.height *= scaleFactor;
		}
		
		public function hitTest(testPoint:Point, alphaThreshold:Number = 255):Boolean
		{
			//if the object's hitmap makes contact with the test point, return a success
			/*TODO get bitmapData.hitTest to work*/
			if(hitmap.hitTestPoint(testPoint.x, testPoint.y))
				if(true)//(hitmap.bitmapData.hitTest(new Point(hitmap.x, hitmap.y), alphaThreshold, testPoint))
					return true;
					
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