package
{
	import flash.text.TextField;
	import flash.display.Shape;
	import flash.display.DisplayObject;
	import flash.text.TextFormat;
	import flash.events.MouseEvent;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	


	public class TutorialMenu extends MovieClip	{
		
		public var proceedButton:TextField = new TextField();
		var continueButton:TextField = new TextField();
		var previousButton:TextField = new TextField();
		var controls:TextField = new TextField();
		var curSlide:Number;		
		var theBackground:Shape = new Shape();
		var tutText:TextFormat = new TextFormat();
		var buttonFormat:TextFormat = new TextFormat();
		
		public function TutorialMenu()
		{
			curSlide = 1;
			initText();
			
			proceedButton.setTextFormat(buttonFormat);
			continueButton.setTextFormat(buttonFormat);
			previousButton.setTextFormat(buttonFormat);
			controls.setTextFormat(tutText);
			controls.selectable = false;
			continueButton.selectable = false;
			previousButton.selectable = false;
			addChild(controls);
			addChild(continueButton);
			continueButton.addEventListener(MouseEvent.MOUSE_DOWN,continueReading);
			previousButton.addEventListener(MouseEvent.MOUSE_DOWN,previousPage);
			
		}	
		
		function initText()
		{
			buttonFormat.color = 0xE5E5E5;
			buttonFormat.font = "Gabriola";
			buttonFormat.size = 36;
			
			tutText.color = 0xCC9933;
			tutText.font = "Gabriola";
			tutText.size = 32;			
			
			proceedButton.x = 630;
			proceedButton.y = 500;
			proceedButton.height = 50;
			proceedButton.width = 275;
			proceedButton.text = "Proceed";
			continueButton.x = 630;
			continueButton.y = 500;
			continueButton.height = 50;
			continueButton.width = 275;
			continueButton.text = "Continue";
			previousButton.x = 0;
			previousButton.y = 500;
			previousButton.height = 50;
			previousButton.width = 275;
			previousButton.text = "Previous";
			
			controls.width = 750;
			controls.height = 800;
			controls.wordWrap = true;
			controls.text = "Welcome to The Night Before The Battle Interactive Scavenger Hunt.  The objective of this game is to help you look more closely at this painting, in order to understand the importance of many of the paintings elements as well as gain knowledge of the history depicted in the artwork.";
		}
		
		//cycles through what the text in the tutorial says
		function updateText():void
		{
			if(curSlide == 1)
			{
				controls.text = "Welcome to The Night Before The Battle Interactive Scavenger Hunt.  The objective of this game is to help you look more closely at this painting, in order to understand the importance of many of the paintings elements as well as gain knowledge of the history depicted in the artwork.";
			}
			if (curSlide == 2)
			{
				controls.text = "In this games there is a collection of objects for you to discover throughout the painting. Mousing over one of these objects will highlight it, and clicking upon it will open a description.";
			}
			if (curSlide == 3)
			{
				controls.text = "In a few moments you will be given a clue to the first object you need to look for.  When the game begins, click on the little icon above the Clues Menu in the bottom of the game screen to obtain your first clue. By clicking on the correct object that the riddle references, the object will be added to your collection.  You will also be given a brief description of the object, as well as some background on its history and its purpose in the painting.";
			}
			if (curSlide == 4)
			{
				controls.text = "Along with this description, you will be rewarded with a piece of a letter written by one of the soldiers in this painting.  The letter has been torn, and is missing several pieces.  As you solve riddles and uncover objects, you will be given new pieces of the letter until it is whole. Click on the Letter Menu icon to review your progress";  
			}
			if (curSlide == 5)
			{
				controls.text = "The next clue will be given to you when you can identify the object behind this first one. Click Proceed to begin.  Good Luck!";
			}
			controls.setTextFormat(tutText);
		}
		
		//brings you to the next page in the tutorial
		function continueReading(event:MouseEvent):void
		{
			curSlide++;
			addChild(previousButton);			
			if(curSlide >= 5)
			{
				addChild(proceedButton);
				removeChild(continueButton);
			}
			updateText();
		}
		
		//returns you to the previous menu in the tutorial if you wish to read it again
		function previousPage(event:MouseEvent):void
		{
			curSlide--;
			if(curSlide <= 1)
			{
				removeChild(previousButton)						  
			}
			if(contains(proceedButton))
			{
				addChild(continueButton);
				removeChild(proceedButton);
			}
			
			updateText();
		}
		
		
		function createBackground():void
		{
			//Set the background graphics
			theBackground.graphics.lineStyle(1, 0x836A35);
			theBackground.graphics.beginFill(0x2F2720);
			theBackground.graphics.drawRect(0, 0, 764, 572);
			theBackground.graphics.endFill();
		}
	}
}