package
{
    import flash.display.MovieClip;
    import flash.text.TextField;
    import flash.display.Shape;
    import flash.text.TextFormat;
    import flash.events.MouseEvent;
    import flash.geom.ColorTransform;
  
    class HelpMenu extends BaseMenu
    {
         
        var objectiveOption:TextField = new TextField();        //Button to display the objectives        
        var controlsOption:TextField = new TextField();         //Button to display the controls
		var letterOption:TextField = new TextField();         //Button to display the controls
		var objectsOption:TextField = new TextField();         //Button to display the controls
		var cluesOption:TextField = new TextField();         //Button to display the controls
		
		var tut:TutorialMenu;
         
        var textFormat:TextFormat = new TextFormat();           //Formatting
         
        //Creates the help menu
        public function HelpMenu(xPos:int, yPos:int, widthVal:int, heightVal:int):void
        {
            //sends variables to create background to the base menu
            super(xPos, yPos, widthVal, heightVal);
             
            //set up start position and size of link textfields
            var startX = 20;
            var startY = 20;
            var elementHeight = 40;
             
            //set up objective button
            objectiveOption.text = "Objective";
            objectiveOption.x = startX;
            objectiveOption.y = startY;
            objectiveOption.height = elementHeight;
            objectiveOption.selectable = false;
            addContent(objectiveOption);
          	
            //set up controls button
            controlsOption.text = "Controls";
			controlsOption.x = startX;
            controlsOption.height = elementHeight;
            controlsOption.selectable = false;
            addContentToTail(controlsOption);
             
            //set up clues button
            cluesOption.text = "Clues";
            cluesOption.x = startX;
            cluesOption.height = elementHeight;
            cluesOption.selectable = false;
            addContentToTail(cluesOption);
			
			//set up letter button
            letterOption.text = "Letter";
            letterOption.x = startX;
            letterOption.height = elementHeight;
            letterOption.selectable = false;
            addContentToTail(letterOption);
			
			//set up options button
            objectsOption.text = "Objects";
            objectsOption.x = startX;
            objectsOption.height = elementHeight;
            objectsOption.selectable = false;
            addContentToTail(objectsOption);
             
            //format buttons
            textFormat.color = 0xE5E5E5;
            textFormat.font = "Gabriola";
            textFormat.size = 26;
            objectiveOption.setTextFormat(textFormat);
            objectsOption.setTextFormat(textFormat);
            controlsOption.setTextFormat(textFormat);
			letterOption.setTextFormat(textFormat);
			cluesOption.setTextFormat(textFormat);
             
            //add event listeners to the buttons
            objectiveOption.addEventListener(MouseEvent.MOUSE_DOWN, showObjective);            
            controlsOption.addEventListener(MouseEvent.MOUSE_DOWN, showControls);
			cluesOption.addEventListener(MouseEvent.MOUSE_DOWN, showClues);
			objectsOption.addEventListener(MouseEvent.MOUSE_DOWN, showObjects);
			letterOption.addEventListener(MouseEvent.MOUSE_DOWN, showLetter);
             
            objectiveOption.addEventListener(MouseEvent.ROLL_OVER, colorChange);
            objectiveOption.addEventListener(MouseEvent.ROLL_OUT, revertColor);
             
            controlsOption.addEventListener(MouseEvent.ROLL_OVER, colorChange);
            controlsOption.addEventListener(MouseEvent.ROLL_OUT, revertColor);	
			
			cluesOption.addEventListener(MouseEvent.ROLL_OVER, colorChange);
            cluesOption.addEventListener(MouseEvent.ROLL_OUT, revertColor);	
			
			objectsOption.addEventListener(MouseEvent.ROLL_OVER, colorChange);
            objectsOption.addEventListener(MouseEvent.ROLL_OUT, revertColor);	
			
			letterOption.addEventListener(MouseEvent.ROLL_OVER, colorChange);
            letterOption.addEventListener(MouseEvent.ROLL_OUT, revertColor);	
			
        }         
      
         
        //function called if the button to show the objective is pressed
        public function showObjective(event:MouseEvent):void
        {
			TutorialMenu.fromHelp = true;
			TutorialMenu.curSlide = 2;
			tut = new TutorialMenu(-5,-240, stage.stageWidth, stage.stageHeight);	
			tut.removeChild(tut.proceedButton);
			tut.updateText();
			addChild(tut);
			tut.resumeButton.addEventListener(MouseEvent.MOUSE_DOWN,closeTutFromHelp);
        }
		
		 //function called if the button to show the info regarding clues is pressed
        public function showClues(event:MouseEvent):void
        {
			TutorialMenu.fromHelp = true;
			TutorialMenu.curSlide = 3;
			tut = new TutorialMenu(-5,-240, stage.stageWidth, stage.stageHeight);	
			tut.removeChild(tut.proceedButton);
			tut.updateText();
			addChild(tut);
			tut.resumeButton.addEventListener(MouseEvent.MOUSE_DOWN,closeTutFromHelp);
        }
		
		 //function called if the button to show the info regarding objects is pressed
        public function showObjects(event:MouseEvent):void
        {
			TutorialMenu.fromHelp = true;
			TutorialMenu.curSlide = 4;
			tut = new TutorialMenu(-5,-240, stage.stageWidth, stage.stageHeight);	
			tut.removeChild(tut.proceedButton);
			tut.updateText();
			addChild(tut);
			tut.resumeButton.addEventListener(MouseEvent.MOUSE_DOWN,closeTutFromHelp);
        }
		
		 //function called if the button to show the info regarding the letter is pressed
        public function showLetter(event:MouseEvent):void
        {
			TutorialMenu.fromHelp = true;
			TutorialMenu.curSlide = 5;
			tut = new TutorialMenu(-5,-240, stage.stageWidth, stage.stageHeight);	
			tut.removeChild(tut.proceedButton);
			tut.updateText();
			addChild(tut);
			tut.resumeButton.addEventListener(MouseEvent.MOUSE_DOWN,closeTutFromHelp);
        }
         
        //function called if the button to show the controls is pressed
        public function showControls(event:MouseEvent):void
        {
			TutorialMenu.fromHelp = true;
			TutorialMenu.curSlide = 6;
			tut = new TutorialMenu(-5,-240, stage.stageWidth, stage.stageHeight);
			tut.removeChild(tut.proceedButton);			
			tut.updateText();
			addChild(tut);
			tut.resumeButton.addEventListener(MouseEvent.MOUSE_DOWN,closeTutFromHelp);
			
        }
		
		function closeTutFromHelp(event:MouseEvent):void
		{
			TutorialMenu.fromHelp = false;
			removeChild(tut);
		}
	}
}