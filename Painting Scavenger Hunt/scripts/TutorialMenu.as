﻿package
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
		var continueButton:TextField = new TextField();
		var previousButton:TextField = new TextField();
		var resumeButton:TextField = new TextField();
		var controls:TextField = new TextField();
		public static var curSlide:Number;
		var theBackground:Shape = new Shape();
		var tutText:TextFormat = new TextFormat();
		var titleText:TextFormat = new TextFormat();
		var buttonFormat:TextFormat = new TextFormat();
		var titleField:TextField = new TextField();
		var letterLoader:Loader = new Loader();
		var clueLoader:Loader = new Loader();
		var mouseLoader:Loader = new Loader();
		var mouseOverLoader:Loader = new Loader();
		public static var fromHelp:Boolean=false;

		public function TutorialMenu(xPos:int, yPos:int, widthVal:int, heightVal:int):void {
			super(xPos, yPos, widthVal, heightVal);

			initText();
			loadImages();
			init();
		}

		function init() {

			titleField.setTextFormat(titleText);
			continueButton.setTextFormat(buttonFormat);
			previousButton.setTextFormat(buttonFormat);
			controls.setTextFormat(tutText);
			controls.selectable=false;
			continueButton.selectable=false;
			previousButton.selectable=false;
			titleField.selectable=false;
			addChild(controls);
			addChild(continueButton);
			continueButton.addEventListener(MouseEvent.MOUSE_DOWN,continueReading);
			previousButton.addEventListener(MouseEvent.MOUSE_DOWN,previousPage);
			continueButton.addEventListener(MouseEvent.ROLL_OVER, colorChange);
			continueButton.addEventListener(MouseEvent.ROLL_OUT, revertColor);
			previousButton.addEventListener(MouseEvent.ROLL_OVER, colorChange);
			previousButton.addEventListener(MouseEvent.ROLL_OUT, revertColor);
			
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

			var url:URLRequest=new URLRequest("../assets/interface/letterTutImage.png");

			letterLoader.load(url);
			letterLoader.scaleX=.8;
			letterLoader.scaleY=.8;
			letterLoader.x=90;
			letterLoader.y=300;

			var url2:URLRequest=new URLRequest("../assets/interface/clueTutImage.png");

			clueLoader.load(url2);
			clueLoader.scaleX=.8;
			clueLoader.scaleY=.8;
			clueLoader.x=90;
			clueLoader.y=350;

			var url3:URLRequest=new URLRequest("../assets/interface/mouseLeftClick.swf");

			mouseLoader.load(url3);
			mouseLoader.scaleX=.6;
			mouseLoader.scaleY=.6;
			mouseLoader.x=50;
			mouseLoader.y=250;

			var url4:URLRequest=new URLRequest("../assets/interface/mouseOver.swf");

			mouseOverLoader.load(url4);
			mouseOverLoader.scaleX=.8;
			mouseOverLoader.scaleY=.8;
			mouseOverLoader.x=300;
			mouseOverLoader.y=250;


		}

		function initText() {
			buttonFormat.color=0xE5E5E5;
			buttonFormat.font="Gabriola";
			buttonFormat.size=36;

			titleText.color=0xE5E5E5;
			titleText.font="Gabriola";
			titleText.size=46;

			tutText.color=0xCC9933;
			tutText.font="Gabriola";
			tutText.size=32;
			tutText.align="center";

			titleField.x=300;
			titleField.width=300;
			titleField.text="Controls";

			proceedButton.x=630;
			proceedButton.y=500;
			proceedButton.height=50;
			proceedButton.width=275;
			proceedButton.text="Proceed";
			continueButton.x=630;
			continueButton.y=500;
			continueButton.height=50;
			continueButton.width=275;
			continueButton.text="Continue";
			previousButton.x=0;
			previousButton.y=500;
			previousButton.height=50;
			previousButton.width=275;
			previousButton.text="Previous";

			resumeButton.x=315;
			resumeButton.y=500;
			resumeButton.height=50;
			resumeButton.width=275;
			resumeButton.text="Resume Game";

			controls.width=750;
			controls.height=800;
			controls.wordWrap=true;
			controls.text="Welcome to The Night Before The Battle Interactive Scavenger Hunt.  The objective of this game is to help you look more closely at this painting, in order to understand the importance of many of the paintings elements as well as gain knowledge of the history depicted in the artwork.";

		}



		//cycles through what the text in the tutorial says
		function updateText():void {
			//if an image is a child, and is not supposed to be seen in that page, remove it
			if (contains(letterLoader)) {
				removeChild(letterLoader);
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
			//change the text depending on what slide you are on. Add images if necessary on that slide
			if (curSlide==1) {
				controls.text="Welcome to The Night Before The Battle Interactive Scavenger Hunt.  The objective of this game is to help you look more closely at this painting, in order to understand the importance of many of the paintings elements as well as gain knowledge of the history depicted in the artwork.";
			}
			if (curSlide==2) {
				controls.text="In this games there is a collection of objects for you to discover throughout the painting. Mousing over one of these objects will highlight it, and clicking upon it will open a description. A magnifying glass is available to help you see objects more clearly. Hit space to toggle this function on and off, or click the magnifying glass icon in the bottom right of the screen.";
				addChild(mouseLoader);
				addChild(mouseOverLoader);
			}
			if (curSlide==3) {
				controls.text="In a few moments you will be given a clue to the first object you need to look for.  When the game begins, click on the little icon above the Clues Menu in the bottom of the game screen to obtain your first clue. By clicking on the correct object that the riddle references, the object will be added to your collection.  You will also be given a brief description of the object, as well as some background on its history and its purpose in the painting.";
				addChild(clueLoader);
			}
			if (curSlide==4) {
				controls.text="Along with this description, you will be rewarded with a piece of a letter written by one of the soldiers in this painting.  The letter has been torn, and is missing several pieces.  As you solve riddles and uncover objects, you will be given new pieces of the letter until it is whole. Click on the Letter Menu icon to review your progress";
				addChild(letterLoader);
			}
			if (curSlide==5) {
				controls.text="\n\n\nLeft Click: Select\nSpace: Toggle Magnifying glass";
				addChild(titleField);
			}
			if (curSlide==6) {
				controls.text="The next clue will be given to you when you can identify the object behind this first one. Click Proceed to begin.  Good Luck!";
			}
			
			//reset the text format
			controls.setTextFormat(tutText);
		}		

		//brings you to the next page in the tutorial
		function continueReading(event:MouseEvent):void {
			curSlide++;
			addChild(previousButton);
			//if on last slide, continue button is replaced by proceed button
			if (curSlide>=6) {
				if (! fromHelp) {
					addChild(proceedButton);
				}
				removeChild(continueButton);

			}
			updateText();
		}

		//returns you to the previous menu in the tutorial if you wish to read it again
		function previousPage(event:MouseEvent):void {
			curSlide--;
			//if on first slide, remove the previous button
			if (curSlide<=1) {
				removeChild(previousButton);
			}
			//if your in the help menu, there is no proceed, just close
			if (curSlide>=5&&fromHelp) {
				addChild(continueButton);
			}
			if (contains(proceedButton)) {
				addChild(continueButton);
				removeChild(proceedButton);
			}

			updateText();
		}

		override public function createCloseButton(placementRect):void {
			return;
		}
	}
}