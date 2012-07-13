﻿package
{
    import flash.net.URLLoader;
    import flash.net.URLRequest;
    import flash.events.*;
    import flash.xml.*;
    import flash.display.DisplayObjectContainer;
    import flash.display.Stage;
    import flash.display.Loader;
    import flash.display.LoaderInfo;
    import flash.display.Bitmap;
    import flash.display.BitmapData;
    import PaintingCanvas;
    import MagnifyingGlass;
	import LetterMenu;
     
    public class HuntImporter
    {              
        //load XML scavenger hunt specification and call parser when done
        public function importHunt(filename:String, paintingCanvas:PaintingCanvas, magnifyingGlass:MagnifyingGlass, letterMenu:LetterMenu):void
        {
            //load XML file
            var xmlLoader:URLLoader = new URLLoader();
            xmlLoader.addEventListener(Event.COMPLETE, function(e:Event):void
                                                                        {
                                                                            parseHunt(new XML(e.target.data), paintingCanvas, magnifyingGlass, letterMenu);
                                                                        });
            xmlLoader.load(new URLRequest(filename));
        }
         
        //parse XML specification of scavenger hunt and modify standard objects, such as painting canvas and magnifying glass
        private function parseHunt(hunt:XML, paintingCanvas:PaintingCanvas, magnifyingGlass:MagnifyingGlass, letterMenu:LetterMenu):void
        {              
            //parse hunt attributes
            var mgZoom:Number = 1;
            var mgRadius:Number = 100;
            var huntAttribs:XMLList = hunt.attributes();
            for each(var attrib in huntAttribs)
            {
                if(attrib.name() == "zoom")
                    mgZoom = Number(attrib);
                if(attrib.name() == "magnifyRadius")
                    mgRadius = Number(attrib);
            }
             
            //set magnifying glass defaults
            magnifyingGlass.setDefaultZoom(mgZoom);
            magnifyingGlass.setDefaultRadius(mgRadius);
             
            //if the hunt is missing necessary information, return
            if(!hunt.hasOwnProperty("Painting") || !hunt.hasOwnProperty("End_Goal") || !hunt.hasOwnProperty("Object_Of_Interest") || !hunt.hasOwnProperty("Letter_Piece"))
                return;
             
            //find the first painting specified and parse it
            var painting:XML = hunt.Painting[0];   
            parsePainting(hunt, painting, paintingCanvas, magnifyingGlass);
			parseLetterPieces(hunt.Letter_Piece, letterMenu);
             
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
                                                                                                 
                                                                                                //mask the magnifying glass so that it is not drawn beyond the painting
                                                                                                magnifyingGlass.mask = paintingCanvas.getPaintingMask();
                                                                                                 
                                                                                                //create objects of interest
                                                                                                parseObjectsOfInterest(hunt.Object_Of_Interest, paintingCanvas);  
																								
																								
                                                                                             });
            bitmapLoader.load(new URLRequest(painting.filename));
        }
                 
        //parse XML specification of obejcts of interest
        private function parseObjectsOfInterest(objectsOfInterest:XMLList, paintingCanvas:PaintingCanvas)
        {
            //object of interest loading counters
            var objectsParsed:Number = 0;
            var objectsLoaded:Number = 0;
            var objectsFailed:Number = 0;
             
            //flag noting if all objects have been parsed
            var allObjectsParsed:Boolean = false;
             
            for each(var ooi in objectsOfInterest)
            {
                if(ooi.hasOwnProperty("name"), ooi.hasOwnProperty("hitmap_filename") && ooi.hasOwnProperty("outline_filename"), ooi.hasOwnProperty("x"), ooi.hasOwnProperty("y"), ooi.hasOwnProperty("clue"))
                {
                    //increment the number of objects parsed
                    objectsParsed++;
                     
                    //create new object of interest
                    var newObject:ObjectOfInterest = new ObjectOfInterest(ooi.name, ooi.clue, ooi.hitmap_filename, ooi.outline_filename, Number(ooi.x), Number(ooi.y), paintingCanvas.getPaintingScale());
                     
                    //listen for the completion of the new object
                    newObject.addEventListener(Event.COMPLETE, function(e:Event):void  
                                                                                {  
                                                                                    //increment the number of successfully loaded obejcts
                                                                                    objectsLoaded++;
                                                                                     
                                                                                    //add the object to the painting canvas
                                                                                    paintingCanvas.addObjectOfInterest(ObjectOfInterest(e.target));
                                                                                     
                                                                                    //if this was the last object of interest to load, initialize the clue list
                                                                                    if(allObjectsParsed && objectsLoaded + objectsFailed >= objectsParsed)
                                                                                        initClueList(paintingCanvas)
                                                                                });
                     
                    //listen of an IO error cause by the new object (signifies a failure to load file)
                    newObject.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent):void
                                                                                              {
                                                                                                //increment the number of failed objects
                                                                                                objectsFailed++;   
                                                                                                 
                                                                                                //if this was the last object of interest to load, initialize the clue list
                                                                                                if(allObjectsParsed && objectsLoaded + objectsFailed >= objectsParsed)
                                                                                                    initClueList(paintingCanvas)
                                                                                              });
                     
                    //begin loading the components of the new object of interest
                    newObject.loadComponents();
                }
            }
             
            //flag that all objects have been parsed (not necessarily fully loaded)
            allObjectsParsed = true;
             
            //if no objects are left to load, initalize the clue list
            if(objectsLoaded + objectsFailed >= objectsParsed)
                initClueList(paintingCanvas);
        }
         
        /*TODO this should be handled differently, consider creating events for when the painting, object list, or end goal are fully loaded*/
        private function initClueList(paintingCanvas:PaintingCanvas)
        {
            //prepare new list of unused objects of interest and pick the first object
            paintingCanvas.resetUnusedOOIList();
            paintingCanvas.pickNextOOI();
             
            /*TODO this might go somewhere else*/
            //display first clue
            paintingCanvas.displayClue();
        }
		
		//parse XML specification of obejcts of interest
        private function parseLetterPieces(pieces:XMLList, letterMenu:LetterMenu)
        {
            //object of interest loading counters
            var objectsParsed:Number = 0;
            var objectsLoaded:Number = 0;
            var objectsFailed:Number = 0;
             
            //flag noting if all objects have been parsed
            var allObjectsParsed:Boolean = false;
             
            for each(var piece in pieces)
            {
                if(piece.hasOwnProperty("name"), piece.hasOwnProperty("filename") ,piece.hasOwnProperty("y"))
                {
                    //increment the number of objects parsed
                    objectsParsed++;
                     
                    //create new object of interest
                    var newPiece:LetterPieces = new LetterPieces(piece.name, piece.filename, Number(piece.y));
                     
                    //listen for the completion of the new object
                    newPiece.addEventListener(Event.COMPLETE, function(e:Event):void  
                                                                                {  
                                                                                    //increment the number of successfully loaded obejcts
                                                                                    objectsLoaded++;
                                                                                     
                                                                                    //add the object to the painting canvas
                                                                                    letterMenu.addPiece(LetterPieces(e.target));
                                                                                     
                                                                                    
                                                                                });
                     
                    //listen of an IO error cause by the new object (signifies a failure to load file)
                    newPiece.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent):void
                                                                                              {
                                                                                                //increment the number of failed objects
                                                                                                objectsFailed++;   
                                                                                                 
                                                                                                
                                                                                              });
                     
                    //begin loading the components of the new object of interest
                    newPiece.loadPiece();					
					newPiece.visible = false;
					
                }
            }
             
            //flag that all objects have been parsed (not necessarily fully loaded)
            allObjectsParsed = true;
             
            
        }
    }
}