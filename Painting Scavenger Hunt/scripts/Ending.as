package scripts
{
    import flash.display.*;
	import flash.events.*;
    import flash.text.*;
  
    class Ending extends BaseMenu
    {
		
		var continueButton:TextField = new TextField();
		var ending:TextField = new TextField();		
		
		 //Creates the ending menu
        public function Ending(xPos:int, yPos:int, widthVal:int, heightVal:int):void
        {
            //sends variables to create background to the base menu
            super(xPos, yPos, widthVal, heightVal, false, false, false);			
			
			//create ending text
			ending = new TextField();		
			ending.defaultTextFormat = BaseMenu.bodyFormat;
			ending.selectable = false;
			ending.autoSize = TextFieldAutoSize.LEFT;
			ending.wordWrap = true;
			ending.text = "Congratulations! You have solved all of the riddles! Although no clues remain, there is still plenty to discover and learn. Perhaps a secret awaits.";
			ending.x = 10;
			ending.y = ending.x;
			ending.width = width - (ending.x * 2);			
			addContent(ending);
			
			//create continue button
			continueButton = new TextField();
			continueButton.defaultTextFormat = BaseMenu.textButtonUpFormat;
			continueButton.selectable = false;			
			continueButton.autoSize = TextFieldAutoSize.LEFT;					
			continueButton.text = "Continue";
			continueButton.x = (width / 2) - (continueButton.width / 2);
			continueButton.y = ending.y + ending.height + 10;			
			addContent(continueButton);
			
			//listen for rolling over and off continue button
			continueButton.addEventListener(MouseEvent.ROLL_OVER, colorChange);
			continueButton.addEventListener(MouseEvent.ROLL_OUT, revertColor);
			
			//listen for the continue button to be clicked
			continueButton.addEventListener(MouseEvent.CLICK, function(e:MouseEvent):void	{	closeMenu();	});				
		}		
	}
}