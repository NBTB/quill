package
{
    import flash.net.URLLoader;
    import flash.net.URLRequest;
    import flash.events.*;
    import flash.xml.*;
    import flash.display.*
    import flash.geom.*;
     
    public class HuntImporter extends EventDispatcher
    {              	
		private var startUpImportFile:String = null
		private var huntImportFile:String = null
		private var ooiImportFile:String = null
		private var endGoalImportFile:String = null
	
	
		var myArrayListeners:Array=[];					//Array of Event Listeners in BaseMenu
	
        //event types
		public static const SPEC_FILES_FOUND:String = "Specification files found";
		public static const START_UP_LOADED:String = "Start-up loaded";
        public static const PAINTING_LOADED:String = "Painting loaded";
        public static const OBJECTS_LOADED:String = "Objects loaded";
        public static const END_GOAL_LOADED:String = "End goal loaded";
		
		private var objectMenu:ObjectsMenu;
		
		//find specification files for importation with the XML of the given file
		public function findSpecFiles(specListFilename:String)
		{
			var xmlLoader:URLLoader = new URLLoader();
			xmlLoader.addEventListener(Event.COMPLETE, function(e:Event):void
																		{
																			//convert text to xml
																			var specList = new XML(e.target.data);
																			
																			//attempt to find spec files
																			if(specList.hasOwnProperty("start_up"))
																				startUpImportFile = specList.start_up;
																			if(specList.hasOwnProperty("hunt"))
																				huntImportFile = specList.hunt;
																			if(specList.hasOwnProperty("objects_of_interest"))
																				ooiImportFile = specList.objects_of_interest;
																			if(specList.hasOwnProperty("end_goal"))
																				endGoalImportFile = specList.end_goal;
																				
																			//dispatch success
																			dispatchEvent(new Event(SPEC_FILES_FOUND));
																		});
			xmlLoader.addEventListener(IOErrorEvent.IO_ERROR, function(e:Event):void
																			   {
																				   trace("Failed to load specification list.");
																			   });
			xmlLoader.load(new URLRequest(specListFilename));
		}
		
         
		//load XML start up specification
		public function importStartUp(startUpScreen:SplashScreen)
		{
			var xmlLoader:URLLoader = new URLLoader();
            xmlLoader.addEventListener(Event.COMPLETE, function(e:Event):void
                                                                        {
																			parseStartUp(new XML(e.target.data), startUpScreen);
                                                                        });
			xmlLoader.addEventListener(IOErrorEvent.IO_ERROR, function(e:Event):void
																			   {
																				   trace("Failed to load start-up parameters.");
																			   });
            xmlLoader.load(new URLRequest(startUpImportFile));
		}
		
		
        //load XML scavenger hunt specification
        public function importHunt(paintingCanvas:PaintingCanvas, ooiManager:OOIManager, magnifyingGlass:MagnifyingGlass, letterMenu:LetterMenu, objectsMenu:ObjectsMenu):void
        {
            var xmlLoader:URLLoader = new URLLoader();
			objectMenu = objectsMenu;
            xmlLoader.addEventListener(Event.COMPLETE, function(e:Event):void
                                                                        {
                                                                        	parseHunt(new XML(e.target.data), paintingCanvas, ooiManager, magnifyingGlass, letterMenu, objectsMenu);
                                                                        });
			xmlLoader.addEventListener(IOErrorEvent.IO_ERROR, function(e:Event):void
																			   {
																				   trace("Failed to load hunt parameters.");
																			   });
            xmlLoader.load(new URLRequest(huntImportFile));
        }
         
		 //parse XML specification of start-up
		 private function parseStartUp(startUp:XML, startUpScreen:SplashScreen)
		 {
			 if(startUp.hasOwnProperty("menu_color"))
				BaseMenu.menuColor = startUp.menu_color;
			
			if(startUp.hasOwnProperty("Splash_Screen"))
				parseSplashScreen(startUp.Splash_Screen[0], startUpScreen);
				
			dispatchEvent(new Event(START_UP_LOADED));
		 }
		 
        //parse XML specification of scavenger hunt and modify standard objects, such as painting canvas and magnifying glass
        private function parseHunt(hunt:XML, paintingCanvas:PaintingCanvas, ooiManager:OOIManager, magnifyingGlass:MagnifyingGlass, letterMenu:LetterMenu, objectsMenu:ObjectsMenu):void
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
             
            //if the hunt is missing necessary information, return
            if(!hunt.hasOwnProperty("Painting"))
                return;
				
            //listen for the painting to be fully loaded
            addEventListener(PAINTING_LOADED, function(e:Event):void
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
																																	 			parseLetterPieces(endGoalXML.children(), letterMenu);  
																																			else
																																				dispatchEvent(new Event(END_GOAL_LOADED));
																																			
																																	   });
																	endGoalXMLLoader.addEventListener(IOErrorEvent.IO_ERROR, function(e:Event):void
																																			  {
																																				  trace("Failed to load end goal specification file.");
																																			  });
																	endGoalXMLLoader.load(new URLRequest(endGoalImportFile));
                                                               });
             
            //find the first painting specified and parse it
            var painting:XML = hunt.Painting[0];   
            parsePainting(hunt, painting, paintingCanvas, magnifyingGlass);        			
        }
		
		private function parseSplashScreen(splashScreenInfo:XML, startUpScreen:SplashScreen)
		{
			var creditsLoader:TextLoader = new TextLoader();
						
			if(splashScreenInfo.hasOwnProperty("credits_text_file"))
			{
				creditsLoader.importText(splashScreenInfo.credits_text_file);
			}
			
			var aboutLoader:TextLoader = new TextLoader();
			
			if(splashScreenInfo.hasOwnProperty("about_text_file"))
			{
			   aboutLoader.importText(splashScreenInfo.about_text_file);
			
			}
			
			
			
			if(splashScreenInfo.hasOwnProperty("tutorial_text_file"))
			{
				   
			}
			
			creditsLoader.addEventListener(TextLoaderEvent.TEXT_FILE_IMPORTED, function(e:Event):void
																							   {
																									/*TODO take in section number*/
																									//parse text file
																									var newText:String = creditsLoader.parseText();
																									
																									//trace (splashLoader.returnFile());
																									//trace (newText);
																									
																									//if text was found, add a textfield to the object's info pane
																									if(newText)
																									{
																										if(splashScreenInfo.credits_text_file)
																										{
																											startUpScreen.getCreditsText(newText);
																										}
																									}
																							   });
			aboutLoader.addEventListener(TextLoaderEvent.TEXT_FILE_IMPORTED, function(e:Event):void
																							  {																								  
																								/*TODO take in section number*/
																								//parse text file
																								var newText:String = aboutLoader.parseText();
																								
																								//trace (splashLoader.returnFile());
																								//trace (newText);
																								
																								//if text was found, add a textfield to the object's info pane
																								if(newText)
																								{
																									if(splashScreenInfo.about_text_file)
																									{
																										startUpScreen.getAboutText(newText);
																									}
																								}
																							  });
		
		}
         
        //parse XML specification of painting to be applied to canvas
        private function parsePainting(hunt:XML, painting:XML, paintingCanvas:PaintingCanvas, magnifyingGlass:MagnifyingGlass)
        {
            //load painting
            var bitmapLoader:Loader = new Loader();
            bitmapLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event):void
                                                                                             {                 
                                                                                                //display painting on canvas
                                                                                                paintingCanvas.displayPainting(Bitmap(LoaderInfo(e.target).content));
                                                                                                 
                                                                                                //dispatch event for painting importation completion
                                                                                                dispatchEvent(new Event(PAINTING_LOADED));
                                                                                             });
			bitmapLoader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent):void
																										   {	
																										   	//dispatch and IO error message
																										   	dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR));	
																											
																											//display error in debug trace
																											trace("Failed to load painting");
																										   });
            bitmapLoader.load(new URLRequest(painting.interactive_filename));
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
                    if(ooi.hasOwnProperty("info"))                       ooiInfoLoader = new OOIInfoImporter(ooi.info);
                     
                    //create new object of interest
                    var newObject:ObjectOfInterest = new ObjectOfInterest(ooi.name, ooi.info_snippet, ooi.clue, ooi.hitmap_filename, ooi.highlight_filename, ooi.found_image_filename, ooiInfoLoader, canvasRectangle.x + Number(ooi.x) * canvasRectangle.width, canvasRectangle.y + Number(ooi.y) * canvasRectangle.height, ooiScaleFactor, new Point(canvasRectangle.x, canvasRectangle.y), new Point(canvasRectangle.x + canvasRectangle.width, canvasRectangle.y + canvasRectangle.height));
                     
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
        private function parseLetterPieces(pieces:XMLList, letterMenu:LetterMenu)
        {
            //object of interest loading counters
            var piecesParsed:Number = 0;
            var piecesLoaded:Number = 0;
            var piecesFailed:Number = 0;
              
            //flag nothing if all objects have been parsed
            var allPiecesParsed:Boolean = false;
             
            for each(var piece in pieces)
            {
                if(piece.hasOwnProperty("name"), piece.hasOwnProperty("filename") ,piece.hasOwnProperty("y"))
                {
                    //increment the number of objects parsed
                    piecesParsed++;
  
                    //create new object of interest
                    var newPiece:LetterPieces = new LetterPieces(piece.name, piece.filename, Number(piece.y));
                       
                    //listen for the completion of the new object
                    newPiece.addEventListener(Event.COMPLETE, function(e:Event):void
                                                                                {
                                                                                    //increment the number of successfully loaded obejcts
                                                                                    piecesLoaded++;
																					
                                                                                    //add the object to the painting canvas
                                                                                    letterMenu.addPiece(LetterPieces(e.target));   
																					
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