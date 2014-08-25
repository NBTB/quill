package scripts {
    import flash.display.*;
    import flash.text.*;
    import flash.events.*;

    class CluesMenu extends BaseMenu {
        private var currentClueText:TextField = null;           //displayed current clue
        private var currentClue:String = null;                  //text of the current clue
        private var oldClues:Array = null;                      //keeps track of all previous clues

		public static var congratulations:String = null;		//player congratulation message for completing the game

        //Creates the clues menu
        public function CluesMenu(xPos:int, yPos:int, widthVal:int, heightVal:int):void {
            //call base constructor
            super(xPos, yPos, widthVal, heightVal, false, false, false, 1);
			changeBackgroundColor(BaseMenu.cluesMenuColor, 1);

            var preClueTextField = new TextField();
            preClueTextField.defaultTextFormat = BaseMenu.altTitleFormat;
            preClueTextField.embedFonts = true;
            preClueTextField.selectable = false;
            preClueTextField.x = 15;
            preClueTextField.y = 20;
            preClueTextField.width = 50;
            preClueTextField.text = "Clue: ";
            addChild(preClueTextField);
			//create array to store old clues
            oldClues = new Array();
            currentClueText = new TextField();
            currentClueText.defaultTextFormat = BaseMenu.bodyFormat;
            currentClueText.embedFonts = true;
            currentClueText.selectable = false;
            currentClueText.wordWrap = true;
            currentClueText.x = 70;
            currentClueText.y = 25;
            currentClueText.autoSize = TextFieldAutoSize.LEFT;
            currentClueText.width = width - 20;
            addChild(currentClueText);
        }

        //add a new clue and update the list of old clues
        public function addClue(newClue:String) {
			//if a new clue was given, add it
			if(newClue) {
				//make the new clue current
				currentClue = newClue;


				//create new clue textfield and use the new clue's text
                setClueText(currentClue);
				//add new text box to content
			}
        }

        //make the current clue old
        public function outdateCurrentClue() {
			if(currentClue) {
				//remove the old clue text field
				removeContent(currentClueText)

				//add current clue to array of old clues
				oldClues.push(currentClue);

				//no clue is current now
				currentClue = null;
			}
        }

        public function setClueText(clue:String) {
            currentClueText.text = clue;
        }

    }
}
