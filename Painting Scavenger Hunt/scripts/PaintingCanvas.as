package
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
	import ObjectOfInterest;
	
	public class PaintingCanvas extends MovieClip
	{
		var canvasWidth:Number;
		var canvasHeight:Number;
		private var painting:Bitmap = null;
		private var fullsizePainting:Bitmap = null;
		private var paintingScale:Number = 1;
		public var objectsOfInterest:Array = null;
		private var ooiUnused:Array = null;
		private var ooiFound:Array = null;		
		private var currentOOI:ObjectOfInterest = null;
		private var paintingMask:Shape;
		var showCaption:Boolean;//if true, hoverCaption is visible
		public static var clueCounter:Number=0; //the current clue you are working on
		public static var prevCounter:Number=9; //the previous clue you solved
		var textTimer:Number=0; //times how long the clue text is available
		var clueTimer:Timer = null;
		var captionText:String="";//the caption text
		var counter:Number=0;//puts a delay on when the hover caption appears
		var captionField:TextField = new TextField();
		var clueText:TextField = new TextField(); //the text field the clue appears in
		var format:TextFormat = new TextFormat(); //formats the textfield with color, fonts
		var format2:TextFormat = new TextFormat(); //formats the textfield with color, fonts
		var wrongAnswer:String = "That is not the answer to the riddle"; //appears in clueText when you guess the wrong clue
		
		public function PaintingCanvas(x:Number, y:Number, canvasWidth:Number, canvasHeight:Number):void
		{						
			//store location and size (do not actually scale canvas)
			this.x = x;
			this.y = y;
			this.canvasWidth = canvasWidth;
			this.canvasHeight = canvasHeight;
			
			//create empty array of objects of interest
			objectsOfInterest = new Array();			
			
			//create clue timer
			clueTimer = new Timer(3 * 1000, 1);
			clueTimer.addEventListener(TimerEvent.TIMER, function(e:TimerEvent):void
																		  {
																			clueTimer.reset();
																			clueText.text = ""
																			clueText.visible = false;
																		  });
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
			
			format.size=30;
			format.color=0x40E0D0;
			format.font="Edwardian Script ITC";
			format2.size=20;
			format2.color=0x40E0D0;			
			clueText.setTextFormat(format);
			clueText.defaultTextFormat=format;
			captionField.setTextFormat(format2);
			captionField.defaultTextFormat=format2;			
			addChild(clueText);			
			addChild(captionField);

			//set clue textfield location and settings		
			//clueText.autoSize = TextFieldAutoSize.CENTER;
			clueText.wordWrap=true;
			clueText.x=66;
			clueText.y=68;
			clueText.width=474;
			captionField.width = 474;
		}
										
		public function addObjectOfInterest(newObject:ObjectOfInterest)
		{
			//add new object to list
			objectsOfInterest.push(newObject);
			
			//add new object as a display list child
			addChild(newObject);			
			
			//listen for when the cursor begins to hover over the new object
			newObject.addEventListener(MouseEvent.MOUSE_OVER, function(e:MouseEvent):void
																					{	
																						var targetObject:ObjectOfInterest = ObjectOfInterest(e.target);
																						targetObject.showOutline();	
																						targetObject.prepareCaption();																						
																					});

			//listen for when the cursor stops hovering over the new object
			newObject.addEventListener(MouseEvent.MOUSE_OUT, function(e:MouseEvent):void
																					{	
																						var targetObject:ObjectOfInterest = ObjectOfInterest(e.target);
																						targetObject.hideOutline();	
																						targetObject.unprepareCaption();
																					});
			
			
			
			//listen for when the object of interest is clicked
			newObject.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void
																					{	
																						if(currentOOI)
																						{
																							if(ObjectOfInterest(e.target).getID() == currentOOI.getID())
																							{
																								pickNextOOI();
																								displayClue();
																							}
																							else
																								displayIncorrect();
																						}
																					});
			
		}
		
		public function resetUnusedOOIList():void
		{
			ooiUnused = new Array();
			for(var i:int = 0; i < objectsOfInterest.length; i++)
				ooiUnused.push(objectsOfInterest[i]);
		}
		
		public function pickNextOOI():void
		{
			//generate a number [0, 1)
			var randNum:Number = Math.random();
			if(randNum >= 1)
				randNum = 0;
			
			//determine index of next object of interest
			var index:int = int(randNum * ooiUnused.length);
			
			//address chosen object
			currentOOI = ooiUnused[index];
			
			//remove object from list of unused
			ooiUnused.splice(index, 1);
		}
		
		public function displayClue():void
		{
			if(currentOOI)
			{
				clueText.visible = true;
				clueText.text = currentOOI.getClue();
			}
			else
			{
				clueText.visible = true;
				clueText.text = "All done";
			}
			
			clueTimer.reset();
			clueTimer.start();
		}
		
		public function displayIncorrect():void
		{
			clueText.visible = true;
			clueText.text = wrongAnswer;
			
			clueTimer.reset();
			clueTimer.start();
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
		
		public function getPaintingMask():Shape		{	return paintingMask;	}
		public function getPaintingScale():Number	{	return paintingScale;	}
	}
}