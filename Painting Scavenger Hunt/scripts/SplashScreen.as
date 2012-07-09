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
	
	public class SplashScreen extends MovieClip
	{
		var theBackground:Shape = new Shape();
		var splashTitle:TextField = new TextField();
		
		var startGameListener:MenuListener;
		var useTut:Boolean;
		var gameReady:Boolean = false;
				
		var splashButtonStart:TextField = new TextField();
		var splashButtonAbout:TextField = new TextField();
		var splashButtonCredits:TextField = new TextField();
		var splashButtonTitle:TextField = new TextField();
		var splashButtonTutorial:TextField = new TextField();
		var splashButtonSkip:TextField = new TextField();
		
		var splashTitleFormat:TextFormat = new TextFormat();
		var splashButtonFormat:TextFormat = new TextFormat();
		
		var buttonX:int = 185;
		var buttonSeparation = 75;
		var buttonY1:int = 165;
		var buttonY2:int = buttonY1+buttonSeparation;
		var buttonY3:int = buttonY2+buttonSeparation;
		
		
		public function SplashScreen(theTrigger:MenuListener) 
		{
			startGameListener = theTrigger;
			
			this.addChild(theBackground);
			this.addChild(splashTitle);
			this.addChild(splashButtonStart);
			this.addChild(splashButtonAbout);
			this.addChild(splashButtonCredits);
			this.addChild(splashButtonTitle);
			this.addChild(splashButtonTutorial);
			this.addChild(splashButtonSkip);
			
			formatText();
			mainSplashActivate();
			createBackground();	
			
			splashTitle.setTextFormat(splashTitleFormat);
			splashButtonStart.setTextFormat(splashButtonFormat);
			splashButtonAbout.setTextFormat(splashButtonFormat);
			splashButtonCredits.setTextFormat(splashButtonFormat);
			splashButtonTitle.setTextFormat(splashButtonFormat);
			splashButtonTutorial.setTextFormat(splashButtonFormat);
			splashButtonSkip.setTextFormat(splashButtonFormat);
			
			splashButtonStart.addEventListener(MouseEvent.MOUSE_DOWN, tutorialStart);
			splashButtonAbout.addEventListener(MouseEvent.MOUSE_DOWN, aboutInfo);
			splashButtonCredits.addEventListener(MouseEvent.MOUSE_DOWN, creditsInfo);
			splashButtonTitle.addEventListener(MouseEvent.MOUSE_DOWN, mainSplash);
			splashButtonTutorial.addEventListener(MouseEvent.MOUSE_DOWN, startWithTut);
			splashButtonSkip.addEventListener(MouseEvent.MOUSE_DOWN, startNoTut);
		}
		
		function startWithTut(event:MouseEvent):void
		{
			useTut = true;
			gameReady = true;
			startGameListener.triggerListener();
		}
		
		function startNoTut(event:MouseEvent):void
		{
			useTut = false;
			gameReady = true;
			startGameListener.triggerListener();
		}
		
		function formatText():void
		{
			splashTitleFormat.align = "center";
			splashTitleFormat.color = 0xCC9933;
			splashTitleFormat.font = "Gabriola";
			splashTitleFormat.size = 44;
			
			splashTitle.wordWrap = true;
			splashTitle.selectable = false;
			splashTitle.x = 60;
			splashTitle.y = 10;
			splashTitle.height = 168;
			splashTitle.width = 425;
			
			splashButtonFormat.align = "center";
			splashButtonFormat.color = 0xE5E5E5;
			splashButtonFormat.font = "Gabriola";
			splashButtonFormat.size = 36;
			
			splashButtonStart.x = buttonX;
			splashButtonStart.y = buttonY1;
			splashButtonStart.height = 50;
			splashButtonStart.width = 175;
			splashButtonStart.text = "Start Game";
			
			splashButtonAbout.x = buttonX;
			splashButtonAbout.y = buttonY2;
			splashButtonAbout.height = 50;
			splashButtonAbout.width = 175;
			splashButtonAbout.text = "About";
			
			splashButtonCredits.x = buttonX;
			splashButtonCredits.y = buttonY3;
			splashButtonCredits.height = 50;
			splashButtonCredits.width = 175;
			splashButtonCredits.text = "Credits";
			
			splashButtonTitle.x = buttonX;
			splashButtonTitle.y = buttonY3;
			splashButtonTitle.height = 50;
			splashButtonTitle.width = 175;
			splashButtonTitle.text = "Main Page";
			
			splashButtonTutorial.x = buttonX;
			splashButtonTutorial.y = buttonY1;
			splashButtonTutorial.height = 50;
			splashButtonTutorial.width = 175;
			splashButtonTutorial.text = "View Tutorial";
			
			splashButtonSkip.x = buttonX;
			splashButtonSkip.y = buttonY2;
			splashButtonSkip.height = 50;
			splashButtonSkip.width = 175;
			splashButtonSkip.text = "Skip Tutorial";
		}
		
		//Display the main splash page
		function mainSplash(event:MouseEvent):void
		{
			mainSplashActivate();
		}
		
		function mainSplashActivate():void
		{
			splashTitle.text = "The Night Before the Battle Scavenger Hunt";
			
			splashButtonAbout.visible = true;
			splashButtonCredits.visible = true;
			splashButtonStart.visible = true;
			
			splashButtonTitle.visible = false;
			splashButtonTutorial.visible = false;
			splashButtonSkip.visible = false;
		}
		
		//Display the credits page		
		function creditsInfo(event:MouseEvent):void
		{
			splashButtonTitle.visible = true;
			
			splashButtonAbout.visible = false;
			splashButtonCredits.visible = false;
			splashButtonStart.visible = false;
			splashButtonTutorial.visible = false;
			splashButtonSkip.visible = false;
		}

		//Display the about page
   		function aboutInfo(event:MouseEvent):void
		{
			splashButtonTitle.visible = true;
			
			splashButtonAbout.visible = false;
			splashButtonCredits.visible = false;
			splashButtonStart.visible = false;
			splashButtonTutorial.visible = false;
			splashButtonSkip.visible = false;
		}
		
		//Display the page asking whether the user wants to use the tutorial or not
		function tutorialStart(event:MouseEvent):void
		{
			splashButtonTutorial.visible = true;
			splashButtonSkip.visible = true;
			
			splashButtonTitle.visible = false;
			splashButtonAbout.visible = false;
			splashButtonCredits.visible = false;
			splashButtonStart.visible = false;
		}
		
		
		//Set the background graphics
		function createBackground():void
		{
			theBackground.graphics.lineStyle(1, 0x836A35);
			theBackground.graphics.beginFill(0x2F2720);
			theBackground.graphics.drawRect(0, 0, 579.5, 434.5);
			theBackground.graphics.endFill();
		}
	}
}