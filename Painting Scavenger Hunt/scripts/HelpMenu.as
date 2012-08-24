package scripts
{
    import flash.display.*;	
    import flash.events.*;
    import flash.text.*;
    import flash.geom.ColorTransform;
  
    class HelpMenu extends BaseMenu
    {
         
        var objectiveOption:TextField = new TextField();	      
        var controlsOption:TextField = new TextField();		
		var endGoalOption:TextField = new TextField();		
		var objectsOption:TextField = new TextField();	
		var cluesOption:TextField = new TextField();
		var aboutOption:TextField = new TextField();
		
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
            endGoalOption.text = "Letter";
            endGoalOption.x = startX;
            endGoalOption.height = elementHeight;
            endGoalOption.selectable = false;
            addContentToTail(endGoalOption);
			
			//set up options button
            objectsOption.text = "Objects";
            objectsOption.x = startX;
            objectsOption.height = elementHeight;
            objectsOption.selectable = false;
            addContentToTail(objectsOption);
			
			//set up about button
            aboutOption.text = "About";
            aboutOption.x = startX;
            aboutOption.height = elementHeight;
            aboutOption.selectable = false;
            addContentToTail(aboutOption);
             
            //format buttons
            textFormat.color = 0xE5E5E5;
            textFormat.font = "Gabriola";
            textFormat.size = 26;
            objectiveOption.setTextFormat(textFormat);
            objectsOption.setTextFormat(textFormat);
            controlsOption.setTextFormat(textFormat);
			endGoalOption.setTextFormat(textFormat);
			cluesOption.setTextFormat(textFormat);
			aboutOption.setTextFormat(textFormat);
			
			//listen for being added
			addEventListener(Event.ADDED, function(e:Event):void
														   {
																tut = new TutorialMenu(0, 0, stage.stageWidth, stage.stageHeight);	
																tut.removeChild(tut.proceedButton);
																tut.updateText();
																parent.addChild(tut);
																tut.resumeButton.addEventListener(MouseEvent.MOUSE_DOWN,closeTutFromHelp);
														   });
             
            //add event listeners to the buttons
            objectiveOption.addEventListener(MouseEvent.MOUSE_DOWN, showObjective);            
            controlsOption.addEventListener(MouseEvent.MOUSE_DOWN, showControls);
			cluesOption.addEventListener(MouseEvent.MOUSE_DOWN, showClues);
			objectsOption.addEventListener(MouseEvent.MOUSE_DOWN, showObjects);
			endGoalOption.addEventListener(MouseEvent.MOUSE_DOWN, showLetter);
			aboutOption.addEventListener(MouseEvent.MOUSE_DOWN, showAbout);
             
            objectiveOption.addEventListener(MouseEvent.ROLL_OVER, colorChange);
            objectiveOption.addEventListener(MouseEvent.ROLL_OUT, revertColor);
             
            controlsOption.addEventListener(MouseEvent.ROLL_OVER, colorChange);
            controlsOption.addEventListener(MouseEvent.ROLL_OUT, revertColor);	
			
			cluesOption.addEventListener(MouseEvent.ROLL_OVER, colorChange);
            cluesOption.addEventListener(MouseEvent.ROLL_OUT, revertColor);	
			
			objectsOption.addEventListener(MouseEvent.ROLL_OVER, colorChange);
            objectsOption.addEventListener(MouseEvent.ROLL_OUT, revertColor);	
			
			endGoalOption.addEventListener(MouseEvent.ROLL_OVER, colorChange);
            endGoalOption.addEventListener(MouseEvent.ROLL_OUT, revertColor);	
			
			aboutOption.addEventListener(MouseEvent.ROLL_OVER, colorChange);
            aboutOption.addEventListener(MouseEvent.ROLL_OUT, revertColor);				
        }         
      
         
        //function called if the button to show the objective is pressed
        public function showObjective(event:MouseEvent):void
        {			
			TutorialMenu.fromHelp = true;
			TutorialMenu.curSlide = 2;
			tut.updateText();
			tut.openMenu();
        }
		
		 //function called if the button to show the info regarding clues is pressed
        public function showClues(event:MouseEvent):void
        {
			TutorialMenu.fromHelp = true;
			TutorialMenu.curSlide = 3;
			tut.updateText();
			tut.openMenu();
        }
		
		 //function called if the button to show the info regarding objects is pressed
        public function showObjects(event:MouseEvent):void
        {
			TutorialMenu.fromHelp = true;
			TutorialMenu.curSlide = 4;
			tut.updateText();
			tut.openMenu();
        }
		
		 //function called if the button to show the info regarding the letter is pressed
        public function showLetter(event:MouseEvent):void
        {
			TutorialMenu.fromHelp = true;
			TutorialMenu.curSlide = 5;
			tut.updateText();
			tut.openMenu();
        }
         
        //function called if the button to show the controls is pressed
        public function showControls(event:MouseEvent):void
        {
			TutorialMenu.fromHelp = true;
			TutorialMenu.curSlide = 6;
			tut.updateText();
			tut.openMenu();			
        }
		
		public function showAbout(event:MouseEvent):void
		{
			TutorialMenu.fromHelp = true;
			TutorialMenu.curSlide = 7;
			tut.updateText();
			tut.openMenu();
		}
		
		function closeTutFromHelp(event:MouseEvent):void
		{
			TutorialMenu.fromHelp = false;
			//removeChild(tut);
			tut.closeMenu();
		}
	}
}