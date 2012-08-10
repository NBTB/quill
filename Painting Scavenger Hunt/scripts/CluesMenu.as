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
		
		private static var currentClueTextFormat:TextFormat = new TextFormat("Arial", 14, 0xFFFFFF);	//default text format of clues
         
        //Creates the clues menu
        public function CluesMenu(xPos:int, yPos:int, widthVal:int, heightVal:int):void
        {
            //call base constructor
            super(xPos, yPos, widthVal, heightVal);             
            
			//create array to store old clues
            oldClues = new Array();             
        }
         
        //add a new clue and update the list of old clues
        public function addClue(newClue:String)
        {          
			if(newClue)
			{
				//make the new clue current
				currentClue = newClue;
				 
				//create new clue textfield and use the new clue's text
				currentClueText = createClueTextField();
				currentClueText.text = currentClue;			
				
				//add new text box to content
				addListChildToHead(currentClueText);
				//addChild(currentClueText);
			}
        }
         
        //make the current clue old
        public function outdateCurrentClue()
        {
			if(currentClue)
			{
				//grey the textfield
				currentClueText.textColor = 0x999999;
				
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
			newClueTextField.defaultTextFormat = currentClueTextFormat;
			newClueTextField.selectable = false;
			newClueTextField.wordWrap = true;
			newClueTextField.x = 10;
			newClueTextField.y = 10;
			newClueTextField.width = width - 40;
			newClueTextField.autoSize = TextFieldAutoSize.LEFT;
			
			//temporary
			newClueTextField.border = true;
			newClueTextField.borderColor = 0xFFFFFF;
			
			return newClueTextField;
		}
    }
}