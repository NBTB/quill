package scripts
{
    import flash.display.*;
    import flash.text.*;
    import flash.geom.ColorTransform;
    import flash.events.*;
  
    public class EndGoalMenu extends BaseMenu
    {
  
        var pieces:Array=new Array();                       //stores all of the letterPieces
        var buttonFormat:TextFormat = new TextFormat();     //formatting		
		public var rewardCounter:Number = 0;				//counter of rewards given
		var heading:TextField = new TextField();			//labels the letter
		
		
		public static const NEXT_REWARD:int = -1;			//denotes the use of the next reward
         
        //Creates the end goal menu
        public function EndGoalMenu(xPos:int, yPos:int, widthVal:int, heightVal:int):void
        {
            //Pass in variables to the base menu to create background
            super(xPos, yPos, widthVal, heightVal, false, false, false, 1);
			
			//change previous and next button
			previousPageButton.text = "<";
			previousPageButton.x = 2;
			previousPageButton.y = (heightVal - previousPageButton.height) / 2;
			nextPageButton.text = ">";
			nextPageButton.x = widthVal - nextPageButton.width - 2;
			nextPageButton.y = (heightVal - nextPageButton.height) / 2;
			initHeading();
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
		
		function initHeading()
		{			
			heading.defaultTextFormat = BaseMenu.linkUnusableFormat;
			heading.borderColor = BaseMenu.menuBorderColor;
			heading.autoSize = TextFieldAutoSize.CENTER;
			heading.backgroundColor = BaseMenu.menuColor;			
			heading.y = 20;
			heading.width = 439;
			heading.text = "Letter home from Sergeant Poule";
			addChild(heading);
			
		}
		
		function displayHeading(event:MouseEvent):void
		{			
			heading.border = true;			
			heading.background = true;
			
			if(rewardCheck == true)
			{
				heading.text = "Letter To Poule's sister From Colonel MacAlister";
			}
			else
			{
				heading.text = "Letter home from Sergeant Poule";
			}
			
			
		}
		
		function removeHeading(event:MouseEvent):void
		{
			heading.border = false;
			heading.background = false;				
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