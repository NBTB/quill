﻿package scripts
{
    import flash.display.MovieClip;
    import flash.text.TextField;
    import flash.display.Shape;
    import flash.text.*;
    import flash.events.MouseEvent;
    import flash.geom.ColorTransform;
  
    class Ending extends RestartMenu
    {
		
		var continueButton:TextField = new TextField();
		//var newGameButton:TextField = new TextField();
		var ending:TextField = new TextField();		
		
		//var endText:TextFormat = new TextFormat();
		//var buttonText:TextFormat = new TextFormat();
		
		 //Creates the ending menu
        public function Ending(xPos:int, yPos:int, widthVal:int, heightVal:int):void
        {
            //sends variables to create background to the base menu
            super(xPos, yPos, widthVal, heightVal);
			
			startOverQuestion.text = "Congratulations! You have solved all of the riddles! Plus, you have unlocked a hidden letter! Would you like play again and discover new clues, or continue learning about the objects here?";
			startOverYes.text = "New Game"
			startOverNo.text = "Continue"
			startOverQuestion.setTextFormat(BaseMenu.bodyFormat);
			startOverYes.setTextFormat(BaseMenu.textButtonFormat);
			startOverNo.setTextFormat(BaseMenu.textButtonFormat);
			
			/*TODO make this not a restart menu*/
			
			/*ending.autoSize = TextFieldAutoSize.LEFT;
			ending.wordWrap = true;
			ending widht = 
			//startOverYes.autoSize = TextFieldAutoSize.LEFT;
			continueButton.autoSize = TextFieldAutoSize.LEFT;
			
			//startOverYes.y = startOverQuestion.y + startOverQuestion.height + 5;
			continueButton.y = width / 2;
			continueButton.y = ending.y + ending.height + 5;
			
			//add text and buttons
			addContent(ending);
			addContent(continueButton);*/
		}
		
	}
	
}