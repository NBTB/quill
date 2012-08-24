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
		var creditsOption:TextField = new TextField();
		
		var instructions:InstructionsMenu;
		var instructionsOpening:Boolean = false;
         
        var textFormat:TextFormat = new TextFormat();           //Formatting
         
        //Creates the help menu
        public function HelpMenu(xPos:int, yPos:int, widthVal:int, heightVal:int):void
        {
            //sends variables to create background to the base menu
            super(xPos, yPos, widthVal, heightVal);
             
            //set up start position and size of link textfields
            var startX = 20;
            var startY = 10;
            var elementHeight = 35;
             
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
			
			//set up credits button
            creditsOption.text = "Credits";
            creditsOption.x = startX;
            creditsOption.height = elementHeight;
            creditsOption.selectable = false;
            addContentToTail(creditsOption);
             
            //format buttons
            textFormat.color = 0xE5E5E5;
            textFormat.font = "Gabriola";
            textFormat.size = 26;
			
            objectiveOption.setTextFormat(BaseMenu.linkUsableFormat);
            objectsOption.setTextFormat(BaseMenu.linkUsableFormat);
            controlsOption.setTextFormat(BaseMenu.linkUsableFormat);
			endGoalOption.setTextFormat(BaseMenu.linkUsableFormat);
			cluesOption.setTextFormat(BaseMenu.linkUsableFormat);
			aboutOption.setTextFormat(BaseMenu.linkUsableFormat);
			creditsOption.setTextFormat(BaseMenu.linkUsableFormat);
			
			//listen for being added
			addEventListener(Event.ADDED, function(e:Event):void
														   {
																instructions = new InstructionsMenu(30, 75, 700, 480);	
																instructions.updateText();
																parent.addChild(instructions);
																instructions.resumeButton.addEventListener(MouseEvent.MOUSE_DOWN,closeTutFromHelp);
																instructions.addEventListener(MenuEvent.MENU_OPENED, function(e:MenuEvent):void	
																																		  {	
																																		  	instructionsOpening = true;
																																		  	helpLinkClicked();	
																																			dispatchEvent(new MenuEvent(e.getTargetMenu(), e.type));
																																		  });  
														   });
             
            //add event listeners to the buttons
            objectiveOption.addEventListener(MouseEvent.MOUSE_DOWN, showObjective);            
            controlsOption.addEventListener(MouseEvent.MOUSE_DOWN, showControls);
			cluesOption.addEventListener(MouseEvent.MOUSE_DOWN, showClues);
			objectsOption.addEventListener(MouseEvent.MOUSE_DOWN, showObjects);
			endGoalOption.addEventListener(MouseEvent.MOUSE_DOWN, showLetter);
			aboutOption.addEventListener(MouseEvent.MOUSE_DOWN, showAbout);
			creditsOption.addEventListener(MouseEvent.MOUSE_DOWN, showCredits);
             
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
			
			creditsOption.addEventListener(MouseEvent.ROLL_OVER, colorChange);
            creditsOption.addEventListener(MouseEvent.ROLL_OUT, revertColor);				
        }         
      
         
        //function called if the button to show the objective is pressed
        public function showObjective(event:MouseEvent):void
        {			
			instructions.curSlide = 2;
			instructions.updateText();
			instructions.openMenu();
        }
		
		 //function called if the button to show the info regarding clues is pressed
        public function showClues(event:MouseEvent):void
        {
			instructions.curSlide = 3;
			instructions.updateText();
			instructions.openMenu();
        }
		
		 //function called if the button to show the info regarding objects is pressed
        public function showObjects(event:MouseEvent):void
        {
			instructions.curSlide = 4;
			instructions.updateText();
			instructions.openMenu();
        }
		
		 //function called if the button to show the info regarding the letter is pressed
        public function showLetter(event:MouseEvent):void
        {
			instructions.curSlide = 5;
			instructions.updateText();
			instructions.openMenu();
        }
         
        //function called if the button to show the controls is pressed
        public function showControls(event:MouseEvent):void
        {
			instructions.curSlide = 6;
			instructions.updateText();
			instructions.openMenu();			
        }
		
		public function showAbout(event:MouseEvent):void
		{
			instructions.curSlide = 7;
			instructions.updateText();
			instructions.openMenu();			
		}
		
		public function showCredits(event:MouseEvent):void
		{
			instructions.curSlide = 8;
			instructions.updateText();
			instructions.openMenu();			
		}
		
		function closeTutFromHelp(event:MouseEvent):void
		{
			//removeChild(instructions);
			instructions.closeMenu();
		}
		
			//handle the event of a help link being clicked
		private function helpLinkClicked():void
		{
			closeMenu();
			instructions.addEventListener(MenuEvent.MENU_CLOSED, paneFromLinkClosed);
		}
		
		//handle event of instructions menu being closed
		private function paneFromLinkClosed(e:Event):void
		{
			e.target.removeEventListener(MenuEvent.MENU_CLOSED, paneFromLinkClosed);
			instructionsOpening = false;
			dispatchEvent(new MenuEvent(BaseMenu(e.target), MenuEvent.MENU_CLOSED));
			dispatchEvent(new MenuEvent(this, MenuEvent.SPECIAL_OPEN_REQUEST));
		}
		
		override public function openMenu():Boolean
		{
			instructions.closeMenu();
			return super.openMenu();
		}
		
		override public function closeMenu():Boolean
		{
			if(!instructionsOpening)
				instructions.closeMenu();
			instructionsOpening = false;
			return super.closeMenu();
		}
	}
}