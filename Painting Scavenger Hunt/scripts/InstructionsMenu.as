﻿package scripts
{
	import flash.display.*;
	import flash.events.*;
	import flash.text.*
	import flash.net.*
	import flash.geom.ColorTransform;
	


	public class InstructionsMenu extends BaseMenu {

		var resumeButton:TextField = new TextField();
		var instructions:TextField = new TextField();
		var curSlide:Number;
		var theBackground:Shape = new Shape();
		var tutText:TextFormat = new TextFormat();
		var titleText:TextFormat = new TextFormat();
		var buttonFormat:TextFormat = new TextFormat();
		var titleField:TextField = new TextField();
		var magLoader:Loader = new Loader();
		var clueLoader:Loader = new Loader();
		var mouseLoader:Loader = new Loader();
		var mouseOverLoader:Loader = new Loader();
		public static var about:String = null;
		public static var credits:String = null;

		public function InstructionsMenu(xPos:int, yPos:int, widthVal:int, heightVal:int):void {
			super(xPos, yPos, widthVal, heightVal, false, false, false);

			init();
			initText();
			loadImages();
			
		}

		function init() {

			titleField.setTextFormat(titleText);
			instructions.setTextFormat(tutText);
			instructions.selectable=false;			
			
			titleField.selectable=false;
			addContent(titleField);
			addContent(instructions);
			addContent(resumeButton);
			
			titleField.defaultTextFormat = BaseMenu.titleFormat;
			instructions.defaultTextFormat = BaseMenu.bodyFormat;
			resumeButton.defaultTextFormat = BaseMenu.textButtonFormat;
			
			
			instructions.setTextFormat(tutText);
			
			curSlide=1;
			resumeButton.setTextFormat(buttonFormat);
			resumeButton.selectable=false;
			resumeButton.addEventListener(MouseEvent.ROLL_OVER, colorChange);
			resumeButton.addEventListener(MouseEvent.ROLL_OUT, revertColor);
		}

		function loadImages() {

			var url:URLRequest=new URLRequest(FileFinder.completePath(FileFinder.INTERFACE, "magGlassPoint.png"));

			magLoader.load(url);
			magLoader.scaleX=.6;
			magLoader.scaleY=.6;
			magLoader.x=170;
			magLoader.y=260;

			var url2:URLRequest=new URLRequest(FileFinder.completePath(FileFinder.INTERFACE, "clueBar.png"));

			clueLoader.load(url2);
			clueLoader.scaleX=.6;
			clueLoader.scaleY=.6;
			clueLoader.x=95;
			clueLoader.y=150;

			var url3:URLRequest=new URLRequest(FileFinder.completePath(FileFinder.INTERFACE, "mouseLeftClick.swf"));

			mouseLoader.load(url3);
			mouseLoader.scaleX=.6;
			mouseLoader.scaleY=.6;
			mouseLoader.x=130;
			mouseLoader.y=251;

			var url4:URLRequest=new URLRequest(FileFinder.completePath(FileFinder.INTERFACE, "mouseOver.swf"));

			mouseOverLoader.load(url4);
			mouseOverLoader.scaleX=.8;
			mouseOverLoader.scaleY=.8;
			mouseOverLoader.x=180;
			mouseOverLoader.y=250;
		}

		function initText() {

			titleField.x=10;
			titleField.y=10
			titleField.width=width - (titleField.x * 2);
			titleField.autoSize = TextFieldAutoSize.CENTER;
			

			resumeButton.text="Resume Game";
			resumeButton.autoSize = TextFieldAutoSize.CENTER;
			resumeButton.x=(width / 2) - (resumeButton.width / 2);
			resumeButton.y=height-resumeButton.height - 10;			

			instructions.x=10
			instructions.y=titleField.y + titleField.height + 50 ;
			instructions.width=width - (instructions.x * 2);
			instructions.autoSize = TextFieldAutoSize.LEFT;
			instructions.wordWrap=true;
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
			//change the text depending on what slide you are on. Add images if necessary on that slide
			if (curSlide==1) {
				titleField.text = "Welcome";
				instructions.text="Welcome to The Night Before The Battle Interactive Scavenger Hunt!  The objective of this game is to help you look more closely at this painting, in order to understand the importance of many of the paintings elements as well as gain knowledge of the history depicted in the artwork. Use your mouse to interact with objects on the canvas.  Hit 'Space' or the little icon in the bottom corner of your screen to toggle the magnifying glass to help you see things more clearly";
			}
			//help menu:Objective
			else if (curSlide==2) {
				titleField.text = "Objective";
				instructions.text="The objective of this game is to help you look more closely at this painting, in order to understand the importance of many of the paintings elements as well as gain knowledge of the history depicted in the artwork. Use the spacebar or the little icon in the right corner of the menu bar to toggle the magnifying glass and see things more clearly.";
				//addChild(magLoader);
			}
			//help menu:Clues
			else if (curSlide==3) {
				titleField.text = "Clues";
				instructions.text="At the top of the screen is your clue bar.  This riddle points to a certain object on the screen.  Correctly solving the riddle will unlock the next clue to be displayed here.";
				addChild(clueLoader);
			}	
			//help menu:Objects
			else if(curSlide==4) {
				titleField.text = "Objects";
				instructions.text = "Many objects important to the painting are scattered acrossed the canvas.  You will know when you've found one because the object will become highlighted. Double Clicking on an object will open a description panel about the object, providing some background on the objects history and its relevance in the painting. It will then be sent to the objects menu where you can review this and other objects you have discovered";
				addChild(mouseLoader);
				addChild(mouseOverLoader);
			}
			//help menu:Letter
			else if (curSlide==5) {
				titleField.text = "Letter";
				instructions.text="As you progress, you will be rewarded with a piece of a letter written by one of the soldiers in this painting.  The letter has been torn, and is missing several pieces.  The panel to the right of the main screen shows you your progress. As you solve riddles and uncover objects, you will be given new pieces of the letter until it is whole.";
				
			}
			//help menu:Controls
			else if (curSlide==6) {
				titleField.text = "Controls";
				instructions.text="Single Left Click: Select\nDouble Left Click (painting only): Open Object Info Panel\nSpace: Toggle Magnifying glass";
			}
			
			//help menu:about
			else if (curSlide==7) {
				titleField.text="About the Night Before the Battle Puzzle";
				instructions.text = about;
			}
			
			//help menu:credits
			else if (curSlide==8) {
				titleField.text="Credits";
				instructions.text = credits;
			}
		}		
	}
}