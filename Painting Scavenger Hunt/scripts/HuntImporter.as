package
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
	
	public class HuntImporter
	{				
		public function importHunt(filename:String, paintingCanvas:PaintingCanvas, magnifyingGlass:MagnifyingGlass):void
		{
			//load XML file
			var xmlLoader:URLLoader = new URLLoader();
			xmlLoader.addEventListener(Event.COMPLETE, function(e:Event):void
																		{
																			parseHunt(new XML(e.target.data), paintingCanvas, magnifyingGlass);
																		});
			xmlLoader.load(new URLRequest(filename));
		}
		
		private function parseHunt(hunt:XML, paintingCanvas:PaintingCanvas, magnifyingGlass:MagnifyingGlass):void
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
			if(!hunt.hasOwnProperty("Painting") || !hunt.hasOwnProperty("End_Goal") || !hunt.hasOwnProperty("Object_Of_Interest"))
				return;
			
			//find the first painting specified and parse it
			var painting:XML = hunt.Painting[0];	
			parsePainting(hunt, painting, paintingCanvas, magnifyingGlass);
			
		}
		
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
				
		private function parseObjectsOfInterest(objectsOfInterest:XMLList, paintingCanvas:PaintingCanvas)
		{
			var objectsParsed:Number = 0;
			var objectsLoaded:Number = 0;
			var objectsFailed:Number = 0;
			var allObjectsParsed:Boolean = false;
			
			for each(var ooi in objectsOfInterest)
			{
				if(ooi.hasOwnProperty("name"), ooi.hasOwnProperty("hitmap_filename") && ooi.hasOwnProperty("outline_filename"), ooi.hasOwnProperty("x"), ooi.hasOwnProperty("y"), ooi.hasOwnProperty("clue"))
				{
					objectsParsed++;
					var newObject:ObjectOfInterest = new ObjectOfInterest(ooi.name, ooi.clue, ooi.hitmap_filename, ooi.outline_filename, Number(ooi.x), Number(ooi.y), paintingCanvas.getPaintingScale());
					
					newObject.addEventListener(Event.COMPLETE, function(e:Event):void	
																				{	
																					objectsLoaded++;
																					paintingCanvas.addObjectOfInterest(ObjectOfInterest(e.target));	
																					if(allObjectsParsed)
																						initClueList(paintingCanvas)
																				});
					
					newObject.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent):void
																							  {	
																							  	objectsFailed++;	
																								if(allObjectsParsed)
																									initClueList(paintingCanvas)
																							  });
					
					newObject.loadComponents();
				}
			}
			
			allObjectsParsed = true;
			
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
	}
}