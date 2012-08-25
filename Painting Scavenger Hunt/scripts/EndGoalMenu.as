package scripts
{
    import flash.display.MovieClip;
    import flash.text.TextField;
    import flash.display.Shape;
    import flash.text.TextFormat;
    import flash.geom.ColorTransform;
    import flash.events.*;
  
    public class EndGoalMenu extends BaseMenu
    {
  
        var pieces:Array=new Array();                       //stores all of the letterPieces
        public var nextButton:TextField;                    //button to go to the next part of the letter, currently redundant?
        var buttonFormat:TextFormat = new TextFormat();     //formatting		
		public var rewardCounter:Number = 0;				//counter of rewards given
		
		public static const NEXT_REWARD:int = -1;			//denotes the use of the next reward
         
        //Creates the end goal menu
        public function EndGoalMenu(xPos:int, yPos:int, widthVal:int, heightVal:int):void
        {
            //Pass in variables to the base menu to create background
            super(xPos, yPos, widthVal, heightVal, false, false, false, 1);
			
			//change previous and next button
			previousPageButton.text = "<";
			previousPageButton.x = 2;
			previousPageButton.y = (heightVal - previousPageButton.height) / 2
			nextPageButton.text = ">";
			nextPageButton.x = widthVal - nextPageButton.width - 2;
			nextPageButton.y = (heightVal - nextPageButton.height) / 2
        }
         
        //add new letter piece to list
        public function addPiece(newPiece:EndGoalPiece)
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
            newPiece.width = 449;
            newPiece.height = 664;  
        }
        
		//unlock the reward
		public function unlockReward(completionRequirement:int, rewardNumber:int = NEXT_REWARD):Boolean
		{
			
			/*TODO make unlocking depend on reward number given*/
			if(rewardCounter < completionRequirement)
			{
            	addContent(pieces[rewardCounter]);    
				pieces[rewardCounter].visible = true;
				rewardCounter++;
				return true;
			}
			return false;
		}    
		
		//unlock the final reward
		public function unlockFinalReward():Boolean
		{
			addContent(pieces[pieces.length - 1]); 
			pieces[pieces.length - 1].visible = true;
			return true;
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