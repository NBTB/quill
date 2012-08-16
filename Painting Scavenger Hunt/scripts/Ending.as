package
{
    import flash.display.MovieClip;
    import flash.text.TextField;
    import flash.display.Shape;
    import flash.text.TextFormat;
    import flash.events.MouseEvent;
    import flash.geom.ColorTransform;
  
    class Ending extends BaseMenu
    {
		
		var returnButton:TextField = new TextField();
		var newGameButton:TextField = new TextField();
		var ending:TextField = new TextField();		
		
		var endText:TextFormat = new TextFormat();
		var buttonText:TextFormat = new TextFormat();
		
		 //Creates the ending menu
        public function Ending(xPos:int, yPos:int, widthVal:int, heightVal:int):void
        {
            //sends variables to create background to the base menu
            super(xPos, yPos, widthVal, heightVal);
			initText();
			init();
		}
		
		function init()
		{
			returnButton.setTextFormat(buttonText);			
			newGameButton.setTextFormat(buttonText);
			ending.setTextFormat(endText);
			addChild(ending);
			addChild(newGameButton);
			addChild(returnButton);
			ending.selectable = false;
			newGameButton.selectable = false;
			returnButton.selectable = false;
			returnButton.addEventListener(MouseEvent.ROLL_OVER,colorChange);
			returnButton.addEventListener(MouseEvent.ROLL_OUT,revertColor);
			newGameButton.addEventListener(MouseEvent.ROLL_OVER, colorChange);
			newGameButton.addEventListener(MouseEvent.ROLL_OUT, revertColor);
			newGameButton.addEventListener(MouseEvent.MOUSE_DOWN, newGame);
		}
		
		function initText()
		{
			buttonText.color=0xE5E5E5;
			buttonText.font="Gabriola";
			buttonText.size=36;
			
			endText.color=0xCC9933;
			endText.font="Gabriola";
			endText.size=32;
			endText.align="center";
			
			
			newGameButton.x=1110;
			newGameButton.y=550;
			newGameButton.height=60;
			newGameButton.width=275;
			newGameButton.text="New Game";
			
			returnButton.x=20;
			returnButton.y=550;
			returnButton.height=60;
			returnButton.width=275;
			returnButton.text="Return to Painting";
			
			ending.x=100;
			ending.width=1050;
			ending.height=800;
			ending.wordWrap=true;
			ending.text="Congratulations! You have solved all of the riddles! Plus, you have unlocked a hidden letter! Click the link on the bottom left to return to the painting and read it, or click the link on the bottom right to start a new hunt!";
		}
		
		
		
		function newGame(event:MouseEvent):void{
			this.dispatchEvent(new RestartEvent(RestartEvent.RESTART_GAME, true));
		}
		
		
		
		override public function createCloseButton(placementRect):void {
			return;
		}
		
		
	}
	
}