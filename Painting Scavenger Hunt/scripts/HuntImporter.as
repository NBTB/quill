package
{
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.events.*;
	import flash.xml.*;
	import flash.display.*
	import flash.geom.Point;
	
	public class HuntImporter extends EventDispatcher
	{				
		//event types
		public static const PAINTING_LOADED:String = "Painting loaded";
		public static const OBJECTS_LOADED:String = "Objects loaded";
		public static const END_GOAL_LOADED:String = "End goal loaded";
		
		//load XML scavenger hunt specification and call parser when done
		public function importHunt(filename:String, paintingCanvas:PaintingCanvas, ooiManager:OOIManager, magnifyingGlass:MagnifyingGlass, letterMenu:LetterMenu, objectsMenu:ObjectsMenu):void
		{
			//load XML file
			var xmlLoader:URLLoader = new URLLoader();
			xmlLoader.addEventListener(Event.COMPLETE, function(e:Event):void
																		{
																			parseHunt(new XML(e.target.data), paintingCanvas, ooiManager, magnifyingGlass, letterMenu, objectsMenu);
																		});
			xmlLoader.load(new URLRequest(filename));
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
				if(attrib.name() == "zoom")
					mgZoom = Number(attrib);
				if(attrib.name() == "magnify_radius")
					mgRadius = Number(attrib);
				if(attrib.name() == "huntCount")
					huntCount = int(Number(attrib));
			}
			
			//set magnifying glass defaults
			magnifyingGlass.setDefaultZoom(mgZoom);
			magnifyingGlass.setDefaultRadius(mgRadius);
			
			//set number of number of usable objects of interest
			ooiManager.setUsableOOICount(huntCount);
			
			//if the hunt is missing necessary information, return
			if(!hunt.hasOwnProperty("Painting") || !hunt.hasOwnProperty("End_Goal") || !hunt.hasOwnProperty("Object_Of_Interest") || !hunt.hasOwnProperty("Letter_Piece"))
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
																	
																	//parse objects of interest to be used in hunt
																	parseObjectsOfInterest(hunt.Object_Of_Interest, ooiManager, paintingCanvas.getPaintingScale(), paintingCanvas.getPaintingWidth(), paintingCanvas.getPaintingHeight());	
																   
																	//listen for all of the end goal pieces to be fully loaded
																	addEventListener(OBJECTS_LOADED, function(e:Event):void
																													  {
																														endGoalLoaded = true;
																														if(objectsLoaded && endGoalLoaded)
																															dispatchEvent(new Event(Event.COMPLETE));
																													  });
																	
																	//parse objects of interest to be used in hunt
																	parseLetterPieces(hunt.Letter_Piece, letterMenu);	
															   });
			
			//find the first painting specified and parse it
			var painting:XML = hunt.Painting[0];	
			parsePainting(hunt, painting, paintingCanvas, magnifyingGlass);			
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
			bitmapLoader.load(new URLRequest(painting.filename));
		}
				
		//parse XML specification of obejcts of interest
		private function parseObjectsOfInterest(objectsOfInterest:XMLList, ooiManager:OOIManager, ooiScaleFactor:Number, paintingWidth:Number, paintingHeight:Number)
		{
			//object of interest loading counters
			var objectsParsed:Number = 0;
			var objectsLoaded:Number = 0;
			var objectsFailed:Number = 0;
			
			//flag noting if all objects have been parsed
			var allObjectsParsed:Boolean = false;
			
			for each(var ooi in objectsOfInterest)
			{
				if(ooi.hasOwnProperty("name"), ooi.hasOwnProperty("hitmap_filename") && ooi.hasOwnProperty("highlight_filename"), ooi.hasOwnProperty("x"), ooi.hasOwnProperty("y"), ooi.hasOwnProperty("clue"))
				{
					//increment the number of objects parsed
					objectsParsed++;
					
					//create new object of interest
					var newObject:ObjectOfInterest = new ObjectOfInterest(ooi.name, ooi.clue, ooi.hitmap_filename, ooi.highlight_filename, Number(ooi.x) * paintingWidth, Number(ooi.y) * paintingHeight, ooiScaleFactor, new Point(0, 0), new Point(paintingWidth, paintingHeight));
					
					//set the display position of the object of interest's info pane
					var infoPaneX:Number = 0;
					var infoPaneY:Number = 0;
					if(ooi.hasOwnProperty("info_pane_x"))
						infoPaneX = ooi.info_pane_x * paintingWidth;
					if(ooi.hasOwnProperty("info_pane_y"))
						infoPaneY = ooi.info_pane_y * paintingHeight;
					newObject.setInfoPanePosition(new Point(infoPaneX, infoPaneY));
					
					
					//listen for the completion of the new object
					newObject.addEventListener(Event.COMPLETE, function(e:Event):void	
																				{	
																					//increment the number of successfully loaded obejcts
																					objectsLoaded++;
																					
																					//add the object to the painting canvas
																					ooiManager.addObjectOfInterest(ObjectOfInterest(e.target));
																					
																					//if this was the last object of interest to load, initialize the clue list
																					if(allObjectsParsed && objectsLoaded + objectsFailed >= objectsParsed)
																						dispatchEvent(new Event(OBJECTS_LOADED));
																				});
					
					//listen of an IO error cause by the new object (signifies a failure to load file)
					newObject.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent):void
																							  {	
																							  	//increment the number of failed objects
																							  	objectsFailed++;	
																								
																								//if this was the last object of interest to load, initialize the clue list
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
                                                                                });
                      
                    //listen of an IO error cause by the new object (signifies a failure to load file)
                    newPiece.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent):void
                                                                                              {
                                                                                                //increment the number of failed objects
                                                                                                piecesFailed++;   
                                                                                              });
                      
                    //begin loading the components of the new object of interest
                    newPiece.loadPiece();                  
                    newPiece.visible = false;
                     
                }
            }
              
            //flag that all objects have been parsed (not necessarily fully loaded)
            allPiecesParsed = true; 
        }
    }
}