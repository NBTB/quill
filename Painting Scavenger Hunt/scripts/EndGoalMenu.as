﻿package scripts
{
    import flash.display.*;
    import flash.text.*;
    import flash.geom.ColorTransform;
    import flash.events.*;
  
    public class EndGoalMenu extends BaseMenu
    {
        private var pieces:Array=new Array();                      			//stores all of the letterPieces
        private var buttonFormat:TextFormat = new TextFormat();   			//formatting		
		private var rewardCounter:Number = 0;								//counter of rewards given
		private var heading:TextField = new TextField();					//labels the letter
		private var endGoalOverlayFormat:TextFormat = null;					//format of text overlaid above end goal		
		
		public static const NEXT_REWARD:int = -1;			//denotes the use of the next reward
         
        //Creates the end goal menu
        public function EndGoalMenu(xPos:int, yPos:int, widthVal:int, heightVal:int):void
        {
            //Pass in variables to the base menu to create background
            super(xPos, yPos, widthVal, heightVal, false, false, false, 1);
			
			//change previous and next button
			previousPageButton.setText("<");
			previousPageButton.fitHitboxToText();
			previousPageButton.x = 2;
			previousPageButton.y = (heightVal - previousPageButton.height) / 2;
			nextPageButton.setText(">");
			nextPageButton.fitHitboxToText();
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
			endGoalOverlayFormat = new TextFormat(bodyFormat.font, bodyFormat.size, bodyFormat.color, bodyFormat.bold, bodyFormat.italic, bodyFormat.underline, null, null, bodyFormat.align);
			endGoalOverlayFormat.color = 0;
			endGoalOverlayFormat.align = TextFormatAlign.CENTER;
		
			heading.defaultTextFormat = endGoalOverlayFormat;
			//heading.borderColor = over;
			heading.autoSize = TextFieldAutoSize.CENTER;
			heading.textColor = 0;	
			heading.x = 0;
			heading.y = 20;
			heading.width = width;
			heading.embedFonts = true;
			heading.alpha = 0.2;
			heading.text = "Letter home from Sergeant Poule";
			heading.blendMode = BlendMode.LAYER;
			addChild(heading);
			
		}
		
		function displayHeading(event:MouseEvent):void
		{	
			heading.alpha = 0.7;
			
			/*TODO this should be done on page switch*/
			if(rewardCheck == true)
			{
				heading.text = "Letter To Poule's Sister from Colonel McAlister";
			}
			else
			{
				heading.text = "Letter home from Sergeant Poule";
			}
			
			
		}
		
		function removeHeading(event:MouseEvent):void
		{
			heading.alpha = 0.2;
		}
		
		//unlock the final reward
		public function unlockFinalReward():Boolean
		{
			addContent(pieces[pieces.length - 1]); 
			pieces[pieces.length - 1].visible = true;
			rewardCheck = true;
			heading.text = "Letter To Poule's Sister from Colonel McAlister";
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