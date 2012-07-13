package
{
    import flash.net.URLLoader;
    import flash.net.URLRequest;
    import flash.events.*;
    import flash.xml.*;
    import flash.display.DisplayObjectContainer;
    import flash.geom.ColorTransform;
    import flash.text.*;
    import flash.display.MovieClip;
    import flash.display.Shape;
    import flash.display.Bitmap;
    import flash.geom.Point;
    import flash.geom.Rectangle;
    import flash.utils.Timer;
    import ObjectOfInterest;
     
    public class PaintingCanvas extends MovieClip
    {
        var canvasWidth:Number;                             //width of canvas
        var canvasHeight:Number;                            //height of canvas
        private var painting:Bitmap = null;                 //painting displayed on canvas
        private var fullsizePainting:Bitmap = null;         //unscaled painting
        private var paintingScale:Number = 1;               //scale factor of painting to fit a given scene
        public var objectsOfInterest:Array = null;          //array of objects of interest
        private var ooiUnused:Array = null;                 //array of objects of interest that have not yet been used for hunt
        private var currentOOI:ObjectOfInterest = null;     //current object of interest being hunted
        private var paintingMask:Shape;                     //mask around painting used to cover display objects that should not be seen beyond such bounds
        private var clueTimer:Timer = null;                 //timer used to trigger the hiding of the clue textfield
        var clueText:TextField = new TextField();           //textfield to hold a newly unlocked clue
        /*TODO clueText and wrong answer should be private*/
         
        private static var clueTextFormat:TextFormat = new TextFormat("Edwardian Script ITC", 30, 0x40E0D0,
                                                                      null, null, null, null, null, TextFormatAlign.CENTER);    //text format of the clue textfield
        public static var wrongAnswer:String = "That is not the answer to the riddle";                                      //message that appears in the clue textfield when the wrong clue is guessed
         
        //construct a painting canvas with a position and dimensions
        public function PaintingCanvas(x:Number, y:Number, canvasWidth:Number, canvasHeight:Number):void
        {                      
            //store location and size (do not actually scale canvas)
            this.x = x;
            this.y = y;
            this.canvasWidth = canvasWidth;
            this.canvasHeight = canvasHeight;
             
            //create empty array of objects of interest
            objectsOfInterest = new Array();           
             
            //create clue timer
            clueTimer = new Timer(3 * 1000, 1);
             
            //listen for the completion of the clue timer
            clueTimer.addEventListener(TimerEvent.TIMER, function(e:TimerEvent):void
                                                                          {
                                                                            //reset clue time and hide the clue text box
                                                                            clueTimer.reset();
                                                                            clueText.text = ""
                                                                            clueText.visible = false;
                                                                          });
        }
         
        //display painting and setup clue display
        public function displayPainting(painting:Bitmap)
        {
            //create bitmap from file and make a copy that will not be scaled
            this.painting = painting;
            fullsizePainting = new Bitmap(painting.bitmapData);
             
            //adjust painting to fit the width of the container
            paintingScale = canvasWidth / painting.width;
            painting.width *= paintingScale;
            painting.height *= paintingScale;
             
            //add bitmap to display list
            addChild(painting);
             
            //create mask around painting
            paintingMask = new Shape();
            paintingMask.graphics.beginFill(0xffffff, 1);
            paintingMask.graphics.drawRect(painting.x, painting.y, painting.width, painting.height);
            paintingMask.graphics.endFill();
            addChildAt(paintingMask, getChildIndex(painting));
             
            //set clue textfield location and settings     
            clueText.defaultTextFormat = clueTextFormat;
            clueText.wordWrap=true;
            clueText.x=66;
            clueText.y=68;
            clueText.width=474;
             
            //add clue textfield to display list
            addChild(clueText);                    
        }
                                     
        //add an object of interest to the list
        public function addObjectOfInterest(newObject:ObjectOfInterest)
        {
            //add new object to list
            objectsOfInterest.push(newObject);
             
            //add new object as a display list child
            addChild(newObject);           
             
            //listen for when the cursor begins to hover over the new object
            newObject.addEventListener(MouseEvent.MOUSE_OVER, function(e:MouseEvent):void
                                                                                    {  
                                                                                        var targetObject:ObjectOfInterest = ObjectOfInterest(e.target);
                                                                                        targetObject.showOutline();
                                                                                        targetObject.prepareCaption();                                                                                     
                                                                                    });
  
            //listen for when the cursor stops hovering over the new object
            newObject.addEventListener(MouseEvent.MOUSE_OUT, function(e:MouseEvent):void
                                                                                    {  
                                                                                        var targetObject:ObjectOfInterest = ObjectOfInterest(e.target);
                                                                                        targetObject.hideOutline();
                                                                                        targetObject.unprepareCaption();
                                                                                    });
             
             
             
            //listen for when the object of interest is clicked
            newObject.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void
                                                                                    {  
                                                                                        if(currentOOI)
                                                                                        {
                                                                                            if(ObjectOfInterest(e.target).getID() == currentOOI.getID())
                                                                                            {
                                                                                                pickNextOOI();
                                                                                                displayClue();
                                                                                            }
                                                                                            else
                                                                                                displayIncorrect();
                                                                                        }
                                                                                    });
             
        }
         
        //reset the unused object of interest list so that objects can be re-hunted
        public function resetUnusedOOIList():void
        {
			ScavengerHunt.rewardCounter = 0;
            ooiUnused = new Array();
            for(var i:int = 0; i < objectsOfInterest.length; i++)
                ooiUnused.push(objectsOfInterest[i]);
        }
         
        //pick the next object of interest to hunt at random
        public function pickNextOOI():void
        {
            //generate a number [0, 1)
            var randNum:Number = Math.random();
            if(randNum >= 1)
                randNum = 0;
             
            //determine index of next object of interest
            var index:int = int(randNum * ooiUnused.length);
             
            //address chosen object
            currentOOI = ooiUnused[index];
             
            //remove object from list of unused
            ooiUnused.splice(index, 1);
        }
         
        //display the clue of the current object of interest in the clue textfield
        public function displayClue():void
        {
            //if an object is being hunted, display its clue
            if(currentOOI)
            {
                clueText.visible = true;
                clueText.text = currentOOI.getClue();
				ScavengerHunt.rewardCounter++;
				trace(ScavengerHunt.rewardCounter);
            }
            //otherwise, notify the user that the hunt has been completed
            else
            {
                clueText.visible = true;
                clueText.text = "All done";
            }
             
            //restart the clue hiding timer
            clueTimer.reset();
            clueTimer.start();
        }
         
        //notify the user that the last attempt at solving the clue was incorrect
        public function displayIncorrect():void
        {
            //display notification
            clueText.visible = true;
            clueText.text = wrongAnswer;
             
            //restart the clue hiding timer
            clueTimer.reset();
            clueTimer.start();
        }
        //add the painting to a list of bitmaps along with corresponding texture points based on a given sample point relative to the painting's upper-left corner
        public function addPaintingToList(bitmapList:Array, texturePointList:Array, samplePoint:Point, useFullsize:Boolean = false)
        {              
            //if flagged to use fullsize painting, add it to the bitmap list
            if(useFullsize)
                bitmapList.push(fullsizePainting);
            //otherwise, add the scaled outline
            else
                bitmapList.push(painting);
             
            //calculate the texture coordinates on the painting of the magnified center
            var paintingTexturePoint:Point = new Point();
            paintingTexturePoint.x = (samplePoint.x - painting.x) / painting.width;
            paintingTexturePoint.y = (samplePoint.y - painting.y) / painting.height;
            texturePointList.push(paintingTexturePoint);
             
        }
         
        //add all objects whose outlines are visible to a list of bitmaps
        public function addObjectOutlinesToList(bitmapList:Array, texturePointList:Array, samplePoint:Point, useFullsize:Boolean = false)
        {
            for(var i:int = 0; i < objectsOfInterest.length; i++)
                if(objectsOfInterest[i].isOutlined())
                    objectsOfInterest[i].addOutlineToList(bitmapList, texturePointList, new Point(samplePoint.x, samplePoint.y), useFullsize);
        }
         
        public function getPaintingMask():Shape     {   return paintingMask;    }
        public function getPaintingScale():Number   {   return paintingScale;   }
    }
}