package scripts
{
    import flash.display.*;	
    import flash.events.*;
    import flash.text.*;
    import flash.geom.ColorTransform;
  
    class HelpMenu extends BaseMenu
    {
         
        var objectiveOption:TextButton = null;	      
        var controlsOption:TextButton = null;		
		var endGoalOption:TextButton = null;		
		var objectsOption:TextButton = null;	
		var cluesOption:TextButton = null;
		var aboutOption:TextButton = null;
		var creditsOption:TextButton = null;
		
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
            objectiveOption = new TextButton("Objective", linkUsableFormat, textUpColor, textOverColor, textDownColor);
            objectiveOption.x = startX;
            objectiveOption.y = startY;
            addContent(objectiveOption);
          	
            //set up controls button
            controlsOption = new TextButton("Controls", linkUsableFormat, textUpColor, textOverColor, textDownColor);
			controlsOption.x = startX;
            addContentToTail(controlsOption);
             
            //set up clues button
            cluesOption = new TextButton("Clues", linkUsableFormat, textUpColor, textOverColor, textDownColor);
            cluesOption.x = startX;
            addContentToTail(cluesOption);
			
			//set up letter button
            endGoalOption = new TextButton("Letter", linkUsableFormat, textUpColor, textOverColor, textDownColor);
            endGoalOption.x = startX;
            addContentToTail(endGoalOption);
			
			//set up objects button
            objectsOption = new TextButton("Objects", linkUsableFormat, textUpColor, textOverColor, textDownColor);
            objectsOption.x = startX;
            addContentToTail(objectsOption);
			
			//set up about button
            aboutOption = new TextButton("About", linkUsableFormat, textUpColor, textOverColor, textDownColor);
            aboutOption.x = startX;
            addContentToTail(aboutOption);
			
			//set up credits button
            creditsOption = new TextButton("Credits", linkUsableFormat, textUpColor, textOverColor, textDownColor);
            creditsOption.x = startX;
            addContentToTail(creditsOption);
			
			//listen for being added
			addEventListener(Event.ADDED_TO_STAGE, function(e:Event):void
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
			var closed:Boolean = super.closeMenu();
			if(!instructionsOpening)
				instructions.closeMenu();
			instructionsOpening = false;
			return closed;
		}
	}
}