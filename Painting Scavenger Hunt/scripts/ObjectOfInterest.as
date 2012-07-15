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
		private var objectName:String = null;					//name of object
		private var id:Number = 0;								//identification number of object
		private var clue:String = null;							//clue associated with object
		private var hitmapFilename = null;						//filename of hitmap
		private var outlineFilename = null;						//filename of outline
		private var hitmap:Bitmap = null;						//bitmap used for checking collisions and contact
		private var outline:Bitmap = null;						//bitmap used to highlight object
		private var fullsizeOutline:Bitmap = null;				//unscaled outline bitmap
		private var scaleFactor:Number = 1;						//scale factor applied to hitmap and outline to fit a given scene
		private var mousedOver:Boolean = false;					//flag if the object is currently under the cursor
		private var captionTimer:Timer = null;					//time used to trigger caption display
		private var caption:TextField = null;					//caption that displays name of object
		private var descriptionPane:OOIDescriptionPane = null;	//pane used to display object's description
		
		private static var staticID:Number = 0;													//counter of objects used to determine each objects ID
		private static var captionFormat:TextFormat = new TextFormat("Arial", 20, 0x40E0D0);	//text format used by caption
		
		//construct an object of interest with a name, clue, position, and scale factor, and store location of hitmap and outline
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
			
						
			//create description pane
			descriptionPane = new OOIDescriptionPane(1, 1, 250, 380);
			
			//track the start of a new frame
			addEventListener(Event.ENTER_FRAME, enterFrame);
		}
		
		//handle new frames
		private function enterFrame(e:Event)
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
		
		//load object's components
		public function loadComponents():void
		{
			loadHitmap();
			loadOutline();
		}
				
		//load the object's hitmap image
		private function loadHitmap():void
		{
			//create new loader
			var hitmapLoader:Loader = new Loader();
			
			//listen for the completion of the image loading
			hitmapLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event):void   
																							 {	
																							 	//store the final image data temporarily
																							 	var tempHitmap:Bitmap = Bitmap(LoaderInfo(e.target).content);	
																								
																								//create a new, scaled hitmap and draw the loaded hitmap into it 
																								hitmap = new Bitmap(new BitmapData(tempHitmap.bitmapData.width * scaleFactor, tempHitmap.bitmapData.height * scaleFactor, true, 0x00000000));
																								hitmap.bitmapData.draw(tempHitmap, new Matrix(scaleFactor, 0, 0, scaleFactor));
																								
																								//dispose of the temporary image data
																								tempHitmap.bitmapData.dispose();
																								
																								//if both the hitmap and outline are now loaded, dispatch a completion event
																								if(hitmap && outline)
																									dispatchEvent(new Event(Event.COMPLETE)); 
																							 });
			
			//listen for a IO error
			hitmapLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent):void
																										   {	
																										   	//dispatch and IO error message
																										   	dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR));	
																											
																											//display error in debug trace
																											trace("Failed to load hitmap of " + objectName);
																										   });
			
			//begin loading iamge
			hitmapLoader.load(new URLRequest(hitmapFilename));
		}
		
		//load the object's outline image
		private function loadOutline():void
		{
			//create new loader
			var outlineLoader:Loader = new Loader();
			
			//listen for the completion of the image loading
			outlineLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event):void	
																							  {	
																							  	//store image data as outline
																							  	outline = Bitmap(LoaderInfo(e.target).content);
																								
																								//scale the outline image (internal data is not affected)
																								outline.width *= scaleFactor;
																								outline.height *= scaleFactor;
																								
																								//store a fullsize outline for convenience
																								fullsizeOutline = new Bitmap(outline.bitmapData);
																								addChild(outline);
																								hideOutline();
																								
																								//if both the hitmap and outline are now loaded, dispatch a completion event
																								if(hitmap && outline)
																									dispatchEvent(new Event(Event.COMPLETE)); 
																							  });
			
			//listen for a IO error
			outlineLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent):void
																											{	
																												dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR));	
																												trace("Failed to load outline of " + objectName);
																											});
			
			//begin loading image
			outlineLoader.load(new URLRequest(outlineFilename));
		}
				
		//test hitmap against a given point, determine hit using a minimum alpha value		
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
		
		//add the object's outline to a list of bitmaps along with corresponding texture points based on a given sample point relative to the object's upper-left corner
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
		
		
		//prepare to display caption after a delay
		public function prepareCaption(displayDelay:Number = 1000)
		{
			//create new timer
			captionTimer = new Timer(displayDelay, 1);
			
			//listen for the completion of the time
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
			
			//start the timer
			captionTimer.start();
		}
		
		//stop preparing to display caption
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
		
		//place the caption at the mouse position in the display parent's space
		private function captionAtMouse()
		{
			caption.x = parent.mouseX + 10;
			caption.y = parent.mouseY;
		}
		
		//display description pane
		public function displayDescription()
		{
			if(parent)
			{	
				parent.addChild(descriptionPane);
				descriptionPane.addEventListener(OOIDescriptionPane.CLOSE_PANE, undisplayDescription);
			}
		}
		
		private function undisplayDescription(e:Event)
		{
			descriptionPane.removeEventListener(OOIDescriptionPane.CLOSE_PANE, undisplayDescription);
			descriptionPane.parent.removeChild(DisplayObject(e.target));	
		}
		
		//toggle outline visibilty
		public function showOutline():void				{	outline.visible = true;		}
		public function hideOutline():void				{	outline.visible = false;	}
		
		//retrieve outline visibility
		public function isOutlined():Boolean			{	return outline.visible;		}
		
		public function getObjectName():String						{	return objectName;		}
		public function getID():Number								{	return id;				}
		public function getClue():String							{	return clue;			}
		public function getHitmap():Bitmap							{	return hitmap;			}
		public function getOutline():Bitmap							{	return outline;			}
		public function getFullsizeOutline():Bitmap					{	return fullsizeOutline;	}
		public function getDescriptionPane():OOIDescriptionPane		{	return descriptionPane;	}
	}
}