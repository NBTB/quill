package
{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.display.Shape;
	import flash.text.TextFormat;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;

	class HelpMenu extends BaseMenu
	{
		
		var objectiveOption:TextField = new TextField();
		var tutorialOption:TextField = new TextField();
		var controlsOption:TextField = new TextField();
		
		var textFormat:TextFormat = new TextFormat();
		
		public function HelpMenu(xPos:int, yPos:int, widthVal:int, heightVal:int, theMenu:MainMenu):void
		{
			super(xPos, yPos, widthVal, heightVal, theMenu);
			
			var startX = 10;
			var startY = 10;
			var elementHeight = 40;
			
			objectiveOption.text = "Objective";
			objectiveOption.x = startX;
			objectiveOption.y = startY;
			objectiveOption.height = elementHeight;
			objectiveOption.selectable = false;
			addListChild(objectiveOption);
			
			controlsOption.text = "Controls";
			controlsOption.x = startX;
			controlsOption.y = contentEndPoint.y;
			controlsOption.height = elementHeight;
			controlsOption.selectable = false;
			addListChild(controlsOption);
			
			tutorialOption.text = "Tutorial";
			tutorialOption.x = startX;
			tutorialOption.y = contentEndPoint.y;
			tutorialOption.height = elementHeight;
			tutorialOption.selectable = false;
			addListChild(tutorialOption);
			
			textFormat.color = 0xE5E5E5;
			textFormat.font = "Gabriola";
			textFormat.size = 26;
			objectiveOption.setTextFormat(textFormat);
			tutorialOption.setTextFormat(textFormat);
			controlsOption.setTextFormat(textFormat);
			
			/*addChild(objectiveOption);
			addChild(tutorialOption);
			addChild(controlsOption);*/
			
			objectiveOption.addEventListener(MouseEvent.MOUSE_DOWN, showObjective);
			tutorialOption.addEventListener(MouseEvent.MOUSE_DOWN, showTutorial);
			controlsOption.addEventListener(MouseEvent.MOUSE_DOWN, showControls);
			
			objectiveOption.addEventListener(MouseEvent.ROLL_OVER, colorChange);
			objectiveOption.addEventListener(MouseEvent.ROLL_OUT, revertColor);
			
			tutorialOption.addEventListener(MouseEvent.ROLL_OVER, colorChange);
			tutorialOption.addEventListener(MouseEvent.ROLL_OUT, revertColor);
			
			controlsOption.addEventListener(MouseEvent.ROLL_OVER, colorChange);
			controlsOption.addEventListener(MouseEvent.ROLL_OUT, revertColor);
		}
		
		public function showTutorial(event:MouseEvent):void
		{
			
		}
		
		public function showObjective(event:MouseEvent):void
		{
			
		}
		
		public function showControls(event:MouseEvent):void
		{
			
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