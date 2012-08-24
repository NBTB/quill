﻿package scripts
{
	import flash.text.TextField;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.display.Shape;
	import flash.display.DisplayObject;
	import flash.text.TextFormat;
	import flash.events.MouseEvent;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.display.Loader;
	import flash.geom.ColorTransform;
	


	public class TutorialMenu extends BaseMenu {

		public var proceedButton:TextField = new TextField();		
		var resumeButton:TextField = new TextField();
		var controls:TextField = new TextField();
		public static var curSlide:Number;
		var theBackground:Shape = new Shape();
		var tutText:TextFormat = new TextFormat();
		var aboutText:TextFormat = new TextFormat();
		var creditsText:TextFormat = new TextFormat();
		var titleText:TextFormat = new TextFormat();
		var buttonFormat:TextFormat = new TextFormat();
		var titleField:TextField = new TextField();
		var magLoader:Loader = new Loader();
		var clueLoader:Loader = new Loader();
		var mouseLoader:Loader = new Loader();
		var mouseOverLoader:Loader = new Loader();
		var lastWasAbout:Boolean = false;
		public static var fromHelp:Boolean=false;
		public static var aboutTextCredits:TextField = new TextField();
		public static var aboutTextBackground:TextField = new TextField();

		public function TutorialMenu(xPos:int, yPos:int, widthVal:int, heightVal:int):void {
			super(xPos, yPos, widthVal, heightVal, true/*false*/, false, false);

			initText();
			loadImages();
			init();
		}

		function init() {

			titleField.setTextFormat(titleText);
			controls.setTextFormat(tutText);
			aboutTextCredits.setTextFormat(creditsText);
			aboutTextBackground.setTextFormat(aboutText);
			controls.selectable=false;			
			aboutTextCredits.selectable = false;
			aboutTextBackground.selectable = false;
			
			titleField.selectable=false;
			addChild(controls);
			addChild(proceedButton);
						
			if (! fromHelp) {
				curSlide=1;
				proceedButton.setTextFormat(buttonFormat);
				proceedButton.selectable=false;
				proceedButton.addEventListener(MouseEvent.ROLL_OVER, colorChange);
				proceedButton.addEventListener(MouseEvent.ROLL_OUT, revertColor);
				
			} else {
				resumeButton.setTextFormat(buttonFormat);
				resumeButton.selectable=false;
				addChild(resumeButton);
				resumeButton.addEventListener(MouseEvent.ROLL_OVER, colorChange);
				resumeButton.addEventListener(MouseEvent.ROLL_OUT, revertColor);				
			}
		}

		function loadImages() {

			var url:URLRequest=new URLRequest(FileFinder.completePath(FileFinder.INTERFACE, "magGlassPoint.png"));

			magLoader.load(url);
			magLoader.scaleX=.6;
			magLoader.scaleY=.6;
			magLoader.x=510;
			magLoader.y=400;

			var url2:URLRequest=new URLRequest(FileFinder.completePath(FileFinder.INTERFACE, "clueBar.png"));

			clueLoader.load(url2);
			clueLoader.scaleX=.6;
			clueLoader.scaleY=.6;
			clueLoader.x=390;
			clueLoader.y=250;

			var url3:URLRequest=new URLRequest(FileFinder.completePath(FileFinder.INTERFACE, "mouseLeftClick.swf"));

			mouseLoader.load(url3);
			mouseLoader.scaleX=.6;
			mouseLoader.scaleY=.6;
			mouseLoader.x=300;
			mouseLoader.y=350;

			var url4:URLRequest=new URLRequest(FileFinder.completePath(FileFinder.INTERFACE, "mouseOver.swf"));

			mouseOverLoader.load(url4);
			mouseOverLoader.scaleX=.8;
			mouseOverLoader.scaleY=.8;
			mouseOverLoader.x=550;
			mouseOverLoader.y=350;
		}

		function initText() {
			buttonFormat.color=0xE5E5E5;
			buttonFormat.font="Gabriola";
			buttonFormat.size=36;

			titleText.color=0xE5E5E5;
			titleText.font="Gabriola";
			titleText.size=46;
			titleText.align = "center";

			tutText.color=0xCC9933;
			tutText.font="Gabriola";
			tutText.size=32;
			tutText.align="center";
			
			aboutText.color=0xCC9933;
			aboutText.font="Gabriola";
			aboutText.size=28;
			aboutText.align="center";
			
			creditsText.color=0xCC9933;
			creditsText.font="Times";
			creditsText.size=20;
			creditsText.align="center";

			titleField.x=320;
			titleField.width=600;
			titleField.text="Controls";

			proceedButton.x=580;
			proceedButton.y=550;
			proceedButton.height=50;
			proceedButton.width=275;
			proceedButton.text="Proceed";
			
			resumeButton.x=470;
			resumeButton.y=550;
			resumeButton.height=50;
			resumeButton.width=275;
			resumeButton.text="Resume Game";

			controls.x = 100;
			controls.y = 100;
			controls.width=1050;
			controls.height=800;
			controls.wordWrap=true;
			controls.text="Welcome to The Night Before The Battle Interactive Scavenger Hunt!  The objective of this game is to help you look more closely at this painting, in order to understand the importance of many of the paintings elements as well as gain knowledge of the history depicted in the artwork. Use your mouse to interact with objects on the canvas.  Hit 'Space' or the little icon in the bottom corner of your screen to toggle the magnifying glass to help you see things more clearly.  Follow the clues to progress through the scavenger hunt. Good Luck!";
		
			aboutTextCredits.x = 700;
			aboutTextCredits.y = 115;
			aboutTextCredits.width = 525;
			aboutTextCredits.height = 800;
			aboutTextCredits.wordWrap = true;
			
			aboutTextBackground.x = 75;
			aboutTextBackground.y = 100;
			aboutTextBackground.width = 600;
			aboutTextBackground.height = 800;
			aboutTextBackground.wordWrap = true;
		}

		//gets the information for the about page after it has been read in
		public static function getAbout(about:String, whichNum:int):void
		{
			//Read in from credits
			if(whichNum == 1)
			{
				aboutTextCredits.text = about;
			}
			//Read in from about
			if(whichNum == 2)
			{
				aboutTextBackground.text = about;
			}
		}

		//cycles through what the text in the tutorial says
		function updateText():void {
			//if an image is a child, and is not supposed to be seen in that page, remove it
			if (contains(magLoader)) {
				removeChild(magLoader);
			}
			if (contains(clueLoader)) {
				removeChild(clueLoader);
			}
			if (contains(mouseLoader)) {
				removeChild(mouseLoader);
			}
			if (contains(mouseOverLoader)) {
				removeChild(mouseOverLoader);
			}
			if (contains(titleField)) {
				removeChild(titleField);
			}
			
			//Make sure the right textFields are displayed
			if(curSlide == 7)
			{
				if(!lastWasAbout)
				{
					removeChild(controls);
					addChild(aboutTextBackground)
					addChild(aboutTextCredits)
				}
				
			}
			else
			{
				if(lastWasAbout)
				{
					addChild(controls);
					removeChild(aboutTextBackground)
					removeChild(aboutTextCredits)
					lastWasAbout = false;
				}
			}
			
			//change the text depending on what slide you are on. Add images if necessary on that slide
			if (curSlide==1) {
				controls.text="Welcome to The Night Before The Battle Interactive Scavenger Hunt!  The objective of this game is to help you look more closely at this painting, in order to understand the importance of many of the paintings elements as well as gain knowledge of the history depicted in the artwork. Use your mouse to interact with objects on the canvas.  Hit 'Space' or the little icon in the bottom corner of your screen to toggle the magnifying glass to help you see things more clearly";
				
			}
			//help menu:Objectives
			if (curSlide==2) {
				controls.text="The objective of this game is to help you look more closely at this painting, in order to understand the importance of many of the paintings elements as well as gain knowledge of the history depicted in the artwork. Hit 'Space' or the little icon in the bottom corner of your screen to toggle the magnifying glass to help you see things more clearly.";
				titleField.text="Objectives";
				titleField.setTextFormat(titleText);
				addChild(magLoader);
				addChild(titleField);
			}
			//help menu:Clues
			if (curSlide==3) {
				controls.text="At the top of the screen is your clue bar.  This riddle points to a certain object on the screen.  Correctly solving the riddle will unlock the next clue to be displayed here.";
				titleField.text="Clues";
				titleField.setTextFormat(titleText);
				addChild(clueLoader);
				addChild(titleField);
			}	
			//help menu:Objects
			if(curSlide==4) {
				controls.text = "Many objects important to the painting are scattered acrossed the canvas.  You will know when you've found one because the object will become highlighted. Double Clicking on an object will open a description panel about the object, providing some background on the objects history and its relevance in the painting. It will then be sent to the objects menu where you can review this and other objects you have discovered";
				titleField.text="Objects";
				titleField.setTextFormat(titleText);
				addChild(mouseLoader);
				addChild(mouseOverLoader);
				addChild(titleField);
			}
			//help menu:Letter
			if (curSlide==5) {
				controls.text="As you progress, you will be rewarded with a piece of a letter written by one of the soldiers in this painting.  The letter has been torn, and is missing several pieces.  The panel to the right of the main screen shows you your progress. As you solve riddles and uncover objects, you will be given new pieces of the letter until it is whole.";
				titleField.text="Letter";
				titleField.setTextFormat(titleText);
				addChild(titleField);
			}
			//help menu:Controls
			if (curSlide==6) {
				controls.text="Single Left Click: Select\nDouble Left Click (on objects of interest only): Open Object Info Panel\nSpace: Toggle Magnifying glass";
				titleField.text="Controls";
				titleField.setTextFormat(titleText);
				addChild(titleField);
			}
			
			//help menu:Controls
			if (curSlide==7) {
				titleField.text="About the Night Before the Battle Puzzle";
				titleField.setTextFormat(titleText);
				addChild(titleField);
				lastWasAbout = true;
			}
						
			//reset the text format
			controls.setTextFormat(tutText);
		}		
		
	}
}