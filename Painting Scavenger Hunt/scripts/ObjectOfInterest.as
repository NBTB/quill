﻿package scripts
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
		private var infoSnippet:String = null;							//short object description
		private var clue:String = null;									//clue associated with object
		private var hitmapFilename = null;								//filename of hitmap
		private var highlightFilename = null;							//filename of highlight
		private var solvedImageFilename = null;							//filename of image to be used when object is found
		private var hitmap:Bitmap = null;								//bitmap used for checking collisions and contact
		private var highlight:Bitmap = null;							//bitmap used to highlight object
		private var fullsizeHighlight:Bitmap = null;					//unscaled highlight bitmap
		private var solvedImage:Bitmap = null;							//bitmap used to when object is found 
		private var fullsizeSolvedImage:Bitmap = null;					//unscaled found image bitmap
		private var scaleFactor:Number = 1;								//scale factor applied to hitmap and highlight to fit a given scene
		private var lowerBounds:Point = null;							//low-end coordinates of boundary for dynamic components (null indicates no boundary)
		private var upperBounds:Point = null;							//upper-end coordinates of boundary for dynamic components (null indicates no boundary)
		private var mousedOver:Boolean = false;							//flag if the object is currently under the cursor
		private var caption:OOICaption = null;							//caption that displays name and basic info of object
		private var infoPane:OOIInfoPane = null;						//pane used to display object's description
		private var infoPanePosition:Point = null;						//coordinates of info pane
		private var infoLoader:OOIInfoImporter = null;					//loader of info pane content	
		private var hasBeenOpened:Boolean = false;						//turned true first time objects display pane is showed
		private var hitTestSuppression:Boolean = false;					//flag if hit testing should be supressed
		
		public static var defaultInfoRect = null;												//default info pane position and size
		public static var anyMousedOver = false;												//flag if any object is moused over
		private static var staticID:Number = 0;													//counter of objects used to determine each objects ID
		private static var captionFormat:TextFormat = new TextFormat("Arial", 20, 0x40E0D0);	//text format used by caption
		
		var myArrayListeners:Array=[];								//Array of Event Listeners in BaseMenu
		
		//event typps
		public static const OOI_MOUSE_OVER:String = "OOI mouse over";
		public static const OOI_MOUSE_OUT:String = "OOI mouse out";
		
		//construct an object of interest with a name, clue, position, and scale factor, and store location of hitmap and highlight
		public function ObjectOfInterest(objectName:String, infoSnippet:String, clue:String, hitmapFilename:String, highlightFilename:String, solvedImageFilename:String, infoLoader:OOIInfoImporter, x:Number, y:Number, scaleFactor:Number = 1, lowerBounds:Point = null, upperBounds:Point = null)
		{			
			//set name, info snippet, and clue
			this.objectName = objectName;
			this.infoSnippet = infoSnippet;
			this.clue = clue;
			
			//set ID and increment static counter
			this.id = staticID;
			staticID++;
			
			//store locations of image files
			this.hitmapFilename = hitmapFilename;
			this.highlightFilename = highlightFilename;
			this.solvedImageFilename = solvedImageFilename;
			
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
						
			//create caption
			caption = new OOICaption(objectName, infoSnippet);
			caption.visible = false;
			caption.mouseEnabled = false;
			caption.mouseChildren = false;
						
			//create info pane
			if(defaultInfoRect)
				infoPane = new OOIInfoPane(defaultInfoRect.x, defaultInfoRect.y, defaultInfoRect.width, defaultInfoRect.height);
			else
				infoPane = new OOIInfoPane(5, 5, 320, 400);
			infoPane.visible = false;
			infoPane.mouseEnabled = true;
			infoPane.mouseChildren = true;
			infoPane.addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent):void{});
			
			//add this as an opener of info pane
			infoPane.addOpener(this);
			
			//add this as an opener of info pane
			infoPane.addOpener(this);
			
			//add title to object info Pane
			var titleText:TextField = new TextField();
			titleText.defaultTextFormat = BaseMenu.altTitleFormat;
			titleText.text = objectName;	
			titleText.width = 280;
			titleText.x = 5;
			titleText.y = 5;
			titleText.wordWrap = true;
			titleText.autoSize = TextFieldAutoSize.LEFT;
			titleText.selectable = false;
			titleText.mouseWheelEnabled = false;
			titleText.embedFonts = true;
			infoPane.addContent(titleText);
			
			//initially disable mouse interaction
			mouseEnabled = false;
			mouseChildren = false;
						
			//track the start of a new frame
			addEventListener(Event.ENTER_FRAME, enterFrame);
			
			//listen for closing of info pane
			infoPane.addEventListener(MenuEvent.MENU_CLOSED, function(e:Event):void	{	hideHighlight();	});
			
			//listen for being removed from the display list
			addEventListener(Event.REMOVED_FROM_STAGE, function(e:Event):void
																		{
																			//dispose of bitmaps
																			if(hitmap)
																			{
																				hitmap.bitmapData.dispose();
																				hitmap = null;
																			}
																			if(highlight)
																			{
																				highlight.bitmapData.dispose();
																				highlight = null;
																			}
																			if(hitmap)
																			{
																				solvedImage.bitmapData.dispose();
																				solvedImage = null;
																			}
																		});
		}
		
		//handle new frames
		private function enterFrame(e:Event)
		{
			//ensure that the object has a display list parent before depending on it
			if(parent)
			{
				//if hit testing is not suppressed the mouse cursor is hovering above the object, dispatch an OOI_MOUSE_OVER
				if(!hitTestSuppression && hitTest(new Point(parent.mouseX, parent.mouseY)))
				{					
					//only dispatch the event if the object was not previously hovered over
					if(!mousedOver && !anyMousedOver)
					{
						dispatchEvent(new Event(OOI_MOUSE_OVER));
						mousedOver = true;
						anyMousedOver = true;
					}
					//otherwise, move caption to mouse position
					else
						captionAtMouse();
				}
				//otherwise, dispatch a OOI_MOUSE_OUT event
				else
				{
					//only dispatch the event if the object was previously hovered over
					if(mousedOver)
					{
						dispatchEvent(new Event(OOI_MOUSE_OUT));
						mousedOver = false;
						anyMousedOver = false;
					}
				}
			}
			
			//keep the object's highlight visible as long as its info pane is open
			if(infoPane.isMenuOpen())
				highlight.visible = true;
		}
		
		//load object's components
		public function loadComponents():void
		{
			loadHitmap();
			loadHighlight();
			loadSolvedImage();
			loadInfo();
		}
		
		//determine if all components have been loaded
		private function componentsLoaded():Boolean
		{
			return hitmap && highlight && solvedImage && (!infoLoader || infoLoader.isDone());
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
																								if(componentsLoaded())
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
																								
																								//add highlight to display list but hide it for now
																								addChild(highlight);
																								hideHighlight();
																								
																								//if both the hitmap and highlight are now loaded, dispatch a completion event
																								if(componentsLoaded())
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
		
		//load the object's found image
		private function loadSolvedImage():void
		{
			//create new loader
			var solvedImageLoader:Loader = new Loader();
			
			//listen for the completion of the image loading
			solvedImageLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event):void	
																								 {
																									 //store image data as found image
																									solvedImage = Bitmap(LoaderInfo(e.target).content);
																									
																									//scale the found image (internal data is not affected)
																									solvedImage.width *= scaleFactor;
																									solvedImage.height *= scaleFactor;
																									
																									//store a fullsize found image for convenience
																									fullsizeSolvedImage = new Bitmap(solvedImage.bitmapData);
																									
																									//add found image to display list (as bottom child) but hide it for now
																									addChildAt(solvedImage, 0);
																									hideSolvedImage();
																									
																									//if both the hitmap and highlight are now loaded, dispatch a completion event
																									if(componentsLoaded())
																										dispatchEvent(new Event(Event.COMPLETE));
																								 });
																								 
			//listen for a IO error
			solvedImageLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent):void
																											{	
																												dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR));	
																												trace("Failed to load solved image of " + objectName);
																											});
			
			//begin loading image
			solvedImageLoader.load(new URLRequest(solvedImageFilename));
		}
		
		//load objects info to be displayed in the info pane
		private function loadInfo():void
		{
			if(infoLoader)
			{
				infoLoader.addEventListener(Event.COMPLETE, function(e:Event):void
																			{
																				//if all components have been loaded, dispatch a completion event
																			if(componentsLoaded())
																				dispatchEvent(new Event(Event.COMPLETE)); 
																			});
				infoLoader.loadInfoToOOI(this);
			}
		}
			
		//add display object as a child of info pane
		public function addInfoToPane(newInfo:DisplayObject)
		{
			infoPane.addContent(newInfo);
		}
		
		//add display object as the tail child of info pane
		public function addInfoToPaneTail(newInfo:DisplayObject)
		{
			infoPane.addContentToTail(newInfo);
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
		
		//add the object's found image to a list of bitmaps along with corresponding texture points based on a given sample point relative to the object's upper-left corner
		public function addSolvedImageToList(bitmapList:Array, texturePointList:Array, samplePoint:Point, useFullsize:Boolean = false)
		{
			//if flagged to use fullsize highlight, add it to the bitmap list
			if(useFullsize)
				bitmapList.push(fullsizeSolvedImage);
			//otherwise, add the scaled highlight
			else
				bitmapList.push(solvedImage);
			
			//add texture coordinates to the texture coordinate list
			var objectTexturePoint:Point = new Point();
			objectTexturePoint.x = (samplePoint.x - x) / highlight.width;
			objectTexturePoint.y = (samplePoint.y - y) / highlight.height;
			texturePointList.push(objectTexturePoint);
		}
		
		//place the caption at the mouse position in the display parent's space
		private function captionAtMouse()
		{
			if(caption.parent)
			{
				//place caption near mouse
				caption.x = caption.parent.mouseX + 10;
				caption.y = caption.parent.mouseY - caption.height / 2;
				
				//if the caption exceeds bounds, clamp it
				var captionFarX = caption.x + caption.width;
				var captionFarY = caption.y + caption.height;
				if(caption.x < lowerBounds.x)
					caption.x = lowerBounds.x;
				if(caption.y < lowerBounds.y)
					caption.y = lowerBounds.y;
				if(captionFarX > upperBounds.x)
					caption.x = caption.parent.mouseX - caption.width - 10;
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
			(parent as MovieClip).buttonMode = true;
			caption.visible = true;
			captionAtMouse();
		}
		
		//hide caption
		public function hideCaption()
		{
			(parent as MovieClip).buttonMode = true;
			caption.visible = false;
		}		
		
		//display info Pane
		public function showInfoPane()
		{
			infoPane.openMenu();
		}
				
		//hide descrition pane
		public function hideInfoPane()
		{
			infoPane.closeMenu();
		}
		
		//control highlight visibilty
		public function showHighlight():void	
		{	
			highlight.visible = true;		
			mouseEnabled = true;
			mouseChildren = true;
		}		
		public function hideHighlight():void	
		{	
			highlight.visible = false;		
			mouseEnabled = false;
			mouseChildren = false;
		}
		
		//control found image visibilty
		public function showSolvedImage():void	{	solvedImage.visible = true;		}		
		public function hideSolvedImage():void	{	solvedImage.visible = false;		}
		
		//object is opened
		public function hasOpened():void					{	hasBeenOpened = true;			}
		
		//retrieve highlight visibility
		public function isHighlighted():Boolean				{	return highlight.visible;		}
		
		//retrieve found image visibility
		public function isFound():Boolean					{	return solvedImage.visible;		}
		
		public function getObjectName():String							{	return objectName;				}
		public function getID():Number									{	return id;						}
		public function getInfoSnippet():String							{	return infoSnippet;				}
		public function getClue():String								{	return clue;					}
		public function getHitmap():Bitmap								{	return hitmap;					}
		public function getHighlight():Bitmap							{	return highlight;				}
		public function getFullsizeHighlight():Bitmap					{	return fullsizeHighlight;		}
		public function getSolvedImage():Bitmap							{	return solvedImage;				}
		public function getFullsizeSolvedImage():Bitmap					{	return fullsizeSolvedImage;		}
		public function getInfoPane():OOIInfoPane						{	return infoPane;				}
		public function getInfoPanePosition():Point						{	return infoPanePosition;		}
		public function getHasBeenOpened():Boolean						{	return hasBeenOpened;			}
		public function getHitTestSuppression():Boolean					{	return hitTestSuppression;		}
			
		public function setCaptionContainer(container:DisplayObjectContainer, childIndex:int = -1):void		
		{	
			//if caption already has a parent, remove it as a child
			if(caption.parent)
				caption.parent.removeChild(caption);
		
			//if the child index is negative, add as a the top child
			if(childIndex < 0)
				container.addChild(caption)
			//otherwise, add at the child index
			else
				container.addChildAt(caption, childIndex)
		}
		public function setInfoPaneContainer(container:DisplayObjectContainer, childIndex:int = -1):void	
		{	
			//if info pane already has a parent, remove it as a child
			if(infoPane.parent)
				infoPane.parent.removeChild(infoPane);
		
			//if the child index is negative, add as a the top child
			if(childIndex < 0)
				container.addChild(infoPane)
			//otherwise, add at the child index
			else
				container.addChildAt(infoPane, childIndex)
		}
		public function setInfoPanePosition(coordinates:Point, childIndex:int = -1):void						
		{	
			infoPane.x = coordinates.x;	
			infoPane.y = coordinates.y;	
			infoPane.changeOrigin(coordinates.x, coordinates.y)
		}
		
		public function setHitTestSuppression(suppression:Boolean):void	{	this.hitTestSuppression = suppression	}
	}
}