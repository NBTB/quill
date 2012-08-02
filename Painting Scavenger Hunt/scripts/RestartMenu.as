package
{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.text.TextFormat;
	import flash.display.Shape;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.display.Loader;
	import flash.net.URLRequest;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	class RestartMenu extends BaseMenu
	{
		
		var initiator:GameInitiator;							//A copy of the GameInitiator class, currently redundant as it is in another .swf
		var startOverQuestion:TextField = new TextField();		//Question asking if the user wants to start over
		var startOverYes:TextField = new TextField();			//yes button
		var startOverNo:TextField = new TextField();			//no button
		
		var textFormat:TextFormat = new TextFormat();			//Formatting
		
		//Creates the restart menu
		public function RestartMenu(xPos:int, yPos:int, widthVal:int, heightVal:int, theMenu:MainMenu):void
		{
			//feeds the position values for the background to the base menu
			super(xPos, yPos, widthVal, heightVal, theMenu);
			
			//Sets up the question
			startOverQuestion.text = "Are you sure you want to start over? All progress will be lost.";
			startOverQuestion.wordWrap = true;
			startOverQuestion.x = 20;
			startOverQuestion.y = 20;
			startOverQuestion.width = widthVal-30;
			startOverQuestion.selectable = false;
			
			textFormat.color = 0xCC9933;
			textFormat.font = "Gabriola";
			textFormat.size = 26;
			startOverQuestion.setTextFormat(textFormat);
			
			//Sets up the yes and no buttons
			startOverYes.text = "Restart";
			startOverYes.x = 80;
			startOverYes.y = 130;
			startOverYes.width = 60;
			startOverYes.height = 50;
			startOverYes.selectable = false;
			
			startOverNo.text = "Cancel";
			startOverNo.x = 240;
			startOverNo.y = 130;
			startOverNo.width = 60;
			startOverNo.height = 50;
			startOverNo.selectable = false;
			
			textFormat.color = 0xE5E5E5;
			textFormat.font = "Gabriola";
			textFormat.size = 26;
			startOverYes.setTextFormat(textFormat);
			startOverNo.setTextFormat(textFormat);
			
			//Adds all three
			addChild(startOverQuestion);
			addChild(startOverYes);
			addChild(startOverNo);
			
			//Event listeners for the yes and no buttons
			startOverYes.addEventListener(MouseEvent.MOUSE_DOWN, startOverProgram);
			startOverNo.addEventListener(MouseEvent.MOUSE_DOWN, closeWindow);
			
			startOverYes.addEventListener(MouseEvent.ROLL_OVER, colorChange);
			startOverYes.addEventListener(MouseEvent.ROLL_OUT, revertColor);
			
			startOverNo.addEventListener(MouseEvent.ROLL_OVER, colorChange);
			startOverNo.addEventListener(MouseEvent.ROLL_OUT, revertColor);
		}
		
		//function which throws the event to restart the game
		public function startOverProgram(event:MouseEvent):void
		{
			//initiator.reloadGame();
			this.dispatchEvent(new RestartEvent(RestartEvent.RESTART_GAME, true));
		}
		
		//Adds the initiator which launches the game, currently redundant
		public function addInitiator(theInitiator:GameInitiator)
		{
			//initiator = theInitiator;
		}
		
		//close all currently open menus
		public function closeWindow(event:MouseEvent):void
		{
			theMainMenu.closeMenus();
		}
		
		//changes the color of buttons
		public function colorChange(event:MouseEvent):void 
		{
			var sender:TextField=event.target as TextField;
			var myColor:ColorTransform=sender.transform.colorTransform;
			myColor.color=0xFFC000;
			sender.transform.colorTransform=myColor;
		}
		
		//reverts the buttons back to their original colors
		public function revertColor(event:MouseEvent):void 
		{
			var sender:TextField=event.target as TextField;
			var myColor:ColorTransform=sender.transform.colorTransform;	
			myColor.color=0xFFFFFF;		
			sender.transform.colorTransform=myColor;
		}
		
	}
}