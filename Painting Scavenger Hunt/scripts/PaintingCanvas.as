package
{
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.events.Event;
	import flash.xml.*;
	import flash.display.DisplayObjectContainer;
	import flash.display.MovieClip;
	import flash.display.Shape;
	import flash.display.Bitmap;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import ObjectOfInterest;
	
	public class PaintingCanvas extends MovieClip
	{
		var canvasWidth:Number;
		var canvasHeight:Number;
		private var painting:Bitmap = null;
		private var fullsizePainting:Bitmap = null;
		private var paintingScale:Number = 1;
		private var objectsOfInterest:Array = null;
		private var ooiMousedOver:ObjectOfInterest = null;
		private var ooiFound:Array = null;		
		private var paintingMask:Shape;
		
		public function PaintingCanvas(x:Number, y:Number, canvasWidth:Number, canvasHeight:Number):void
		{			
			//store location and size (do not actually scale canvas)
			this.x = x;
			this.y = y;
			this.canvasWidth = canvasWidth;
			this.canvasHeight = canvasHeight;
						
			//create empty array of objects of interest
			objectsOfInterest = new Array();
		}
		
		public function displayPainting(painting:Bitmap)
		{
			//create bitmap from file and make a copy that will not be scaled
			this.painting = painting;
			fullsizePainting = new Bitmap(painting.bitmapData);
			
			//adjust painting to fit the width of the container
			paintingScale = canvasWidth / painting.width;
			painting.width *= paintingScale;
			painting.height *= paintingScale;
			
			//add bitmap to container
			addChild(painting);
			
			//create mask around painting
			paintingMask = new Shape();
			paintingMask.graphics.beginFill(0xffffff, 1);
			paintingMask.graphics.drawRect(painting.x, painting.y, painting.width, painting.height);
			paintingMask.graphics.endFill();
			addChildAt(paintingMask, getChildIndex(painting));
		}
		
		public function addObjectOfInterest(newObject:ObjectOfInterest)
		{
			//add new object to list
			objectsOfInterest.push(newObject);
			
			//get child index of painting
			var paintingIndex:int = getChildIndex(painting);
			
			//place hitmap below painting
			addChildAt(newObject.getHitmap(), paintingIndex);
			paintingIndex++;
			
			//place outine above painting
			addChildAt(newObject.getOutline(), paintingIndex + 1);
			newObject.hideOutline();
			
			//scale new object in the same way that the painting was scaled
			newObject.scaleBitmaps(paintingScale);			
		}
		
		public function outlineObjectsAtPoint(point:Point)
		{			
			//outline any objects that make contact with the given point
			for(var i:int; i < objectsOfInterest.length; i++)
			{
				//address object of interest
				var ooi:ObjectOfInterest = objectsOfInterest[i];
				
				//if the object is under the cursor, show its outline
				if(ooi.hitTest(point))
					ooi.showOutline();
				//otherwise, hide its outline
				else
					ooi.hideOutline();
			}
		}
		
		public function addPaintingToList(bitmapList:Array, texturePointList:Array, samplePoint:Point, useFullsize:Boolean = false)
		{				
			//if flagged to use fullsize painting, add it to the bitmap list
			if(useFullsize)
				bitmapList.push(fullsizePainting);
			//otherwise, add the scaled outline
			else
				bitmapList.push(painting);
			
			//calculate the texture coordinates on the painting of the magnified center
			var paintingTexturePoint:Point = new Point();
			paintingTexturePoint.x = (samplePoint.x - painting.x) / painting.width;
			paintingTexturePoint.y = (samplePoint.y - painting.y) / painting.height;
			texturePointList.push(paintingTexturePoint);
			
		}
		
		public function addObjectOutlinesToList(bitmapList:Array, texturePointList:Array, samplePoint:Point, useFullsize:Boolean = false)
		{
			for(var i:int = 0; i < objectsOfInterest.length; i++)
				if(objectsOfInterest[i].isOutlined())
					objectsOfInterest[i].addOutlineToList(bitmapList, texturePointList, new Point(samplePoint.x, samplePoint.y), useFullsize);
		}
		
		public function getPaintingMask():Shape	{	return paintingMask;	}
	}
}