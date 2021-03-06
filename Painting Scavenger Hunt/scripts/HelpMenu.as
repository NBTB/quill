﻿package scripts
{
    import flash.display.*;	
    import flash.events.*;
    import flash.text.*;
    import flash.geom.*;
  
    class HelpMenu extends BaseMenu
    {
		var instructions:InstructionsMenu;			//instructions menu
		var instructionsOpening:Boolean = false;	//flag if instructions menu is opening
		
        //help menu options
        private var objectiveOption:TextButton = null;	      
        private var controlsOption:TextButton = null;		
		private var endGoalOption:TextButton = null;		
		private var objectsOption:TextButton = null;	
		private var cluesOption:TextButton = null;
		private var aboutOption:TextButton = null;
		private var creditsOption:TextButton = null;		
         
        public function HelpMenu(xPos:int, yPos:int, widthVal:int, heightVal:int, instructionsRect:Rectangle):void
        {
            //sends variables to create background to the base menu
            super(xPos, yPos, widthVal, heightVal);
             
            //set up start position and size of link textfields
            var startX = 10;
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
            endGoalOption = new TextButton(InstructionsMenu.endGoalTitle, linkUsableFormat, textUpColor, textOverColor, textDownColor);
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
																		instructions = new InstructionsMenu(instructionsRect.x, instructionsRect.y, instructionsRect.width, instructionsRect.height);	
																		parent.addChild(instructions);
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
			endGoalOption.addEventListener(MouseEvent.MOUSE_DOWN, showEndGoal);
			aboutOption.addEventListener(MouseEvent.MOUSE_DOWN, showAbout);
			creditsOption.addEventListener(MouseEvent.MOUSE_DOWN, showCredits);	
        }         
      
         
        //function called if the button to show the objective is pressed
        public function showObjective(event:MouseEvent):void
        {			
			instructions.updateText(InstructionsMenu.OBJECTIVE_SLIDE);
			instructions.openMenu();
        }
		
		 //function called if the button to show the info regarding clues is pressed
        public function showClues(event:MouseEvent):void
        {
			instructions.updateText(InstructionsMenu.CLUES_SLIDE);
			instructions.openMenu();
        }
		
		 //function called if the button to show the info regarding objects is pressed
        public function showObjects(event:MouseEvent):void
        {
			instructions.updateText(InstructionsMenu.OBJECTS_SLIDE);
			instructions.openMenu();
        }
		
		 //function called if the button to show the info regarding the end goal is pressed
        public function showEndGoal(event:MouseEvent):void
        {
			instructions.updateText(InstructionsMenu.END_GOAL_SLIDE);
			instructions.openMenu();
        }
         
        //function called if the button to show the controls is pressed
        public function showControls(event:MouseEvent):void
        {
			instructions.updateText(InstructionsMenu.CONTROLS_SLIDE);
			instructions.openMenu();			
        }
		
		public function showAbout(event:MouseEvent):void
		{
			instructions.updateText(InstructionsMenu.ABOUT_SLIDE);
			instructions.openMenu();			
		}
		
		public function showCredits(event:MouseEvent):void
		{
			instructions.updateText(InstructionsMenu.CREDITS_SLIDE);
			instructions.openMenu();			
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