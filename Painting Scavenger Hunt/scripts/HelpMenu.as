﻿package
{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.display.Shape;
	import flash.text.TextFormat;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;

	class HelpMenu extends BaseMenu
	{
		
		var objectiveOption:TextField = new TextField();		//Button to display the objectives
		var tutorialOption:TextField = new TextField();			//Button to display the full tutorial
		var controlsOption:TextField = new TextField();			//Button to display the controls
		
		var textFormat:TextFormat = new TextFormat();			//Formatting
		
		//Creates the help menu
		public function HelpMenu(xPos:int, yPos:int, widthVal:int, heightVal:int, theMenu:MainMenu):void
		{
			//sends variables to create background to the base menu
			super(xPos, yPos, widthVal, heightVal, theMenu);
			
			//set up objective button
			objectiveOption.text = "Objective";
			objectiveOption.x = xPos+20;
			objectiveOption.y = yPos+20;
			objectiveOption.height = 40;
			objectiveOption.selectable = false;
			
			//set up controls button
			controlsOption.text = "Controls";
			controlsOption.x = xPos+20;
			controlsOption.y = yPos+60;
			controlsOption.height = 40;
			controlsOption.selectable = false;
			
			//set up tutorial button
			tutorialOption.text = "Tutorial";
			tutorialOption.x = xPos+20;
			tutorialOption.y = yPos+100;
			tutorialOption.height = 40;
			tutorialOption.selectable = false;
			
			//format buttons
			textFormat.color = 0xE5E5E5;
			textFormat.font = "Gabriola";
			textFormat.size = 26;
			objectiveOption.setTextFormat(textFormat);
			tutorialOption.setTextFormat(textFormat);
			controlsOption.setTextFormat(textFormat);
			
			//add buttons
			addChild(objectiveOption);
			addChild(tutorialOption);
			addChild(controlsOption);
			
			//add event listeners to the buttons
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
		
		//function called if the button to show the tutorial is pressed
		public function showTutorial(event:MouseEvent):void
		{
			
		}
		
		//function called if the button to show the objective is pressed
		public function showObjective(event:MouseEvent):void
		{
			
		}
		
		//function called if the button to show the controls is pressed
		public function showControls(event:MouseEvent):void
		{
			
		}
		
		//changes the color of the buttons
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