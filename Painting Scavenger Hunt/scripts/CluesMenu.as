package
{
    import flash.display.*;
    import flash.text.*;
    import flash.events.*;
     
    class CluesMenu extends BaseMenu
    {
        private var currentClueText:TextField = null;
        private var oldClueText:TextField = null;
        private var currentClue:String = null;
        private var oldClues:Array = null;
         
        public function CluesMenu(xPos):void
        {
            super(xPos);
            //this.addChild(menuBackground);
            //createBackground();
             
            oldClues = new Array();
             
            currentClueText = new TextField();
            oldClueText = new TextField();
                         
            //temporary
            currentClueText.wordWrap = true;
            currentClueText.x = 205;
            currentClueText.y = 430;
            currentClueText.width = 150;           
            oldClueText.wordWrap = true;
            oldClueText.x = 205;
            oldClueText.y = 430;
            oldClueText.width = 150;   
             
            var clueTextFormat:TextFormat = new TextFormat("Arial", 14, 0xFFFFFFFF);
            currentClueText.defaultTextFormat = clueTextFormat;
            oldClueText.defaultTextFormat = clueTextFormat;
            oldClueText.textColor = 0xFFFFFF99;
             
            addEventListener(Event.ADDED_TO_STAGE, addedToStage);
             
        }
  
        public function addedToStage(e:Event)
        {
            addChild(currentClueText);
            addChild(oldClueText);
        }
         
        //add a new clue and update the list of old clues
        public function addClue(newClue:String)
        {          
            //make the new clue current
            currentClue = newClue;
             
            /*TODO make list of clues*/
            //list clues
            if(currentClue)
                currentClueText.text = newClue;
            else
                currentClueText.text = "";
        }
         
        //make the current clue old
        public function outdateCurrentClue()
        {
            //add current clue to array of old clues
            oldClues.push(currentClue);
             
            //no clue is current now
            currentClue = null;
        }
     
    }
}