package scripts
{
	import flash.display.*;
	import flash.events.*;
	import flash.ui.*;	
	import flash.geom.Point;
    import flash.geom.Matrix;	
	import flash.net.URLRequest;
	
	public class EndGoalPiece extends MovieClip
	{
		private var pieceName:String;
		private var id:Number = 0;
		private var fileName:String;
		private var piece:Bitmap = null;
		private var scaleFactor:Number = 1; 
	
		private static var staticID:Number = 0;
		
		var myArrayListeners:Array=[];
		
		function EndGoalPiece(pieceName:String, fileName:String, xPos:Number, yPos:Number)
		{
			this.pieceName = pieceName;
			this.fileName = fileName;
			x = xPos;
			y = yPos;
			
			
			//set ID and increment static counter
			this.id = staticID;
			staticID++;
			
			//store scale to be used when loading bitmaps
            if(scaleFactor <= 0)
                scaleFactor = 1;
            this.scaleFactor = scaleFactor;
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
                                                                                                piece = Bitmap(LoaderInfo(e.target).content);
                                                                                                  
                                                                                                //scale the outline image (internal data is not affected)
                                                                                                piece.width *= scaleFactor;
                                                                                                piece.height *= scaleFactor;
                                                                                                  
                                                                                                //store a fullsize lette for convenience
                                                                                                addChild(piece);
                                                                                                  
                                                                                                //if both the hitmap and outline are now loaded, dispatch a completion event
                                                                                                if(piece)
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
		
		public function getID():Number	{	return id;				}
		
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