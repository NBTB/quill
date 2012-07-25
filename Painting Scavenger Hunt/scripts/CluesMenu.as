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
		
		public function CluesMenu(xPos:int, yPos:int, widthVal:int, heightVal:int, theMenu:MainMenu):void
		{
			super(xPos, yPos, widthVal, heightVal, theMenu);
			
			oldClues = new Array();
			
			currentClueText = new TextField();
			oldClueText = new TextField();
						
			//temporary
			currentClueText.wordWrap = true;
			currentClueText.x = xPos+20;
			currentClueText.y = yPos+20;
			currentClueText.width = 150;			
			currentClueText.selectable = false;
			oldClueText.wordWrap = true;
			oldClueText.x = xPos+40;
			oldClueText.y = yPos+40;
			oldClueText.width = 150;	
			oldClueText.selectable = false;
			
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