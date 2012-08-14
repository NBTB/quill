package
{
    import flash.display.MovieClip;
    import flash.text.TextField;
    import flash.display.Shape;
    import flash.text.TextFormat;
    import flash.geom.ColorTransform;
    import flash.events.*;
  
    public class LetterMenu extends BaseMenu
    {
  
        var pieces:Array=new Array();                       //stores all of the letterPieces
        public var nextButton:TextField;                    //button to go to the next part of the letter, currently redundant?
        var buttonFormat:TextFormat = new TextFormat();     //formatting		
		public var rewardCounter:Number = 0;						//???	/*TODO this should be a part of letter menu*/
		
		public static const NEXT_REWARD:int = -1;			//denotes the use of the next reward
         
        //Creates the letter menu
        public function LetterMenu(xPos:int, yPos:int, widthVal:int, heightVal:int):void
        {
            //Pass in variables to the base menu to create background
            super(xPos, yPos, widthVal, heightVal);
             
            //Create the next button
            /*nextButton = new TextField();
            nextButton.text = "Next Letter";
            nextButton.selectable = false;
            nextButton.x = 485;
            nextButton.y = 465;
            nextButton.width = 175;
            buttonFormat.color = 0xE5E5E5;
            buttonFormat.font = "Gabriola";
            buttonFormat.size = 30;
            nextButton.setTextFormat(buttonFormat);
           	addChild(nextButton);
            nextButton.visible = false;
            nextButton.addEventListener(MouseEvent.MOUSE_DOWN, clickNext);
            nextButton.addEventListener(MouseEvent.ROLL_OVER, colorChange);
            nextButton.addEventListener(MouseEvent.ROLL_OUT, revertColor);*/
        }
         
        //add new letter piece to list
        public function addPiece(newPiece:LetterPieces)
        {
            var newID:int = newPiece.getID();
            var indexFound:Boolean = false;
             
            if(pieces.length > 0)
            {
                for(var i:int = 0; i < pieces.length && !indexFound; i++)
                {
                    if(pieces[i].getID() > newID)
                    {
                        pieces.splice(i, 0, newPiece);
                        indexFound = true;
                    }
                }
                if(!indexFound)
                    pieces.push(newPiece);
            }
            else
                pieces.push(newPiece);
                 
            //add new object to list
            newPiece.width = 399;
            newPiece.height = 544;
             
            //add new object as a display list child
            addChild(newPiece);
             
             
        }
        
		//unlock the reward
		public function unlockReward(completionRequirement:int, rewardNumber:int = NEXT_REWARD)
		{
			/*make unlocking depend on reward number given*/
			if(rewardCounter < completionRequirement)
			{
				pieces[rewardCounter].visible = true;
				rewardCounter++;
				return true;
			}
			return false;
		}
        
         
        //next piece is shown
        function clickNext(event:MouseEvent):void
        {
            for(var i:Number = 0; i < pieces.length - 1; i++)
            {
                pieces[i].visible = !pieces[i].visible;
            }
            pieces[7].visible = !pieces[i].visible;
        }
    }
}