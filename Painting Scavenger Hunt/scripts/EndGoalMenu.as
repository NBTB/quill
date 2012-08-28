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
        var buttonFormat:TextFormat = new TextFormat();     //formatting		
		public var rewardCounter:Number = 0;				//counter of rewards given
		var heading:TextField;								//labels the letter
		
		
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
			addEventListener(MouseEvent.MOUSE_OVER, displayHeading);
			addEventListener(MouseEvent.MOUSE_OUT, removeHeading);
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
		
		function displayHeading(event:MouseEvent):void
		{
			heading = new TextField();
			heading.defaultTextFormat = BaseMenu.captionFormat;
			heading.border = true;
			heading.borderColor = 0x836A35;
			heading.background = true;
			heading.autoSize = "center";
			heading.backgroundColor = 0x010417;			
			heading.y = 20;
			heading.width = 439;	
			if(rewardCheck == true)
			{
				heading.text = "Letter To Poule's sister From Colonel MacAlister";
			}
			else
			{
				heading.text = "Letter home from Sergeant Poule";
			}
			addChild(heading);
			
		}
		
		function removeHeading(event:MouseEvent):void
		{
			removeChild(heading);
		}
		
		//unlock the final reward
		public function unlockFinalReward():Boolean
		{
			addContent(pieces[pieces.length - 1]); 
			pieces[pieces.length - 1].visible = true;
			rewardCheck = true;
			return true;
		} 
		
		public function hideRewards()
		{
			for(var i:int; i < pages.length; i++)
				pages[i].visible = false;
		}
         
		public function showRewards()
		{
			for(var i:int; i < pages.length; i++)
				pages[i].visible = true;
		}
    }
}