﻿package scripts
{
	import flash.display.*;
	import flash.events.*;
	import flash.text.*
	import flash.net.*
	import flash.geom.ColorTransform;
	


	public class InstructionsMenu extends BaseMenu {

		var resumeButton:TextButton = null;
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
		public static var objectiveTitle = null;
		public static var objectiveText = null;
		public static var cluesTitle = null;
		public static var cluesText = null;
		public static var objectsTitle = null;
		public static var objectsText = null;
		public static var endGoalTitle = null;
		public static var endGoalText = null;
		public static var controlsTitle = null;
		public static var controlsText = null;
		public static var aboutTitle = null;
		public static var aboutText = null;
		public static var creditsTitle = null;
		public static var creditsText = null;

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
			
			
			titleField.defaultTextFormat = BaseMenu.titleFormat;
			instructions.defaultTextFormat = BaseMenu.bodyFormat;
			
			
			instructions.setTextFormat(tutText);
			
			curSlide=1;
			resumeButton = new TextButton("Resume Game", textButtonFormat, textUpColor, textOverColor, textDownColor);
			
			addContent(titleField);
			addContent(instructions);
			addContent(resumeButton);
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
			titleField.embedFonts = true;

			//resumeButton.text="Resume Game";
			//resumeButton.autoSize = TextFieldAutoSize.CENTER;
			resumeButton.x=(width / 2) - (resumeButton.width / 2);
			resumeButton.y=height-resumeButton.height - 10;			

			instructions.x=10
			instructions.y=titleField.y + titleField.height + 50 ;
			instructions.width=width - (instructions.x * 2);
			instructions.autoSize = TextFieldAutoSize.LEFT;
			instructions.wordWrap=true;
			instructions.embedFonts = true;
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
				titleField.text = objectiveTitle;
				instructions.text = objectiveText;
				//addChild(magLoader);
			}
			//help menu:Clues
			else if (curSlide==3) {
				titleField.text = cluesTitle;
				instructions.text = cluesText;
				addChild(clueLoader);
			}	
			//help menu:Objects
			else if(curSlide==4) {
				titleField.text = objectsTitle;
				instructions.text = objectsText;
				addChild(mouseLoader);
				addChild(mouseOverLoader);
			}
			//help menu:Letter
			else if (curSlide==5) {
				titleField.text = endGoalTitle;
				instructions.text = endGoalText;
				
			}
			//help menu:Controls
			else if (curSlide==6) {
				titleField.text = controlsTitle;
				instructions.text = controlsText;
			}
			
			//help menu:about
			else if (curSlide==7) {
				titleField.text = aboutTitle;
				instructions.text = aboutText;
			}
			
			//help menu:credits
			else if (curSlide==8) {
				titleField.text = creditsTitle;
				instructions.text = creditsText;
			}
		}		
	}
}