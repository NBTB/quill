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
	import flash.geom.ColorTransform;
	
//TODO: Add code to read in the About and Credit page information
//TODO: Try to find a way to have the title keep its formatting, without having to constantly reset it

	public class SplashScreen extends MovieClip
	{
		var theBackground:Shape = new Shape();
		var splashTitle:TextField = new TextField();
		var tut:TutorialMenu;
		
		var startGameListener:MenuListener;
		var useTut:Boolean;
		var gameReady:Boolean = false;
		var firstStart:Boolean = true;
				
		var splashButtonStart:TextField = new TextField();
		var splashButtonAbout:TextField = new TextField();
		var splashButtonCredits:TextField = new TextField();
		var splashButtonTitle:TextField = new TextField();
				
		var splashTitleFormat:TextFormat = new TextFormat();
		var splashButtonFormat:TextFormat = new TextFormat();
		var infoTextFormat:TextFormat = new TextFormat();
		
		var buttonX:int = 535;
		var buttonSeparation = 75;
		var buttonY1:int = 265;
		var buttonY2:int = buttonY1+buttonSeparation;
		var buttonY3:int = buttonY2+buttonSeparation;
				
		var aboutText:TextField = new TextField();
		var creditsText:TextField = new TextField();
		
		var whichChild:String = "";

		var myArrayListeners:Array=[];								//Array of Event Listeners in BaseMenu
		
		public function SplashScreen(theTrigger:MenuListener) 
		{
			//Copy of the MenuListener, to be triggered at start of game.
			startGameListener = theTrigger;
			
			//Add the elements of the SplashScreen to the game.
			this.addChild(theBackground);
			this.addChild(splashTitle);
			
			//Run starting functions to show screen correctly.
			formatText();
			mainSplashActivate();
			createBackground();	
			
			//Make sure all the elements have their text formatted correctly.
			splashButtonStart.setTextFormat(splashButtonFormat);
			splashButtonAbout.setTextFormat(splashButtonFormat);
			splashButtonCredits.setTextFormat(splashButtonFormat);
			splashButtonTitle.setTextFormat(splashButtonFormat);
						
			//make the buttons so the text cursor doesn't appear over them
			splashTitle.selectable = false;
			splashButtonStart.selectable = false;
			splashButtonAbout.selectable = false;
			splashButtonCredits.selectable = false;
			splashButtonTitle.selectable = false;
						
			//Event listeners for the different buttons in the project.
			splashButtonStart.addEventListener(MouseEvent.MOUSE_DOWN, startWithTut);
			splashButtonAbout.addEventListener(MouseEvent.MOUSE_DOWN, aboutInfo);
			splashButtonCredits.addEventListener(MouseEvent.MOUSE_DOWN, creditsInfo);
			splashButtonTitle.addEventListener(MouseEvent.MOUSE_DOWN, mainSplash);
						
			splashButtonStart.addEventListener(MouseEvent.ROLL_OVER, colorChange);
			splashButtonStart.addEventListener(MouseEvent.ROLL_OUT, revertColor);
			splashButtonAbout.addEventListener(MouseEvent.ROLL_OVER, colorChange);
			splashButtonAbout.addEventListener(MouseEvent.ROLL_OUT, revertColor);
			splashButtonCredits.addEventListener(MouseEvent.ROLL_OVER, colorChange);
			splashButtonCredits.addEventListener(MouseEvent.ROLL_OUT, revertColor);
			splashButtonTitle.addEventListener(MouseEvent.ROLL_OVER, colorChange);
			splashButtonTitle.addEventListener(MouseEvent.ROLL_OUT, revertColor);
		}
		
		function startWithTut(event:MouseEvent):void
		{
			//Function chosen if the user chooses to view the tutorial
			useTut = true;
			gameReady = true;
			removeChild(splashTitle);
			removeChild(splashButtonAbout);
			removeChild(splashButtonCredits);
			removeChild(splashButtonStart);									
			tut = new TutorialMenu(0,0, stage.stageWidth, stage.stageHeight);
			addChild(tut);
			tut.proceedButton.addEventListener(MouseEvent.MOUSE_DOWN,proceedFromTut);
		}	
		
		function proceedFromTut(event:MouseEvent):void
		{			
			tut.proceedButton.removeEventListener(MouseEvent.MOUSE_DOWN, proceedFromTut);
			startGameListener.triggerListener();
		}	
		
		
		function getAboutText(theAboutText:String):void
		{
			aboutText.text = theAboutText;
		}
		
		function getCreditsText(theCreditsText:String):void
		{
			creditsText.text = theCreditsText;
		}
		
		function formatText():void
		{
			//Details regarding the title
			splashTitleFormat.align = "center";
			splashTitleFormat.color = 0xCC9933;
			splashTitleFormat.font = "Gabriola";
			splashTitleFormat.size = 44;
			
			//Formatting for the credits and about info
			infoTextFormat.align = "center";
			infoTextFormat.color = 0xCC9933;
			infoTextFormat.font = "Gabriola";
			infoTextFormat.size = 18;
			
			//More details regarding the title
			splashTitle.wordWrap = true;
			splashTitle.selectable = false;
			splashTitle.x = 410;
			splashTitle.y = 70;
			splashTitle.height = 168;
			splashTitle.width = 425;
			
			creditsText.wordWrap = true;
			creditsText.selectable = false;
			creditsText.x = 410;
			creditsText.y = 250;
			creditsText.height = 180;
			creditsText.width = 425;
			
			aboutText.wordWrap = true;
			aboutText.selectable = false;
			aboutText.x = 410;
			aboutText.y = 250;
			aboutText.height = 180;
			aboutText.width = 425;
			
			//Details which apply to all of the buttons
			splashButtonFormat.align = "center";
			splashButtonFormat.color = 0xE5E5E5;
			splashButtonFormat.font = "Gabriola";
			splashButtonFormat.size = 36;
			
			//Details of the start game button
			splashButtonStart.x = buttonX;
			splashButtonStart.y = buttonY1;
			splashButtonStart.height = 50;
			splashButtonStart.width = 175;
			splashButtonStart.text = "Start Game";
			
			//Details of the about button
			splashButtonAbout.x = buttonX;
			splashButtonAbout.y = buttonY2;
			splashButtonAbout.height = 50;
			splashButtonAbout.width = 175;
			splashButtonAbout.text = "About";
			
			//Details of the credits button
			splashButtonCredits.x = buttonX;
			splashButtonCredits.y = buttonY3;
			splashButtonCredits.height = 50;
			splashButtonCredits.width = 175;
			splashButtonCredits.text = "Credits";
			
			//Details of the main page button
			splashButtonTitle.x = buttonX;
			splashButtonTitle.y = buttonY3;
			splashButtonTitle.height = 50;
			splashButtonTitle.width = 175;
			splashButtonTitle.text = "Main Page";			
			
		}
		
		//changes the text color of the menu buttons to identify which one you're moused over
		public function colorChange(event:MouseEvent):void {
			var sender:TextField=event.target as TextField;
			var myColor:ColorTransform=sender.transform.colorTransform;
			myColor.color=0xCC9933;
			sender.transform.colorTransform=myColor;

		}
		
		//reverts the buttons back to their original colors
		public function revertColor(event:MouseEvent):void {
			var sender:TextField=event.target as TextField;
			var myColor:ColorTransform=sender.transform.colorTransform;	
			myColor.color=0xE5E5E5;		
			sender.transform.colorTransform=myColor;
		}
		
		function mainSplash(event:MouseEvent):void
		{
			//Display the main splash page; secondary function with a mouse listener, since both are used.
			mainSplashActivate();
		}
		
		function mainSplashActivate():void
		{
			//Set the title for the main splash page, and make sure formatting stays correct
			splashTitle.text = "The Night Before the Battle Scavenger Hunt";
			splashTitle.setTextFormat(splashTitleFormat);
			
			//Set which buttons are visible or not on the main splash page
			this.addChild(splashButtonAbout);
			this.addChild(splashButtonCredits);

			this.addChild(splashButtonStart);
			//Only remove child if it's coming from a page where it has been added.
			if (firstStart != true)
			{
				this.removeChild(splashButtonTitle);
				
				if (whichChild == "credits")
				{
					this.removeChild(creditsText);
				}
				if (whichChild == "about")
				{
					this.removeChild(aboutText);
				}
			}
			
			
			//No longer the first time on page...
			firstStart = false;
		}
		
		function creditsInfo(event:MouseEvent):void
		{
			//Set which code buttons are visible or not on the credits part of the splash page
			addChild(splashButtonTitle);
			addChild(creditsText);
			removeChild(splashButtonAbout);
			removeChild(splashButtonCredits);
			removeChild(splashButtonStart);
			
			whichChild = "credits";
			
			//Set the title for the credits page, and make sure formatting stays correct
			splashTitle.text = "The Night Before the Battle Scavenger Hunt";
			splashTitle.setTextFormat(splashTitleFormat);
			creditsText.setTextFormat(infoTextFormat);
		}

   		function aboutInfo(event:MouseEvent):void
		{
			//Set which code buttons are visible or not on the about part of the splash page
			addChild(splashButtonTitle);
			addChild(aboutText);
			removeChild(splashButtonAbout);
			removeChild(splashButtonCredits);
			removeChild(splashButtonStart);
			
			whichChild = "about";
			
			//Set the title for the about page, and make sure formatting stays correct
			splashTitle.text = "The Night Before the Battle Scavenger Hunt";
			splashTitle.setTextFormat(splashTitleFormat);
			aboutText.setTextFormat(infoTextFormat);
		}
		
		function createBackground():void
		{			
			//Set the background graphics
			theBackground.graphics.lineStyle(1, 0x836A35);
			theBackground.graphics.beginFill(BaseMenu.menuColor);
			theBackground.graphics.drawRect(0, 0, 1264, 627);
			theBackground.graphics.endFill();
		}
		
		override public function addEventListener (type:String, listener:Function, useCapture:Boolean=false, priority:int=0, useWeakReference:Boolean=false):void 
		{ 
			super.addEventListener (type, listener, useCapture, priority, useWeakReference);
			myArrayListeners.push({type:type, listener:listener, useCapture:useCapture});
		}
		
		function clearEvents():void 
		{
			for (var i:Number=0; i < myArrayListeners.length; i++) 
			{
				if (this.hasEventListener(myArrayListeners[i].type)) 
				{
					this.removeEventListener(myArrayListeners[i].type, myArrayListeners[i].listener);
				}
			}
			myArrayListeners=null;
		}
	}
}