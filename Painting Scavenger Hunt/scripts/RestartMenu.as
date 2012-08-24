package scripts
{
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	import flash.geom.ColorTransform;
	import flash.net.URLRequest;
	
	class RestartMenu extends BaseMenu
	{		
		var startOverQuestion:TextField = new TextField();		//Question asking if the user wants to start over
		var startOverYes:TextField = new TextField();			//yes button
		var startOverNo:TextField = new TextField();			//no button
		
		//Creates the restart menu
		public function RestartMenu(xPos:int, yPos:int, widthVal:int, heightVal:int):void
		{
			//feeds the position values for the background to the base menu
			super(xPos, yPos, widthVal, heightVal, false, false, false);
			
			//Sets up the question
			startOverQuestion.text = "Are you sure you want to start over? All progress will be lost.";
			startOverQuestion.wordWrap = true;
			startOverQuestion.x = 20;
			startOverQuestion.y = 20;
			startOverQuestion.width = widthVal-30;
			startOverQuestion.selectable = false;
			
			/*textFormat.color = 0xCC9933;
			textFormat.font = "Gabriola";
			textFormat.size = 26;*/
			startOverQuestion.setTextFormat(BaseMenu.bodyFormat);
			
			//Sets up the yes and no buttons
			startOverYes.text = "Restart";
			startOverYes.x = 80;
			startOverYes.y = 130;
			startOverYes.autoSize = TextFieldAutoSize.LEFT;
			startOverYes.selectable = false;
			
			startOverNo.text = "Cancel";
			startOverNo.x = 240;
			startOverNo.y = 130;
			startOverYes.autoSize = TextFieldAutoSize.LEFT;
			startOverNo.selectable = false;
			
			/*textFormat.color = 0xE5E5E5;
			textFormat.font = "Gabriola";
			textFormat.size = 26;*/
			startOverYes.setTextFormat(BaseMenu.textButtonFormat);
			startOverNo.setTextFormat(BaseMenu.textButtonFormat);
			
			//Adds all three
			addChild(startOverQuestion);
			addChild(startOverYes);
			addChild(startOverNo);
			
			//Event listeners for the yes and no buttons
			startOverYes.addEventListener(MouseEvent.MOUSE_DOWN, startOverProgram);
			startOverNo.addEventListener(MouseEvent.MOUSE_DOWN, function(e:Event):void	{	closeMenu();	});
			
			startOverYes.addEventListener(MouseEvent.ROLL_OVER, colorChange);
			startOverYes.addEventListener(MouseEvent.ROLL_OUT, revertColor);
			
			startOverNo.addEventListener(MouseEvent.ROLL_OVER, colorChange);
			startOverNo.addEventListener(MouseEvent.ROLL_OUT, revertColor);
		}
		
		//function which throws the event to restart the game
		public function startOverProgram(event:MouseEvent):void
		{
			//dispatch restart event
			this.dispatchEvent(new RestartEvent(RestartEvent.RESTART_GAME, true));
		}		
	}
}