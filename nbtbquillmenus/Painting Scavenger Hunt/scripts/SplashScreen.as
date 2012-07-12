﻿package
{
	import flash.text.TextField;
	import flash.display.Shape;
	import flash.display.DisplayObject;
	import flash.text.TextFormat;
	import flash.events.MouseEvent;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
//TODO: Add code to read in the About and Credit page information
//TODO: Try to find a way to have the title keep its formatting, without having to constantly reset it

	public class SplashScreen extends MovieClip
	{
		var theBackground:Shape = new Shape();
		var splashTitle:TextField = new TextField();
		
		var startGameListener:MenuListener;
		var useTut:Boolean;
		var gameReady:Boolean = false;
		var firstStart:Boolean = true;
				
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
			splashTitle.setTextFormat(splashTitleFormat);
			splashButtonStart.setTextFormat(splashButtonFormat);
			splashButtonAbout.setTextFormat(splashButtonFormat);
			splashButtonCredits.setTextFormat(splashButtonFormat);
			splashButtonTitle.setTextFormat(splashButtonFormat);
			splashButtonTutorial.setTextFormat(splashButtonFormat);
			splashButtonSkip.setTextFormat(splashButtonFormat);
			
			//Event listeners for the different buttons in the project.
			splashButtonStart.addEventListener(MouseEvent.MOUSE_DOWN, tutorialStart);
			splashButtonAbout.addEventListener(MouseEvent.MOUSE_DOWN, aboutInfo);
			splashButtonCredits.addEventListener(MouseEvent.MOUSE_DOWN, creditsInfo);
			splashButtonTitle.addEventListener(MouseEvent.MOUSE_DOWN, mainSplash);
			splashButtonTutorial.addEventListener(MouseEvent.MOUSE_DOWN, startWithTut);
			splashButtonSkip.addEventListener(MouseEvent.MOUSE_DOWN, startNoTut);
		}
		
		function startWithTut(event:MouseEvent):void
		{
			//Function chosen if the user chooses to view the tutorial
			useTut = true;
			gameReady = true;
			startGameListener.triggerListener();
		}
		
		function startNoTut(event:MouseEvent):void
		{
			//Function chosen if the user chooses not to view the tutorial
			useTut = false;
			gameReady = true;
			startGameListener.triggerListener();
		}
		
		function formatText():void
		{
			//Details regarding the title
			splashTitleFormat.align = "center";
			splashTitleFormat.color = 0xCC9933;
			splashTitleFormat.font = "Gabriola";
			splashTitleFormat.size = 44;
			
			//More details regarding the title
			splashTitle.wordWrap = true;
			splashTitle.selectable = false;
			splashTitle.x = 60;
			splashTitle.y = 10;
			splashTitle.height = 168;
			splashTitle.width = 425;
			
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
			
			//Details of the view tutorial button
			splashButtonTutorial.x = buttonX;
			splashButtonTutorial.y = buttonY1;
			splashButtonTutorial.height = 50;
			splashButtonTutorial.width = 175;
			splashButtonTutorial.text = "View Tutorial";
			
			//Details of the skip tutorial button
			splashButtonSkip.x = buttonX;
			splashButtonSkip.y = buttonY2;
			splashButtonSkip.height = 50;
			splashButtonSkip.width = 175;
			splashButtonSkip.text = "Skip Tutorial";
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
			}
			
			//No longer the first time on page...
			firstStart = false;
		}
		
		function creditsInfo(event:MouseEvent):void
		{
			//Set which code buttons are visible or not on the credits part of the splash page
			addChild(splashButtonTitle);
			removeChild(splashButtonAbout);
			removeChild(splashButtonCredits);
			removeChild(splashButtonStart);
			
			//Set the title for the credits page, and make sure formatting stays correct
			splashTitle.text = "The Night Before the Battle Scavenger Hunt";
			splashTitle.setTextFormat(splashTitleFormat);
		}

   		function aboutInfo(event:MouseEvent):void
		{
			//Set which code buttons are visible or not on the about part of the splash page
			addChild(splashButtonTitle);
			removeChild(splashButtonAbout);
			removeChild(splashButtonCredits);
			removeChild(splashButtonStart);
			
			//Set the title for the about page, and make sure formatting stays correct
			splashTitle.text = "The Night Before the Battle Scavenger Hunt";
			splashTitle.setTextFormat(splashTitleFormat);
		}
		
		//Display the page asking whether the user wants to use the tutorial or not
		function tutorialStart(event:MouseEvent):void
		{
			//Set the title for the tutorial page, and make sure formatting stays correct
			splashTitle.text = "The Night Before the Battle Scavenger Hunt";
			splashTitle.setTextFormat(splashTitleFormat);
			
			//Set which code buttons are visible or not on the tutorial inquisition part of the splash page
			addChild(splashButtonTutorial);
			addChild(splashButtonSkip);
			removeChild(splashButtonAbout);
			removeChild(splashButtonCredits);
			removeChild(splashButtonStart);
		}
		
		
		function createBackground():void
		{
			//Set the background graphics
			theBackground.graphics.lineStyle(1, 0x836A35);
			theBackground.graphics.beginFill(0x2F2720);
			theBackground.graphics.drawRect(0, 0, 579.5, 434.5);
			theBackground.graphics.endFill();
		}
	}
}