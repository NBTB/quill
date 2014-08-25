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

		public static var completionRequirement = 0;		//number of rewards required to complete goal (does not include hidden rewards)
		public static var trueCompletionRequirement = 0;    //number of rewards required to complete goal (includes hidden rewards)
		public static var completionToShow = 0;				//display number of rewards the player needs to find, used because we can't alter completionRequirement
		public static var freeRewardCount = 0;				//number of free rewards given at beginning
		public static var goalOverlayText = null;			//text to display over goal
		public static var hiddenOverlayText = null;			//text to display over hidden goal

        //Creates the end goal menu
        public function EndGoalMenu(xPos:int, yPos:int, widthVal:int, heightVal:int):void
        {
            //Pass in variables to the base menu to create background
            super(xPos, yPos, widthVal, heightVal, false, false, false, 1);
			changeBackgroundColor(0x000000, 0); //Get rid of background for letter
			this.buttonMode = true;
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
			rewardCounter++;
			return null;
		}

		//unlock the final reward
		public function unlockFinalReward():String
		{
			if(!pieces[pieces.length - 1].visible)
			{
				var final_piece = pieces[pieces.length - 1];
				addContent(final_piece);
				final_piece.visible = true;
				return final_piece.getRewardNotification();
			}
			else
				return null;
		}

        public function moveSecondLetter():void {
            var final_piece = pieces[pieces.length - 1];
            if(final_piece.visible) {
                if(final_piece.x != 925) {
                    final_piece.x = 925;
                }
                else {
                    final_piece.x = 600;
                }
            }
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
			return "You've unlocked " + (rewardCounter - freeRewardCount) + " out of " + completionRequirement
			+ " pieces, which is " + (calculatePercentLeft(true) * 100) + " percent.";
		}

		public function getCluesLeft():String {
			return getCluesUnlocked() + " / " + getCluesNotUnlocked();
		}

		public function getCluesNotUnlocked():Number {
			return allNormalPiecesAwarded() ? trueCompletionRequirement : completionToShow;
		}

		public function getCluesUnlocked():Number {
			return rewardCounter - freeRewardCount;
		}

		public function calculatePercentLeft(round:Boolean = false):Number {
			if(allNormalPiecesAwarded()) {
				completionToShow = trueCompletionRequirement;
			}
			var percent:Number = ( (rewardCounter - freeRewardCount) / completionToShow );
			if(round == true) {
				percent = Math.round(percent);
			}
			return percent;
		}

		//display rewards
		public function showRewards()
		{
			for(var i:int; i < pages.length; i++)
				pages[i].visible = true;
		}

		public function getPieces() {
				return pieces;
		}

		public function getFirstPiece() {
			return pieces[0];
		}

		public function getLastPiece() {
			return pieces[pieces.length - 1];
		}

        public function scaleMenu(originalX:Number, originalY:Number, scaledX:Number, scaledY:Number):void {
            if(scaleX == 1) {
                scaleX = 0.15;
                scaleY = 0.15;
                x = scaledX;
                y = scaledY;
            }
            else {
                scaleX = 1;
                scaleY = 1;
                x = originalX;
                y = originalY;

            }
        }
    }
}
