package
{
	import flash.display.MovieClip;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.events.Event;
	import flash.xml.*;
	import flash.display.Loader;
	import flash.display.LoaderInfo;
	import flash.display.Bitmap;
	import flash.display.BitmapData;
	import PaintingCanvas;
	
	public class ScavengerHunt extends MovieClip
	{
		var paintingCanvas:PaintingCanvas = null;
		
		public function ScavengerHunt() : void
		{			
			//import hunt parameters
			importXML("scavenger hunt params.xml");
		}
		
		public function importXML(file:String):void
		{
			//load XML file
			var xmlLoader:URLLoader = new URLLoader();
			xmlLoader.addEventListener(Event.COMPLETE, parseXML);
			xmlLoader.load(new URLRequest(file));
		}
		
		public function parseXML(e:Event):void
		{			
			//retrieve XML data
			var xmlData:XML = new XML(e.target.data);
			
			//if the file is missing necessary information, return
			if(!xmlData.hasOwnProperty("Painting") || !xmlData.hasOwnProperty("End_Goal") || !xmlData.hasOwnProperty("Object_Of_Interest"))
				return;
			
			//find the first painting specified, return if not found
			var paintings:XMLList = xmlData.Painting;
			var paintingFilename:String = paintings[0].filename;
			
			//parse attributes
			var pmgZoom:Number = 1;
			var pmgRadius:Number = 100;
			var paintingAttribs:XMLList = paintings[0].attributes();
			for each(var attrib in paintingAttribs)
			{
				if(attrib.name() == "zoom")
					pmgZoom = Number(attrib);
				if(attrib.name() == "magnifyRadius")
					pmgRadius = Number(attrib);
			}
			
			//create canvas to fill stage
			paintingCanvas = new PaintingCanvas(0, 0, stage.stageWidth, stage.stageHeight, pmgZoom, pmgRadius);
			addChild(paintingCanvas);
			
			//load painting
			var bitmapLoader:Loader = new Loader();
			bitmapLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, createCanvas);
			bitmapLoader.load(new URLRequest(paintingFilename));
		}
		
		public function createCanvas(e:Event)
		{			
			//display painting in canvas
			paintingCanvas.displayPainting(Bitmap(LoaderInfo(e.target).content));
		}
	}
}