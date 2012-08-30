package scripts
{
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	import flash.geom.ColorTransform;
	import flash.net.URLRequest;
	
	class RestartMenu extends BaseMenu
	{		
		var startOverQuestion:TextField = null;		//Question asking if the user wants to start over
		var startOverYes:TextButton = null;			//yes button
		var startOverNo:TextButton = null;			//no button
		
		//Creates the restart menu
		public function RestartMenu(xPos:int, yPos:int, widthVal:int, heightVal:int):void
		{
			//feeds the position values for the background to the base menu
			super(xPos, yPos, widthVal, heightVal, false, false, false);
			
			//Sets up the question
			startOverQuestion = new TextField();
			startOverQuestion.embedFonts = true;
			startOverQuestion.text = "Are you sure you want to start over? All progress will be lost.";
			startOverQuestion.wordWrap = true;
			startOverQuestion.x = 20;
			startOverQuestion.y = 20;
			startOverQuestion.width = widthVal-30;
			startOverQuestion.selectable = false;
			startOverQuestion.setTextFormat(BaseMenu.bodyFormat);
			
			//Sets up the yes and no buttons
			startOverYes = new TextButton("Restart", textButtonFormat, textUpColor, textOverColor, textDownColor);
			startOverYes.x = 80;
			startOverYes.y = 130;
			
			startOverNo = new TextButton("Cancel", textButtonFormat, textUpColor, textOverColor, textDownColor);
			startOverNo.x = 240;
			startOverNo.y = 130;
			
			//startOverYes.setTextFormat(BaseMenu.textButtonUpFormat);
			//startOverNo.setTextFormat(BaseMenu.textButtonUpFormat);
			
			//Adds all three
			addChild(startOverQuestion);
			addChild(startOverYes);
			addChild(startOverNo);
			
			//Event listeners for the yes and no buttons
			startOverYes.addEventListener(MouseEvent.MOUSE_DOWN, startOverProgram);
			startOverNo.addEventListener(MouseEvent.MOUSE_DOWN, function(e:Event):void	{	closeMenu();	});
		}
		
		//function which throws the event to restart the game
		public function startOverProgram(event:MouseEvent):void
		{
			//dispatch restart event
			this.dispatchEvent(new RestartEvent(RestartEvent.RESTART_GAME, true));
		}		
	}
}