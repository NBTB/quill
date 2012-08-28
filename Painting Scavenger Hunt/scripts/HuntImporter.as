package scripts
{
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;	
    import flash.xml.*;
	import flash.geom.*;
    import flash.net.URLLoader;
    import flash.net.URLRequest;
     
    public class HuntImporter extends EventDispatcher
    {     
		private var menuImportFile:String = null	
		private var aboutImportFile:String = null
		private var huntImportFile:String = null
		private var paintingImportFile:String = null
		private var ooiImportFile:String = null
		private var endGoalImportFile:String = null
	
	
		var myArrayListeners:Array=[];					//Array of Event Listeners in BaseMenu
	
        //event types
		public static const SPECS_AND_DIRECTORIES_FOUND:String = "Specification files found";
		public static const START_UP_LOADED:String = "Start-up loaded";
		public static const HUNT_LOADED:String = "Hunt loaded";
        public static const PAINTING_LOADED:String = "Painting loaded";
        public static const OBJECTS_LOADED:String = "Objects loaded";
        public static const END_GOAL_LOADED:String = "End goal loaded";
		
		//find specification files for importation with the XML of the given file
		public function findSpecFilesAndAssetDirectories(specListFilename:String)
		{
			var xmlLoader:URLLoader = new URLLoader();
			xmlLoader.addEventListener(Event.COMPLETE, function(e:Event):void
																		{
																			//convert text to xml
																			var specList = new XML(e.target.data);
																			
																			//attempt to find spec files
																			if(specList.hasOwnProperty("menu"))
																				menuImportFile = specList.menu;
																			if(specList.hasOwnProperty("about"))
																				aboutImportFile = specList.about;
																			if(specList.hasOwnProperty("hunt"))
																				huntImportFile = specList.hunt;
																			if(specList.hasOwnProperty("painting"))
																				paintingImportFile = specList.painting;
																			if(specList.hasOwnProperty("objects_of_interest"))
																				ooiImportFile = specList.objects_of_interest;
																			if(specList.hasOwnProperty("end_goal"))
																				endGoalImportFile = specList.end_goal;
																				
																			//attempt to find asset directories
																			FileFinder.init();
																			if(specList.hasOwnProperty("Asset_Directories"))
																			{
																				var directoryList:XMLList = specList.Asset_Directories;
																				if(directoryList.hasOwnProperty("game_interface"))
																					FileFinder.setDirectory(FileFinder.INTERFACE, directoryList.game_interface);
																				if(directoryList.hasOwnProperty("game_info"))
																					FileFinder.setDirectory(FileFinder.GAME_INFO, directoryList.game_info);
																				if(directoryList.hasOwnProperty("object_of_interest_images"))
																					FileFinder.setDirectory(FileFinder.OOI_IMAGES, directoryList.object_of_interest_images);
																				if(directoryList.hasOwnProperty("object_of_interest_info"))
																					FileFinder.setDirectory(FileFinder.OOI_INFO, directoryList.object_of_interest_info);
																				if(directoryList.hasOwnProperty("end_goal_images"))
																					FileFinder.setDirectory(FileFinder.END_GOAL_IMAGES, directoryList.end_goal_images);	
																			}
																														   
																																							
																			//dispatch success
																			dispatchEvent(new Event(SPECS_AND_DIRECTORIES_FOUND));
																		});
			xmlLoader.addEventListener(IOErrorEvent.IO_ERROR, function(e:Event):void
																			   {
																				   trace("Failed to load specification list.");
																			   });
			xmlLoader.load(new URLRequest(specListFilename));
		}
		
         
		//load XML start up specification
		public function importStartUp()//startUpScreen:SplashScreen)
		{
			//track load status of menu parameters and info about game
			var menuParamsLoaded:Boolean = false;
			var aboutLoaded:Boolean = false;
			
			//load menu parameters
			var menuXMLLoader:URLLoader = new URLLoader();
            menuXMLLoader.addEventListener(Event.COMPLETE, function(e:Event):void
																			{
																				parseMenu(new XML(e.target.data));																				
																				menuParamsLoaded = true;
																				if(menuParamsLoaded && aboutLoaded)
																					dispatchEvent(new Event(START_UP_LOADED));
																			});
			menuXMLLoader.addEventListener(IOErrorEvent.IO_ERROR, function(e:Event):void
																				   {
																					   trace("Failed to load menu parameters.");
																					   menuParamsLoaded = true;
																						if(menuParamsLoaded && aboutLoaded)
																							dispatchEvent(new Event(START_UP_LOADED));
																				   });
            menuXMLLoader.load(new URLRequest(menuImportFile));
			
			//load info about game
			var aboutXMLLoader:URLLoader = new URLLoader();
            aboutXMLLoader.addEventListener(Event.COMPLETE, function(e:Event):void
																			 {
																				parseAbout(new XML(e.target.data));
																				aboutLoaded = true;
																				if(menuParamsLoaded && aboutLoaded)
																					dispatchEvent(new Event(START_UP_LOADED));
																			 });
			aboutXMLLoader.addEventListener(IOErrorEvent.IO_ERROR, function(e:Event):void
																				    {
																					  	trace("Failed to load info about game.");
																					  	aboutLoaded = true;
																						if(menuParamsLoaded && aboutLoaded)
																							dispatchEvent(new Event(START_UP_LOADED));
																				    });
            aboutXMLLoader.load(new URLRequest(aboutImportFile));
		}
		
		
        //load XML scavenger hunt specification
        public function importHunt(paintingCanvas:PaintingCanvas, ooiManager:OOIManager, magnifyingGlass:MagnifyingGlass, endGoalMenu:EndGoalMenu):void
        {			
			//track load status of hunt parameters and painting
			var huntLoaded:Boolean = false;
			var paintingLoaded:Boolean = false;
			
			//load hunt
            var huntXMLLoader:URLLoader = new URLLoader();			
            huntXMLLoader.addEventListener(Event.COMPLETE, function(e:Event):void
																			{																				
																				addEventListener(HUNT_LOADED, function(e:Event):void
																															   {
																																	huntLoaded = true;
																																	if(huntLoaded && paintingLoaded)
																																		prepareToParseAssets(paintingCanvas, ooiManager, endGoalMenu);
																															   });
																				parseHunt(new XML(e.target.data), ooiManager, magnifyingGlass);
																																	
																			});
			huntXMLLoader.addEventListener(IOErrorEvent.IO_ERROR, function(e:Event):void
																				   {
																					   	trace("Failed to load hunt parameters.");
																					  	huntLoaded = true;
																						if(huntLoaded && paintingLoaded)
																							prepareToParseAssets(paintingCanvas, ooiManager, endGoalMenu);
																				   });
			huntXMLLoader.load(new URLRequest(huntImportFile));
			
			//load painting
            var paintingXMLLoader:URLLoader = new URLLoader();			
            paintingXMLLoader.addEventListener(Event.COMPLETE, function(e:Event):void
																				{	
																					addEventListener(PAINTING_LOADED, function(e:Event):void
																																	   {
																																		   	paintingLoaded = true;
																																			if(huntLoaded && paintingLoaded)
																																				prepareToParseAssets(paintingCanvas, ooiManager, endGoalMenu);
																																	   });
																					parsePainting(new XML(e.target.data), paintingCanvas, magnifyingGlass);  
																				});
			paintingXMLLoader.addEventListener(IOErrorEvent.IO_ERROR, function(e:Event):void
																					   {
																						  	trace("Failed to load painting.");
																							paintingLoaded = true;
																							if(huntLoaded && paintingLoaded)
																								prepareToParseAssets(paintingCanvas, ooiManager, endGoalMenu);
																					   });
			paintingXMLLoader.load(new URLRequest(paintingImportFile));
        }
		
		//parse XML specification of menu parameters
		private function parseMenu(menuParams:XML)
		{
			//attempt to retrieve standard menu parameters
			if(menuParams.hasOwnProperty("menu_color"))
				BaseMenu.menuColor = Number(menuParams.menu_color);
			if(menuParams.hasOwnProperty("menu_border"))
				BaseMenu.menuBorderColor = Number(menuParams.menu_border);
			if(menuParams.hasOwnProperty("menu_opacity"))
				BaseMenu.menuOpacity = Number(menuParams.menu_opacity);
			
			//attempt to create text formats
			if(menuParams.hasOwnProperty("text_format"))
			{
				var formats:XMLList = menuParams.text_format;
				for each(var formatParams in formats)
				{
					var attribs = formatParams.attributes();
					for each(var attrib in attribs)
					{
						if(attrib.name() == "name")
						{
							//parse format
							var formatName = attrib;
							var textFormats:XMLList = menuParams.text_format;
							var newFormat:TextFormat = new TextFormat();
							if(formatParams.hasOwnProperty("font"))
								newFormat.font = formatParams.font;
							if(formatParams.hasOwnProperty("size"))
								newFormat.size = Number(formatParams.size);
							if(formatParams.hasOwnProperty("color"))
								newFormat.color = Number(formatParams.color);
							if(formatParams.hasOwnProperty("align"))
							{
								if(formatParams.align == "left")
									newFormat.align = TextFormatAlign.LEFT;
								else if(formatParams.align == "right")
									newFormat.align = TextFormatAlign.RIGHT;
								else if(formatParams.align == "center")
									newFormat.align = TextFormatAlign.CENTER;
								else if(formatParams.align == "justify")
									newFormat.align = TextFormatAlign.JUSTIFY;
							}
							if(formatParams.hasOwnProperty("bold"))
								newFormat.bold = true;
							if(formatParams.hasOwnProperty("italic"))
								newFormat.italic = true;
							if(formatParams.hasOwnProperty("underline"))
								newFormat.underline = true;
							
							//store format
							if(formatName == "title")
								BaseMenu.titleFormat = newFormat;
							else if(formatName == "body")
								BaseMenu.bodyFormat = newFormat;
							else if(formatName == "caption")
								BaseMenu.captionFormat = newFormat;
							else if(formatName == "text_button")
								BaseMenu.textButtonFormat = newFormat;
							else if(formatName == "link_usable")
								BaseMenu.linkUsableFormat = newFormat;
							else if(formatName == "link_unusable")
								BaseMenu.linkUnusableFormat = newFormat;
							else if(formatName == "link_accentuated")
								BaseMenu.linkAccentuatedFormat = newFormat;
						}
					}
				}
			}
		}
         
		//parse XML specification of info about game
		private function parseAbout(about:XML)
		{			
			if(about.hasOwnProperty("Splash_Screen"))
				parseSplashScreen(about.Splash_Screen[0]);
		}
		 
        //parse XML specification of scavenger hunt parameters
        private function parseHunt(hunt:XML, ooiManager:OOIManager, magnifyingGlass:MagnifyingGlass):void
        {              
            //parse hunt attributes
            var mgZoom:Number = 1;
            var mgRadius:Number = 100;
            var huntCount:int = -1;
            var huntAttribs:XMLList = hunt.attributes();
            for each(var attrib in huntAttribs)
            {
                if(attrib.name() == "magnify_scale")
                    mgZoom = Number(attrib);
                if(attrib.name() == "magnify_radius")
                    mgRadius = Number(attrib);
                if(attrib.name() == "hunt_count")
                    huntCount = int(Number(attrib));
            }
			
            //set magnifying glass defaults
            magnifyingGlass.setDefaultZoom(mgZoom);
            magnifyingGlass.setDefaultRadius(mgRadius);
             
            //set number of number of usable objects of interest
            ooiManager.setUsableOOICount(huntCount);      			
			
			//dispatch hunt loaded event
			dispatchEvent(new Event(HUNT_LOADED));
        }
		
		//parse XML specification of splash screen

		private function parseSplashScreen(splashScreenInfo:XML)
		{
			
			var creditsLoader:TextLoader = new TextLoader();
						
			if(splashScreenInfo.hasOwnProperty("credits_text_file"))
			{
				
				creditsLoader.importText(FileFinder.completePath(FileFinder.GAME_INFO, splashScreenInfo.credits_text_file));
			}
			
			var aboutLoader:TextLoader = new TextLoader();
			
			if(splashScreenInfo.hasOwnProperty("about_text_file"))
			{
			   aboutLoader.importText(FileFinder.completePath(FileFinder.GAME_INFO, splashScreenInfo.about_text_file));
			
			}
			
			
			
			if(splashScreenInfo.hasOwnProperty("tutorial_text_file"))
			{
				   
			}
			
			creditsLoader.addEventListener(TextLoaderEvent.TEXT_FILE_IMPORTED, function(e:Event):void
																							   {
																									//parse text file
																									var newText:String = creditsLoader.parseText();
																									
																									//if text was found, add a textfield to the object's info pane
																									if(newText)
																									{
																										if(splashScreenInfo.credits_text_file)
																										{
																											InstructionsMenu.credits = newText;
																										}
																									}
																							   });
			aboutLoader.addEventListener(TextLoaderEvent.TEXT_FILE_IMPORTED, function(e:Event):void
																							  {																								
																								//parse text file
																								var newText:String = aboutLoader.parseText();
																								
																								//if text was found, add a textfield to the object's info pane
																								if(newText)
																								{
																									if(splashScreenInfo.about_text_file)
																									{
																										InstructionsMenu.about = newText;
																									}
																								}
																							  });
		
		}
         
        //parse XML specification of painting to be applied to canvas
        private function parsePainting(painting:XML, paintingCanvas:PaintingCanvas, magnifyingGlass:MagnifyingGlass)
        {
			//track the load status of interactive and non-interactive paintings
			var interactiveLoaded:Boolean = false;
			var nonInteractiveLoaded:Boolean = false;
			
            //load interactive painting
            var ibitmapLoader:Loader = new Loader();
            ibitmapLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event):void
                                                                                              {                 
																							  	//attach painting to canvas
																								paintingCanvas.attachPainting(Bitmap(LoaderInfo(e.target).content));
																							  
                                                                                               	//display painting on canvas
                                                                                                paintingCanvas.displayPainting();
                                                                                                 
                                                                                                //if both versions of the painting are loaded, dispatch event for painting importation completion
																								interactiveLoaded = true
																								if(interactiveLoaded && nonInteractiveLoaded)
                                                                                                	dispatchEvent(new Event(PAINTING_LOADED));
                                                                                              });
			ibitmapLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent):void
																										    {	
																										   		//dispatch and IO error message
																										   		dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR));	
																											
																												//display error in debug trace
																												trace("Failed to load painting (interactive)");
																										    });
            ibitmapLoader.load(new URLRequest(FileFinder.completePath(FileFinder.INTERFACE, painting.interactive_filename)));
			
			//load non-interactive painting
            var nbitmapLoader:Loader = new Loader();
            nbitmapLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event):void
                                                                                              {     
																							  	//attach non-interacive painting to canvas
																								paintingCanvas.attachNonInteractivePainting(Bitmap(LoaderInfo(e.target).content));
																							  
                                                                                                //if both versions of the painting are loaded, dispatch event for painting importation completion
																								nonInteractiveLoaded = true
																								if(interactiveLoaded && nonInteractiveLoaded)
                                                                                                	dispatchEvent(new Event(PAINTING_LOADED));
                                                                                              });
			nbitmapLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent):void
																										    {	
																										   		//dispatch and IO error message
																										   		dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR));	
																											
																												//display error in debug trace
																												trace("Failed to load painting (non-interactive)");
																										    });
            nbitmapLoader.load(new URLRequest(FileFinder.completePath(FileFinder.INTERFACE, painting.non_interactive_filename)));
        }
		
		//prepare to parse objects of interest and end goal pieces
		private function prepareToParseAssets(paintingCanvas:PaintingCanvas, ooiManager:OOIManager, endGoalMenu:EndGoalMenu)
		{
			//flags of completion
			var objectsLoaded:Boolean = false;
			var endGoalLoaded:Boolean = false;
			
			//listen for all of the objects to be fully loaded
			addEventListener(OBJECTS_LOADED, function(e:Event):void
														  {
																objectsLoaded = true;
																if(objectsLoaded && endGoalLoaded)
																dispatchEvent(new Event(Event.COMPLETE));
														  });
			
			//load and parse objects of interest to be used in hunt
			var ooiXMLLoader:URLLoader = new URLLoader();
			ooiXMLLoader.addEventListener(Event.COMPLETE, function(e:Event):void
																	   {
																			var ooiXML:XML = new XML(e.target.data);
																			if(ooiXML.hasOwnProperty("Object_Of_Interest"))
																				parseObjectsOfInterest(ooiXML.children(), ooiManager, paintingCanvas.getPaintingScale(), new Rectangle(paintingCanvas.x, paintingCanvas.y, paintingCanvas.getPaintingWidth(), paintingCanvas.getPaintingHeight())); 
																			else
																				dispatchEvent(new Event(OBJECTS_LOADED));
																	   });
			ooiXMLLoader.addEventListener(IOErrorEvent.IO_ERROR, function(e:Event):void
																			  {
																				  trace("Failed to load objects of interest specification file.");
																			  });
			ooiXMLLoader.load(new URLRequest(ooiImportFile));
			
			
			//listen for all of the end goal pieces to be fully loaded
			addEventListener(END_GOAL_LOADED, function(e:Event):void
														  {
															endGoalLoaded = true;
															if(objectsLoaded && endGoalLoaded)
																dispatchEvent(new Event(Event.COMPLETE));
														  });
			
			//load and end goal pieces to be used in hunt
			var endGoalXMLLoader:URLLoader = new URLLoader();
			endGoalXMLLoader.addEventListener(Event.COMPLETE, function(e:Event):void
																		   {
																				var endGoalXML:XML = new XML(e.target.data);
																				if(endGoalXML.hasOwnProperty("End_Goal_Piece"))
																					parseEndGoalPieces(endGoalXML.children(), endGoalMenu);  
																				else
																					dispatchEvent(new Event(END_GOAL_LOADED));
																				
																		   });
			endGoalXMLLoader.addEventListener(IOErrorEvent.IO_ERROR, function(e:Event):void
																				  {
																					  trace("Failed to load end goal specification file.");
																				  });
			endGoalXMLLoader.load(new URLRequest(endGoalImportFile));
		}
                 
        //parse XML specification of obejcts of interest
        private function parseObjectsOfInterest(objectsOfInterest:XMLList, ooiManager:OOIManager, ooiScaleFactor:Number, canvasRectangle:Rectangle)
        {
            //object of interest loading counters
            var objectsParsed:Number = 0;
            var objectsLoaded:Number = 0;
            var objectsFailed:Number = 0;
             
            //flag noting if all objects have been parsed
            var allObjectsParsed:Boolean = false;
            for each(var ooi in objectsOfInterest)
            {
                if(ooi.hasOwnProperty("name") && ooi.hasOwnProperty("info_snippet") && ooi.hasOwnProperty("hitmap_filename") && ooi.hasOwnProperty("highlight_filename") && ooi.hasOwnProperty("found_image_filename") && ooi.hasOwnProperty("x") && ooi.hasOwnProperty("y") && ooi.hasOwnProperty("clue"))
                {					
                    //increment the number of objects parsed
                    objectsParsed++;
                     
                    //if information for the object's info pane has been provided, create a loader
                    var ooiInfoLoader:OOIInfoImporter = null;
                    if(ooi.hasOwnProperty("info"))                       
						ooiInfoLoader = new OOIInfoImporter(ooi.info);
                     
                    //create new object of interest
                    var newObject:ObjectOfInterest = new ObjectOfInterest(ooi.name, 
																		  ooi.info_snippet, 
																		  ooi.clue, 
																		  FileFinder.completePath(FileFinder.OOI_IMAGES, ooi.hitmap_filename), 
																		  FileFinder.completePath(FileFinder.OOI_IMAGES, ooi.highlight_filename), 
																		  FileFinder.completePath(FileFinder.OOI_IMAGES, ooi.found_image_filename), 
																		  ooiInfoLoader, 
																		  canvasRectangle.x + Number(ooi.x) * canvasRectangle.width, 
																		  canvasRectangle.y + Number(ooi.y) * canvasRectangle.height, 
																		  ooiScaleFactor, 
																		  new Point(canvasRectangle.x, canvasRectangle.y), 
																		  new Point(canvasRectangle.x + canvasRectangle.width, canvasRectangle.y + canvasRectangle.height));
                     
                    //set the display position of the object of interest's info pane
                    var infoPaneX:Number = 0;
                    var infoPaneY:Number = 0;
                    if(ooi.hasOwnProperty("info_pane_x"))
                        infoPaneX = canvasRectangle.x + ooi.info_pane_x * canvasRectangle.width;
                    if(ooi.hasOwnProperty("info_pane_y"))
                        infoPaneY = canvasRectangle.y + ooi.info_pane_y * canvasRectangle.height;
                    newObject.setInfoPanePosition(new Point(infoPaneX, infoPaneY));
                     
                     
                    //listen for the completion of the new object
                    newObject.addEventListener(Event.COMPLETE, function(e:Event):void  
                                                                                {  
                                                                                    //increment the number of successfully loaded obejcts
                                                                                    objectsLoaded++;
                                                                                     
                                                                                    //add the object to the painting canvas
                                                                                    ooiManager.addObjectOfInterest(ObjectOfInterest(e.target));
                                                                                     
                                                                                    //if this was the last object of interest to load, dispatch event
                                                                                    if(allObjectsParsed && objectsLoaded + objectsFailed >= objectsParsed)
                                                                                        dispatchEvent(new Event(OBJECTS_LOADED));
                                                                                });
                     
                    //listen of an IO error cause by the new object (signifies a failure to load file)
                    newObject.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent):void
                                                                                              {
                                                                                                //increment the number of failed objects
                                                                                                objectsFailed++;   
                                                                                                 
                                                                                                //if this was the last object of interest to load, dispatch event
                                                                                                if(allObjectsParsed && objectsLoaded + objectsFailed >= objectsParsed)
                                                                                                    dispatchEvent(new Event(OBJECTS_LOADED));
                                                                                              });
                     
                    //begin loading the components of the new object of interest
                    newObject.loadComponents();
                }
            }
             
            //flag that all objects have been parsed (not necessarily fully loaded)
            allObjectsParsed = true;
             
            //if no objects are left to load, initalize the clue list
            if(objectsLoaded + objectsFailed >= objectsParsed)
                dispatchEvent(new Event(OBJECTS_LOADED));
        }
         
        //parse XML specification of pieces of the end goal
        private function parseEndGoalPieces(pieces:XMLList, endGoalMenu:EndGoalMenu)
        {
            //object of interest loading counters
            var piecesParsed:Number = 0;
            var piecesLoaded:Number = 0;
            var piecesFailed:Number = 0;
              
            //flag nothing if all objects have been parsed
            var allPiecesParsed:Boolean = false;
             
            for each(var piece in pieces)
            {
                if(piece.hasOwnProperty("name"), piece.hasOwnProperty("filename"), piece.hasOwnProperty("x"), piece.hasOwnProperty("y"))
                {
                    //increment the number of objects parsed
                    piecesParsed++;
  
                    //create new object of interest
                    var newPiece:EndGoalPiece = new EndGoalPiece(piece.name, FileFinder.completePath(FileFinder.END_GOAL_IMAGES, piece.filename), Number(piece.x), Number(piece.y));
                       
                    //listen for the completion of the new object
                    newPiece.addEventListener(Event.COMPLETE, function(e:Event):void
                                                                                {
                                                                                    //increment the number of successfully loaded obejcts
                                                                                    piecesLoaded++;
																					
                                                                                    //add the object to the painting canvas
                                                                                    endGoalMenu.addPiece(EndGoalPiece(e.target));   
																					
																					//if this was the last end goal piece to load, dispatch event
                                                                                    if(allPiecesParsed && piecesLoaded + piecesFailed >= piecesParsed)
                                                                                        dispatchEvent(new Event(END_GOAL_LOADED));
                                                                                });
                       
                    //listen of an IO error cause by the new object (signifies a failure to load file)
                    newPiece.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent):void
                                                                                              {
																								
                                                                                                //increment the number of failed objects
                                                                                                piecesFailed++;  
																								
																								//if this was the last end goal piece to load, dispatch event
                                                                                                if(allPiecesParsed && piecesLoaded + piecesFailed >= piecesParsed)
                                                                                                    dispatchEvent(new Event(END_GOAL_LOADED));
                                                                                              });
                       
                    //begin loading the components of the new object of interest
                    newPiece.loadPiece();                 
                    newPiece.visible = false;
                      
                }
            }
               
            //flag that all objects have been parsed (not necessarily fully loaded)
            allPiecesParsed = true;
			
			 //if no pieces are left to load, initalize the clue list
            if(piecesLoaded + piecesFailed >= piecesParsed)
                dispatchEvent(new Event(END_GOAL_LOADED));
        }
		
		override public function addEventListener (type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void 
		{ 
			super.addEventListener (type, listener, useCapture, priority, useWeakReference);
			myArrayListeners.push({type:type, listener:listener, useCapture:useCapture});
		}
		
		function clearEvents():void 
		{
			for (var i:Number=0; i < myArrayListeners.length; i++) 
			{
				if (this.hasEventListener(myArrayListeners[i].type)) 
				{
					this.removeEventListener(myArrayListeners[i].type, myArrayListeners[i].listener);
				}
			}
			myArrayListeners=null;
		}
    }
}