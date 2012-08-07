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
        var tutorialOption:TextField = new TextField();         //Button to display the full tutorial
        var controlsOption:TextField = new TextField();         //Button to display the controls
		
		var tut:TutorialMenu;
         
        var textFormat:TextFormat = new TextFormat();           //Formatting
         
        //Creates the help menu
        public function HelpMenu(xPos:int, yPos:int, widthVal:int, heightVal:int):void
        {
            //sends variables to create background to the base menu
            super(xPos, yPos, widthVal, heightVal);
             
            //set up start position and size of link textfields
            var startX = 10;
            var startY = 10;
            var elementHeight = 40;
             
            //set up objective button
            objectiveOption.text = "Objective";
            objectiveOption.x = startX;
            objectiveOption.y = startY;
            objectiveOption.height = elementHeight;
            objectiveOption.selectable = false;
            addListChild(objectiveOption);
             
            //set up controls button
            controlsOption.text = "Controls";
            controlsOption.x = startX;
            controlsOption.y = contentEndPoint.y;
            controlsOption.height = elementHeight;
            controlsOption.selectable = false;
            addListChild(controlsOption);
             
            //set up tutorial button
            tutorialOption.text = "Tutorial";
            tutorialOption.x = startX;
            tutorialOption.y = contentEndPoint.y;
            tutorialOption.height = elementHeight;
            tutorialOption.selectable = false;
            addListChild(tutorialOption);
             
            //format buttons
            textFormat.color = 0xE5E5E5;
            textFormat.font = "Gabriola";
            textFormat.size = 26;
            objectiveOption.setTextFormat(textFormat);
            tutorialOption.setTextFormat(textFormat);
            controlsOption.setTextFormat(textFormat);
             
            //add event listeners to the buttons
            objectiveOption.addEventListener(MouseEvent.MOUSE_DOWN, showObjective);
            tutorialOption.addEventListener(MouseEvent.MOUSE_DOWN, showTutorial);
            controlsOption.addEventListener(MouseEvent.MOUSE_DOWN, showControls);
             
            objectiveOption.addEventListener(MouseEvent.ROLL_OVER, colorChange);
            objectiveOption.addEventListener(MouseEvent.ROLL_OUT, revertColor);
             
            tutorialOption.addEventListener(MouseEvent.ROLL_OVER, colorChange);
            tutorialOption.addEventListener(MouseEvent.ROLL_OUT, revertColor);
             
            controlsOption.addEventListener(MouseEvent.ROLL_OVER, colorChange);
            controlsOption.addEventListener(MouseEvent.ROLL_OUT, revertColor);			
			
        }
         
        //function called if the button to show the tutorial is pressed
        public function showTutorial(event:MouseEvent):void
        {
			TutorialMenu.fromHelp = true;
			TutorialMenu.curSlide = 1;
			tut = new TutorialMenu(0,-350, stage.stageWidth, stage.stageHeight);				
			addChild(tut);
			tut.resumeButton.addEventListener(MouseEvent.MOUSE_DOWN,closeTutFromHelp);
        }
         
        //function called if the button to show the objective is pressed
        public function showObjective(event:MouseEvent):void
        {
			TutorialMenu.fromHelp = true;
			TutorialMenu.curSlide = 1;
			tut = new TutorialMenu(0,-350, stage.stageWidth, stage.stageHeight);	
			tut.removeChild(tut.continueButton);
			tut.updateText();
			addChild(tut);
			tut.resumeButton.addEventListener(MouseEvent.MOUSE_DOWN,closeTutFromHelp);
        }
         
        //function called if the button to show the controls is pressed
        public function showControls(event:MouseEvent):void
        {
			TutorialMenu.fromHelp = true;
			TutorialMenu.curSlide = 5;
			tut = new TutorialMenu(0,-350, stage.stageWidth, stage.stageHeight);	
			tut.removeChild(tut.continueButton);			
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