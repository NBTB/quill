package
{
    import flash.display.*;
    import flash.text.*;
    import flash.events.*;	
	 
    class CluesMenu extends BaseMenu
    {
        private var currentClueText:TextField = null;           //The displayed current clue
        private var currentClue:String = null;                  //The text of the current clue
        private var oldClues:Array = null;                      //Keeps track of all previous clues
         
        //Creates the clues menu
        public function CluesMenu(xPos:int, yPos:int, widthVal:int, heightVal:int):void
        {
            //call base constructor
            super(xPos, yPos, widthVal, heightVal, false, false, false);  
			
			//tempoarary (figure out a better place
			menuBackground.alpha = 1;
			
			//create array to store old clues
            oldClues = new Array();     
			
			
        }
         
        //add a new clue and update the list of old clues
        public function addClue(newClue:String)
        {   		
			//if a new clue was given, add it
			if(newClue)
			{				
				//make the new clue current
				currentClue = newClue;
				 
				//create new clue textfield and use the new clue's text
				currentClueText = createClueTextField();
				currentClueText.text = currentClue;			
				
				//add new text box to content
				addContentToHead(currentClueText);
			}
        }
         
        //make the current clue old
        public function outdateCurrentClue()
        {
			if(currentClue)
			{
				//remove the old clue text field
				removeContent(currentClueText)
				
				//add current clue to array of old clues
				oldClues.push(currentClue);
				 
				//no clue is current now
				currentClue = null;
				currentClueText = null;
			}
        }     
		
		//create a new textfield to be used for a clue
		private function createClueTextField():TextField
		{
			var newClueTextField = new TextField();
			newClueTextField.defaultTextFormat = BaseMenu.bodyFormat;
			newClueTextField.selectable = false;
			newClueTextField.wordWrap = true;
			newClueTextField.x = 10;
			newClueTextField.y = 10;
			newClueTextField.width = width - 20;
			newClueTextField.autoSize = TextFieldAutoSize.LEFT;
			
			return newClueTextField;
		}
    }
}