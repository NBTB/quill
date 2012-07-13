package
{
	import flash.display.*;
	import flash.events.*;
	import flash.ui.*;	
	import flash.geom.Point;
    import flash.geom.Matrix;	
	import flash.net.URLRequest;
	
	public class LetterPieces extends MovieClip
	{
		var pieceName:String;
		var fileName:String;
		var yPos:Number;
		private var letter:Bitmap = null;
		private var scaleFactor:Number = 1; 
		
		function LetterPieces(pieceName:String, fileName:String, yPos:Number)
		{
			this.pieceName = pieceName;
			this.fileName = fileName;
			this.yPos = yPos;
			y = yPos;
			
			
			//store scale to be used when loading bitmaps
            if(scaleFactor  <= 0)
                scaleFactor = 1;
            this.scaleFactor = scaleFactor;
		}
		
		public function displayLetter(letter:Bitmap)
		{
			//create bitmap from file and make a copy that will not be scaled
			this.letter = letter;
			
			
			//add bitmap to container
			addChild(letter);		
			
		}
				
		
		
		
		//load the object's outline image
        public function loadPiece():void
        {
            //create new loader
            var loader:Loader = new Loader();
             
            //listen for the completion of the image loading
            loader.contentLoaderInfo.addEventListener(Event.COMPLETE, function(e:Event):void
                                                                                              {
                                                                                                //store image data as outline
                                                                                                letter = Bitmap(LoaderInfo(e.target).content);
                                                                                                 
                                                                                                //scale the outline image (internal data is not affected)
                                                                                                letter.width *= scaleFactor;
                                                                                                letter.height *= scaleFactor;
                                                                                                 
                                                                                                //store a fullsize lette for convenience
                                                                                                //fullsizeOutline = new Bitmap(letter.bitmapData);
                                                                                                addChild(letter);
                                                                                                //hideOutline();
                                                                                                 
                                                                                                //if both the hitmap and outline are now loaded, dispatch a completion event
                                                                                                if(letter)
                                                                                                    dispatchEvent(new Event(Event.COMPLETE));
                                                                                              });
             
            //listen for a IO error
            loader.contentLoaderInfo.addEventListener(IOErrorEvent.IO_ERROR, function(e:IOErrorEvent):void
                                                                                                            {  
                                                                                                                dispatchEvent(new IOErrorEvent(IOErrorEvent.IO_ERROR));
                                                                                                                trace("Failed to load outline of " + pieceName);
                                                                                                            });
             
            //begin loading image
            loader.load(new URLRequest(fileName));
        }
	}
	
	
}