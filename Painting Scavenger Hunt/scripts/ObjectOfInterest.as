package
{
	import flash.display.*;
	import flash.events.*;
	import flash.ui.*;	
	import flash.text.*;
	import flash.geom.Point;
	import flash.geom.Matrix;
	import flash.net.URLRequest;
	import flash.utils.Timer;
	
	public class ObjectOfInterest extends MovieClip
	{
		private var objectName:String = null;
		private var id:Number = 0;
		private var clue:String = null;
		private var hitmapFilename = null;
		private var outlineFilename = null;
		private var hitmap:Bitmap = null;
		private var outline:Bitmap = null;
		private var fullsizeOutline:Bitmap = null;
		private var scaleFactor:Number = 1;
		private var mousedOver:Boolean = false;
		private var unused:Boolean = true;
		private var captionTimer:Timer = null;
		private var caption:TextField = null;
		
		private static var staticID:Number = 0;
		private static var captionFormat:TextFormat = new TextFormat("Arial", 20, 0x40E0D0);
		
		public function ObjectOfInterest(objectName:String, clue:String, hitmapFilename:String, outlineFilename:String, x:Number, y:Number, scaleFactor:Number = 1)
		{
			//set name, and clue
			this.objectName = objectName;
			this.clue = clue;
			
			//set ID and increment static counter
			this.id = staticID;
			staticID++;
			
			//store locations of hitmap and outline image files
			this.hitmapFilename = hitmapFilename;
			this.outlineFilename = outlineFilename;
			
			//set coordinates
			this.x = x;
			this.y = y;
			
			//store scale to be used when loading bitmaps
			if(scaleFactor  <= 0)
				scaleFactor = 1;
			this.scaleFactor = scaleFactor;
			
			//create caption textfield to display name
			caption = new TextField();
			caption.defaultTextFormat = captionFormat;
			caption.text = objectName;
			
			//track the start of a new frame
			addEventListener(Event.ENTER_FRAME, enterFrame);
		}
		
		public function enterFrame(e:Event)
		{
			//ensure that the object has a display list parent before depending on it
			if(parent)
			{
				//if the mouse cursor is hovering above the object, dispatch a MOUSE_OVER
				if(hitTest(new Point(parent.mouseX, parent.mouseY)))
				{					
					//only dispatch the event if the object was not previously hovered over
					if(!mousedOver)
					{
						dispatchEvent(new MouseEvent(MouseEvent.MOUSE_OVER));
						mousedOver = true;
					}
					//otherwise, move caption to mouse position
					else
						captionAtMouse();
				}
				//otherwise, dispatch a MOUSE_OUT event
				else
				{
					//only dispatch the event if the object was not previously hovered over
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
			
			hitmapLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent):void
																										   {	
																										   	dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR));	
																											trace("Failed to load hitmap of " + objectName);
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
																								hideOutline();
																								if(hitmap && outline)
																									dispatchEvent(new Event(Event.COMPLETE)); 
																							  });
			
			outlineLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent):void
																											{	
																												dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR));	
																												trace("Failed to load outline of " + objectName);
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
			objectTexturePoint.x = (samplePoint.x - x) / outline.width;
			objectTexturePoint.y = (samplePoint.y - y) / outline.height;
			texturePointList.push(objectTexturePoint);
		}
		
		public function prepareCaption(displayDelay:Number = 1000)
		{
			captionTimer = new Timer(displayDelay, 1);
			captionTimer.addEventListener(TimerEvent.TIMER, function(e:TimerEvent):void
																				  {
																					//if the time exists, stop and discard, and add the caption to the display list
																					if(captionTimer)
																					{
																						captionTimer.stop();
																						captionTimer = null;
																					
																						//move caption to mouse position
																						captionAtMouse();
																						
																						//if a parent in the display list exists, add the caption as its child
																						if(parent)
																							parent.addChild(caption);
																					}
																				  });
			captionTimer.start();
		}
		
		public function unprepareCaption()
		{
			//stop caption time and discard it
			if(captionTimer)
			{
				captionTimer.stop();
				captionTimer = null;
			}
			
			//if the caption has been added to the display list, remove it
			if(caption.parent)
				caption.parent.removeChild(caption);
		}
		
		private function captionAtMouse()
		{
			caption.x = parent.mouseX + 10;
			caption.y = parent.mouseY;
		}
		
		public function showOutline():void				{	outline.visible = true;		}
		public function hideOutline():void				{	outline.visible = false;	}
		public function isOutlined():Boolean			{	return outline.visible;		}
		
		public function useClue():void					{	unused = false;		}
		public function unuseClue():void				{	unused = true;		}
		public function isClueUnused():Boolean			{	return unused;		}
		
		public function getObjectName():String			{	return objectName;		}
		public function getID():Number					{	return id;				}
		public function getClue():String				{	return clue;			}
		public function getHitmap():Bitmap				{	return hitmap;			}
		public function getOutline():Bitmap				{	return outline;			}
		public function getFullsizeOutline():Bitmap		{	return fullsizeOutline;	}
	}
}