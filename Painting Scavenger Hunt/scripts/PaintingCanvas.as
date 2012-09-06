package scripts
{
    import flash.net.URLLoader;
    import flash.net.URLRequest;
    import flash.events.*;
    import flash.xml.*;
    import flash.display.DisplayObjectContainer;
    import flash.geom.ColorTransform;
    import flash.text.*;
    import flash.display.MovieClip;
    import flash.display.Shape;
    import flash.display.Bitmap;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.utils.Timer;
     
    public class PaintingCanvas extends MovieClip
    {
        var canvasWidth:Number;                             //width of canvas
        var canvasHeight:Number;                            //height of canvas
        private var painting:Bitmap = null;                 //painting displayed on canvas
        private var fullsizePainting:Bitmap = null;         //unscaled painting
        private var paintingScale:Number = 1;               //scale factor of painting to fit a given scene         
        private var paintingMask:Shape;                     //mask around painting used to cover display objects that should not be seen beyond such bounds
		private var nonInteractivePainting:Bitmap = null;	//painting to be used when interaction is not allowed
         
        public static const INTERACTIVE:int = 0;
		public static const NON_INTERACTIVE:int = 1;
		 
        //construct a painting canvas with a position and dimensions
        public function PaintingCanvas(x:Number, y:Number, canvasWidth:Number, canvasHeight:Number):void
        {                      
            //store location and size (do not actually scale canvas)
            this.x = x;
            this.y = y;
            this.canvasWidth = canvasWidth;
            this.canvasHeight = canvasHeight;
			
			//listen for being removed from the display list
			addEventListener(Event.REMOVED_FROM_STAGE, function(e:Event):void
																		{
																			//dispose of bitmaps
																			if(painting)
																			{
																				painting.bitmapData.dispose();
																				painting = null;
																				fullsizePainting = null;
																			}
																			if(nonInteractivePainting)
																			{
																				nonInteractivePainting.bitmapData.dispose();
																				nonInteractivePainting= null;
																			}
																		});
        }
         
        //display painting on canvas
        public function displayPainting()
        {                     
            //add bitmap to display list
            addChild(painting);
             
            //create mask around painting
            paintingMask = new Shape();
            paintingMask.graphics.beginFill(0xffffff, 1);
            paintingMask.graphics.drawRect(painting.x, painting.y, painting.width, painting.height);
            paintingMask.graphics.endFill();
            addChildAt(paintingMask, getChildIndex(painting));                 
        }         
		
		//switch between interactive and non-interactive paintings
		public function updatePaintingMode(paintingMode:int)
		{
			switch(paintingMode)
			{
				case INTERACTIVE:
					if(nonInteractivePainting.parent == this)
					{
						addChildAt(painting, getChildIndex(nonInteractivePainting));
						removeChild(nonInteractivePainting);
					}
					break;
				case NON_INTERACTIVE:
					if(painting.parent == this)
					{
						addChildAt(nonInteractivePainting, getChildIndex(painting));
						removeChild(painting);
					}
					break;
			}
		}
         
        //add the painting to a list of bitmaps along with corresponding texture points based on a given sample point relative to the painting's upper-left corner
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
         
        public function getCanvasWidth():Number     {   return canvasWidth;     }
        public function getCanvasHeight():Number    {   return canvasHeight;    }      
        public function getPaintingWidth():Number   {   return painting.width;  }
        public function getPaintingHeight():Number  {   return painting.height; }      
        public function getPaintingMask():Shape     {   return paintingMask;    }
        public function getPaintingScale():Number   {   return paintingScale;   }
		
		//attach a painting and fit it to the canvas
		public function attachPainting(bitmap:Bitmap):void
		{
			//create bitmap from data and make a copy that will not be scaled
            painting = bitmap;
            fullsizePainting = new Bitmap(painting.bitmapData);
             
            //adjust painting to fit the width of the container
            paintingScale = canvasWidth / painting.width;
            painting.width *= paintingScale;
            painting.height *= paintingScale;
		}
		
		//attach a non-interactive painting and fit it to the canvas
		public function attachNonInteractivePainting(bitmap:Bitmap):void
		{
			//store bitmap as non-interactive painting
           	nonInteractivePainting = bitmap;
             
            //adjust non-interactive painting to fit the width of the container
            var nonInteractivePaintingScale:Number = canvasWidth / nonInteractivePainting.width;
            nonInteractivePainting.width *= nonInteractivePaintingScale;
            nonInteractivePainting.height *= nonInteractivePaintingScale;
		}
    }
}