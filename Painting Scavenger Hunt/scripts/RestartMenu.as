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
	
	class RestartMenu extends BaseMenu
	{
		
		var initiator:GameInitiator;
		
		var startOverQuestion:TextField = new TextField();
		var startOverYes:TextField = new TextField();
		var startOverNo:TextField = new TextField();
		
		var textFormat:TextFormat = new TextFormat();

		public function RestartMenu(xPos:int, yPos:int, widthVal:int, heightVal:int, theMenu:MainMenu):void
		{
			super(xPos, yPos, widthVal, heightVal, theMenu);
			
			startOverQuestion.text = "Are you sure you want to start over? All progress will be lost.";
			startOverQuestion.wordWrap = true;
			startOverQuestion.x = xPos+20;
			startOverQuestion.y = yPos+20;
			startOverQuestion.width = widthVal-30;
			startOverQuestion.selectable = false;
			
			textFormat.color = 0xCC9933;
			textFormat.font = "Gabriola";
			textFormat.size = 26;
			startOverQuestion.setTextFormat(textFormat);
			
			startOverYes.text = "Restart";
			startOverYes.x = xPos+80;
			startOverYes.y = yPos+130;
			startOverYes.width = 60;
			startOverYes.height = 50;
			startOverYes.selectable = false;
			
			startOverNo.text = "Cancel";
			startOverNo.x = xPos+240;
			startOverNo.y = yPos+130;
			startOverNo.width = 60;
			startOverNo.height = 50;
			startOverNo.selectable = false;
			
			textFormat.color = 0xE5E5E5;
			textFormat.font = "Gabriola";
			textFormat.size = 26;
			startOverYes.setTextFormat(textFormat);
			startOverNo.setTextFormat(textFormat);
			
			addChild(startOverQuestion);
			addChild(startOverYes);
			addChild(startOverNo);
			
			startOverYes.addEventListener(MouseEvent.MOUSE_DOWN, startOverProgram);
			startOverNo.addEventListener(MouseEvent.MOUSE_DOWN, closeWindow);
			
			startOverYes.addEventListener(MouseEvent.ROLL_OVER, colorChange);
			startOverYes.addEventListener(MouseEvent.ROLL_OUT, revertColor);
			
			startOverNo.addEventListener(MouseEvent.ROLL_OVER, colorChange);
			startOverNo.addEventListener(MouseEvent.ROLL_OUT, revertColor);
		}
		
		public function startOverProgram(event:MouseEvent):void
		{
			initiator.reloadGame();
		}
		
		public function addInitiator(theInitiator:GameInitiator)
		{
			initiator = theInitiator;
		}
		
		public function closeWindow(event:MouseEvent):void
		{
			theMainMenu.closeMenus();
		}
		
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