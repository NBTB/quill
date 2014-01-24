package scripts
{
    import flash.display.*;
    import flash.text.*;
    import flash.geom.*;
    import flash.events.*;	
	import flash.utils.*;	
  
    public class EndGoalMenu extends BaseMenu
    {
        private var pieces:Array=new Array();                      			//stores all of the letterPieces
        private var buttonFormat:TextFormat = new TextFormat();   			//formatting		
		private var rewardCounter:Number = 0;								//counter of rewards given
		private var heading:TextField = new TextField();					//labels the letter
		
		public static var completionRequirement = 0;		//number of rewards required to complete goal (does not include hidden rewards)
		public static var freeRewardCount = 0;				//number of free rewards given at beginning
		public static var headingTextColor = 0;				//color of text in overlay
		public static var goalOverlayText = null;			//text to display over goal
		public static var hiddenOverlayText = null;			//text to display over hidden goal
         
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
			
			previousPageButton.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void	{	heading.text = goalOverlayText		});
			nextPageButton.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void		{	heading.text = hiddenOverlayText	});
			
			//listen for being removed from the display list
			addEventListener(Event.REMOVED_FROM_STAGE, function(e:Event):void
																		{
																			var bitmapClassName:String = String(getDefinitionByName(getQualifiedClassName(Bitmap)));
																			for(var i:int = 0; i < pieces.size; i++)
																			{
																				if(String(getDefinitionByName(getQualifiedClassName(pieces[i]))) == bitmapClassName)
																				{
																					Bitmap(pieces[i]).bitmapData.dispose();
																					pieces = null;
																				}
																			}
																		});
        }
         
        //add new letter piece to list
        public function addPiece(newPiece:EndGoalPiece)
        {
            var newID:int = newPiece.getID();
            var indexFound:Boolean = false;
			newPiece.visible = false;
             
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
		
		public function initHeading()
		{			
			var endGoalOverlayFormat:TextFormat = new TextFormat(bodyFormat.font, bodyFormat.size, headingTextColor, bodyFormat.bold, bodyFormat.italic, bodyFormat.underline, null, null, bodyFormat.align);
			endGoalOverlayFormat.align = TextFormatAlign.CENTER;
		
			heading.defaultTextFormat = endGoalOverlayFormat;
			heading.autoSize = TextFieldAutoSize.CENTER;
			heading.x = 0;
			heading.y = 20;
			heading.width = width;
			heading.embedFonts = true;
			heading.text = goalOverlayText;
			heading.blendMode = BlendMode.LAYER;
			heading.selectable = false;
			fadeHeading();
			addChild(heading);
			
			addEventListener(MouseEvent.MOUSE_OVER, function(e:MouseEvent):void	{	displayHeading();	});
			addEventListener(MouseEvent.MOUSE_OUT, function(e:MouseEvent):void	{	fadeHeading();		});
		}
		
		function displayHeading():void
		{	
			heading.alpha = 0.7;
		}
		
		function fadeHeading():void
		{
			heading.alpha = 0.2;
		}
        
		//unlock a reward
		public function unlockReward():String
		{
			if(rewardCounter < freeRewardCount + completionRequirement)
			{
				addContent(pieces[rewardCounter]);    
				pieces[rewardCounter].visible = true;
				rewardCounter++;					
				return pieces[rewardCounter-1].getRewardNotification();
			}
			return null;
		}    
			
		//unlock the final reward
		public function unlockFinalReward():String
		{
			if(!pieces[pieces.length - 1].visible)
			{
				addContent(pieces[pieces.length - 1]); 
				pieces[pieces.length - 1].visible = true;
				heading.text = hiddenOverlayText;
				return pieces[pieces.length - 1].getRewardNotification();
			}
			else 
				return null;
		} 
		
		//determine if all non-hidden rewards have been awarded
		public function allNormalPiecesAwarded():Boolean	{	return (rewardCounter >= freeRewardCount + completionRequirement);	}
		
		//hide rewards from display
		public function hideRewards()
		{
			for(var i:int; i < pages.length; i++)
				pages[i].visible = false;
		}
		
		//Return number of pieces unlocked, how many total to win, and the percent unlocked
		public function getRewardInfo():String {
			var percent:Number = ( rewardCounter / completionRequirement ) * 100;
			var string:String = "You've unlocked " + rewardCounter + " out of " + completionRequirement + " pieces, which is " + percent + " percent.";
			return string
		}
         
		//display rewards
		public function showRewards()
		{
			for(var i:int; i < pages.length; i++)
				pages[i].visible = true;
		}
    }
}