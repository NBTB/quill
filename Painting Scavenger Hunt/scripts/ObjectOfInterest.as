﻿package
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
		private var objectName:String = null;							//name of object
		private var id:Number = 0;										//identification number of object
		private var clue:String = null;									//clue associated with object
		private var hitmapFilename = null;								//filename of hitmap
		private var highlightFilename = null;							//filename of highlight
		private var hitmap:Bitmap = null;								//bitmap used for checking collisions and contact
		private var highlight:Bitmap = null;							//bitmap used to highlight object
		private var fullsizeHighlight:Bitmap = null;					//unscaled highlight bitmap
		private var scaleFactor:Number = 1;								//scale factor applied to hitmap and highlight to fit a given scene
		private var lowerBounds:Point = null;							//low-end coordinates of boundary for dynamic components (null indicates no boundary)
		private var upperBounds:Point = null;							//upper-end coordinates of boundary for dynamic components (null indicates no boundary)
		private var mousedOver:Boolean = false;							//flag if the object is currently under the cursor
		private var caption:TextField = null;							//caption that displays name of object
		private var captionContainer:DisplayObjectContainer = null;		//display container of caption
		private var infoPane:OOIInfoPane = null;						//pane used to display object's description
		private var infoPaneContainer:DisplayObjectContainer = null;	//display container of info pane
		private var infoPanePosition:Point = null;						//coordinates of info pane
		private var infoLoader:OOIInfoImporter = null;					//loader of info pane content
		private var descriptionTimer:Timer = null;						//time used to trigger description display		
		private var hasBeenOpened:Boolean = false;						//turned true first time objects display pane is showed
		
		public static var anyMousedOver = false;												//flag if any object is moused over
		private static var staticID:Number = 0;													//counter of objects used to determine each objects ID
		private static var captionFormat:TextFormat = new TextFormat("Arial", 20, 0x40E0D0);	//text format used by caption
		
		//construct an object of interest with a name, clue, position, and scale factor, and store location of hitmap and highlight
		public function ObjectOfInterest(objectName:String, clue:String, hitmapFilename:String, highlightFilename:String, infoLoader:OOIInfoImporter, x:Number, y:Number, scaleFactor:Number = 1, lowerBounds:Point = null, upperBounds:Point = null)
		{			
			//set name, and clue
			this.objectName = objectName;
			this.clue = clue;
			
			//set ID and increment static counter
			this.id = staticID;
			staticID++;
			
			//store locations of hitmap and highlight image files
			this.hitmapFilename = hitmapFilename;
			this.highlightFilename = highlightFilename;
			
			//store info loader 
			this.infoLoader = infoLoader;
			
			//set coordinates
			this.x = x;
			this.y = y;
			
			//by default position the info pane at the origin
			infoPanePosition = new Point(0, 0);
			
			//store scale to be used when loading bitmaps
			if(scaleFactor  <= 0)
				scaleFactor = 1;
			this.scaleFactor = scaleFactor;
			
			//store bounds
			this.lowerBounds = lowerBounds;
			this.upperBounds = upperBounds;
			
			//store display containers (default to this object's parent)
			if(captionContainer)
				this.captionContainer = captionContainer;
			else
				this.captionContainer = this.parent;
			if(infoPaneContainer)
				this.infoPaneContainer = captionContainer;
			else
				this.infoPaneContainer = this.parent;
			
			//create caption textfield to display name
			caption = new TextField();
			caption.defaultTextFormat = captionFormat;
			caption.autoSize = TextFieldAutoSize.LEFT;
			caption.selectable = false;
			caption.text = objectName;
						
			//create info Pane
			infoPane = new OOIInfoPane(5, 5, 250, 380);
			
			//add title to object info Pane
			var titleText:TextField = new TextField();
			titleText.defaultTextFormat = OOIInfoPane.getTitleFormat();
			titleText.text = objectName;	
			titleText.width = 180;
			titleText.x = 5;
			titleText.y = 5;
			titleText.wordWrap = true;
			titleText.autoSize = TextFieldAutoSize.LEFT;
			titleText.selectable = false;
			titleText.mouseWheelEnabled = false;
			infoPane.addListChild(titleText);
			
			//listen for when info Pane closes
			infoPane.addEventListener(OOIInfoPane.CLOSE_PANE, function(e:Event):void	{	hideInfoPane();	});
			
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
					if(!mousedOver && !anyMousedOver)
					{
						dispatchEvent(new MouseEvent(MouseEvent.MOUSE_OVER));
						mousedOver = true;
						anyMousedOver = true;
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
						anyMousedOver = false;
					}
				}
			}
		}
		
		//load object's components
		public function loadComponents():void
		{
			loadHitmap();
			loadHighlight();
			if(infoLoader)
				infoLoader.loadInfoToOOI(this);
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
																								
																								//if both the hitmap and highlight are now loaded, dispatch a completion event
																								if(hitmap && highlight)
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
		
		//load the object's highlight image
		private function loadHighlight():void
		{
			//create new loader
			var highlightLoader:Loader = new Loader();
			
			//listen for the completion of the image loading
			highlightLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event):void	
																							  {	
																							  	//store image data as highlight
																							  	highlight = Bitmap(LoaderInfo(e.target).content);
																								
																								//scale the highlight image (internal data is not affected)
																								highlight.width *= scaleFactor;
																								highlight.height *= scaleFactor;
																								
																								//store a fullsize highlight for convenience
																								fullsizeHighlight = new Bitmap(highlight.bitmapData);
																								addChild(highlight);
																								hideHighlight();
																								
																								//if both the hitmap and highlight are now loaded, dispatch a completion event
																								if(hitmap && highlight)
																									dispatchEvent(new Event(Event.COMPLETE)); 
																							  });
			
			//listen for a IO error
			highlightLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent):void
																											{	
																												dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR));	
																												trace("Failed to load highlight of " + objectName);
																											});
			
			//begin loading image
			highlightLoader.load(new URLRequest(highlightFilename));
		}
			
		//add display object as a child of info pane
		public function addInfoToPane(newInfo:DisplayObject)
		{
			infoPane.addListChild(newInfo);
		}
		
		//add display object as the tail child of info pane
		public function addInfoToPaneTail(newInfo:DisplayObject)
		{
			infoPane.addListChildToTail(newInfo);
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
		
		//add the object's highlight to a list of bitmaps along with corresponding texture points based on a given sample point relative to the object's upper-left corner
		public function addHighlightToList(bitmapList:Array, texturePointList:Array, samplePoint:Point, useFullsize:Boolean = false)
		{
			//if flagged to use fullsize highlight, add it to the bitmap list
			if(useFullsize)
				bitmapList.push(fullsizeHighlight);
			//otherwise, add the scaled highlight
			else
				bitmapList.push(highlight);
			
			//add texture coordinates to the texture coordinate list
			var objectTexturePoint:Point = new Point();
			objectTexturePoint.x = (samplePoint.x - x) / highlight.width;
			objectTexturePoint.y = (samplePoint.y - y) / highlight.height;
			texturePointList.push(objectTexturePoint);
		}
		
		
		//display caption and prepare to display description after a delay
		public function prepareInfoPane(displayDelay:Number = -1)
		{			
			//if a negative time was given, assume that discription is not desired and do not start timer
			if(displayDelay < 0)
				return;
			
			//create new timer
			descriptionTimer = new Timer(displayDelay, 1);
			
			//listen for the completion of the time
			descriptionTimer.addEventListener(TimerEvent.TIMER, function(e:TimerEvent):void
																				  {
																					//if the time exists, stop and discard, and add the caption to the display list
																					if(descriptionTimer)
																					{
																						descriptionTimer.stop();
																						descriptionTimer = null;
																						
																						//display info Pane
																						showInfoPane();
																						
																					}
																				  });
			
			//start the timer
			descriptionTimer.start();
		}
		
		//stop preparing to display description and hide caption
		public function unprepareInfoPane()
		{
			//stop caption time and discard it
			if(descriptionTimer)
			{
				descriptionTimer.stop();
				descriptionTimer = null;
			}
		}
		
		//place the caption at the mouse position in the display parent's space
		private function captionAtMouse()
		{
			if(caption.parent)
			{
				//place caption near mouse
				caption.x = caption.parent.mouseX + 10;
				caption.y = caption.parent.mouseY;
				
				//if the caption exceeds bounds, clamp it
				var captionFarX = caption.x + caption.width;
				var captionFarY = caption.y + caption.height;
				if(caption.x < lowerBounds.x)
					caption.x = lowerBounds.x;
				if(caption.y < lowerBounds.y)
					caption.y = lowerBounds.y;
				if(captionFarX > upperBounds.x)
					caption.x -= captionFarX - upperBounds.x;
				if(captionFarY > upperBounds.y)
					caption.y -= captionFarY - upperBounds.y;
			}
		}
		
		//place the caption at the mouse position in the display parent's space
		private function infoPaneAtMouse()
		{
			if(infoPane.parent)
			{
				//place description near mouse
				infoPane.x = parent.mouseX - infoPane.width/2;
				infoPane.y = parent.mouseY+1;
				
				//if the cainfo Pane exceeds bounds, clamp it
				var infoPaneFarX = infoPane.x + infoPane.width;
				var infoPaneFarY = infoPane.y + infoPane.height;
				if(infoPane.x < lowerBounds.x)
					infoPane.x = lowerBounds.x;
				if(infoPane.y < lowerBounds.y)
					infoPane.y = lowerBounds.y;
				if(infoPaneFarX > upperBounds.x)
					infoPane.x -= infoPaneFarX - upperBounds.x;
				if(infoPaneFarY > upperBounds.y)
					infoPane.y -= infoPaneFarY - upperBounds.y;
			}
		}
		
		//display caption
		public function showCaption()
		{
			if(captionContainer)
			{	
				captionContainer.addChild(caption);
				captionAtMouse();
			}
		}
		
		//hide caption
		public function hideCaption()
		{
			if(caption.parent)
			{
				caption.parent.removeChild(caption);
			}
		}		
		
		//display info Pane
		public function showInfoPane()
		{
			if(infoPaneContainer)
			{	
				infoPaneContainer.addChild(infoPane);
				dispatchEvent(new Event(OOIInfoPane.OPEN_PANE));
			}
		}
		
		//event listener version of showInfoPane
		public function displayInfoPane(e:MouseEvent)
		{
			showInfoPane();
		}
		
		
		//hide descrition pane
		public function hideInfoPane()
		{
			if(infoPane.parent)
			{
				infoPane.parent.removeChild(infoPane);
				dispatchEvent(new Event(OOIInfoPane.CLOSE_PANE));
			}
		}
		
		//toggle highlight visibilty
		public function showHighlight():void				{	highlight.visible = true;		}
		public function hideHighlight():void				{	highlight.visible = false;		}
		
		//object is opened
		public function hasOpened():void					{	hasBeenOpened = true;			}
		
		//retrieve highlight visibility
		public function isHighlightd():Boolean				{	return highlight.visible;		}
		
		public function getObjectName():String							{	return objectName;				}
		public function getID():Number									{	return id;						}
		public function getClue():String								{	return clue;					}
		public function getHitmap():Bitmap								{	return hitmap;					}
		public function getHighlight():Bitmap							{	return highlight;				}
		public function getFullsizeHighlight():Bitmap					{	return fullsizeHighlight;		}
		public function getInfoPane():OOIInfoPane						{	return infoPane;				}
		public function getCaptionContainer():DisplayObjectContainer	{	return captionContainer;		}
		public function getInfoPaneContainer():DisplayObjectContainer	{	return infoPaneContainer;		}
		public function getInfoPanePosition():Point						{	return infoPanePosition;		}
		public function getHasBeenOpened():Boolean						{	return hasBeenOpened;			}
			
		public function setCaptionContainer(container:DisplayObjectContainer):void		{	this.captionContainer = container;		}
		public function setDescriptionContainer(container:DisplayObjectContainer):void	{	this.infoPaneContainer = container;		}
		public function setInfoPanePosition(coordinates:Point):void						
		{	
			this.infoPane.x = coordinates.x;	
			this.infoPane.y = coordinates.y;	
		}
	}
}