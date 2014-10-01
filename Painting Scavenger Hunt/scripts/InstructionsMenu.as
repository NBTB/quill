﻿package scripts
{
	import flash.display.*;
	import flash.events.*;
	import flash.text.*
	import flash.net.*
	import flash.geom.ColorTransform;

	public class InstructionsMenu extends BaseMenu {

		private var resumeButton:TextButton = null;		//button for resuming game
		private var instructions:TextField = null;		//instructions text field
		private var titleField:TextField = null;		//title text field
		private var magLoader:Loader = null;			//loader of magnifying glass help image
		private var clueLoader:Loader = null;			//loader of clues help image
		private var mouseLoader:Loader = null;			//loader of mouse help image
		private var mouseOverLoader:Loader = null;		//loader of mouse over help image

		public static var objectiveTitle:String = null;	//instruction title of objective menu
		public static var objectiveText:String = null;	//instruction text of objective menu
		public static var cluesTitle:String = null;		//instruction title of clues menu
		public static var cluesText:String = null;		//instruction text of clues menu
		public static var objectsTitle:String = null;	//instruction title of objects menu
		public static var objectsText:String = null;	//instruction text of objects menu
		public static var endGoalTitle:String = null;	//instruction title of end goal menu
		public static var endGoalText:String = null;	//instruction text of end goal menu
		public static var controlsTitle:String = null;	//instruction title of controls menu
		public static var controlsText:String = null;	//instruction text of controls menu
		public static var aboutTitle:String = null;		//instruction title of about menu
		public static var aboutText:String = null;		//instruction text of about menu
		public static var creditsTitle:String = null;	//instruction title of credits menu
		public static var creditsText:String = null;	//instruction text of credits menu

		//slide numbers
		public static const OBJECTIVE_SLIDE:int = 1;
		public static const CLUES_SLIDE:int = 2;
		public static const OBJECTS_SLIDE:int = 3;
		public static const END_GOAL_SLIDE:int = 4;
		public static const CONTROLS_SLIDE:int = 5;
		public static const ABOUT_SLIDE:int = 6;
		public static const CREDITS_SLIDE:int = 7;

		public function InstructionsMenu(xPos:int, yPos:int, widthVal:int, heightVal:int):void {
			super(xPos, yPos, widthVal, heightVal, false, false, false);

			initText();
			loadImages();

			addContent(titleField);
			addContent(instructions);
			addContent(resumeButton);
		}

		//load images to be used in slides
		private function loadImages() {

			var url2:URLRequest=new URLRequest(FileFinder.completePath(FileFinder.INTERFACE, "clueBar.png"));
			clueLoader = new Loader();
			clueLoader.load(url2);
			clueLoader.x=60;
			clueLoader.y=150;

			var url3:URLRequest=new URLRequest(FileFinder.completePath(FileFinder.INTERFACE, "mouseLeftClick.swf"));
			mouseLoader = new Loader();
			mouseLoader.load(url3);
			mouseLoader.scaleX=.6;
			mouseLoader.scaleY=.6;
			mouseLoader.x=130;
			mouseLoader.y=241;

			var url4:URLRequest=new URLRequest(FileFinder.completePath(FileFinder.INTERFACE, "mouseOver.swf"));
			mouseOverLoader = new Loader();
			mouseOverLoader.load(url4);
			mouseOverLoader.scaleX=.8;
			mouseOverLoader.scaleY=.8;
			mouseOverLoader.x=180;
			mouseOverLoader.y=240;

			//listen for being removed from the display list
			addEventListener(Event.REMOVED_FROM_STAGE, function(e:Event):void
																		{
																			if(clueLoader && clueLoader.content)
																			{
																				Bitmap(clueLoader.content).bitmapData.dispose();
																				clueLoader.unload();
																				if(clueLoader.parent)
																					clueLoader.parent.removeChild(clueLoader);
																			}
																		});
		}

		//initialize text fields
		private function initText() {
			titleField = new TextField();
			titleField.defaultTextFormat = BaseMenu.altTitleFormat;
			titleField.x=10;
			titleField.y=10
			titleField.width=width - (titleField.x * 2);
			titleField.autoSize = TextFieldAutoSize.CENTER;
			titleField.embedFonts = true;
			titleField.selectable=false;

			resumeButton = new TextButton("Resume Game", textButtonFormat, textUpColor, textOverColor, textDownColor);
			resumeButton.x=(width / 2) - (resumeButton.width / 2);
			resumeButton.y=height-resumeButton.height - 10;
			resumeButton.addEventListener(MouseEvent.CLICK, function(e:Event):void	{	closeMenu();	});

			instructions = new TextField();
			instructions.defaultTextFormat = BaseMenu.bodyFormat;
			instructions.x=10
			instructions.y=titleField.y + titleField.height + 50 ;
			instructions.width=width - (instructions.x * 2);
			instructions.autoSize = TextFieldAutoSize.LEFT;
			instructions.wordWrap=true;
			instructions.embedFonts = true;
			instructions.selectable=false;
		}



		//cycles through what the text in the tutorial says
		public function updateText(curSlide:int):void {
			//if an image is a child, and is not supposed to be seen in that page, remove it
			if (contains(clueLoader)) {
				removeChild(clueLoader);
			}
			if (contains(mouseLoader)) {
				removeChild(mouseLoader);
			}
			if (contains(mouseOverLoader)) {
				removeChild(mouseOverLoader);
			}
			//help menu:Objective
			if (curSlide==OBJECTIVE_SLIDE) {
				titleField.text = objectiveTitle;
				instructions.text = objectiveText;
			}
			//help menu:Clues
			else if (curSlide==CLUES_SLIDE) {
				titleField.text = cluesTitle;
				instructions.text = cluesText;
				addChild(clueLoader);
			}
			//help menu:Objects
			else if(curSlide==OBJECTS_SLIDE) {
				titleField.text = objectsTitle;
				instructions.text = objectsText;
				addChild(mouseLoader);
				addChild(mouseOverLoader);
			}
			//help menu:End Goal
			else if (curSlide==END_GOAL_SLIDE) {
				titleField.text = endGoalTitle;
				instructions.text = endGoalText;

			}
			//help menu:Controls
			else if (curSlide==CONTROLS_SLIDE) {
				titleField.text = controlsTitle;
				instructions.text = controlsText;
			}

			//help menu:About
			else if (curSlide==ABOUT_SLIDE) {
				titleField.text = aboutTitle;
				instructions.text = aboutText;
			}

			//help menu:Credits
			else if (curSlide==CREDITS_SLIDE) {
				titleField.text = creditsTitle;
				instructions.text = creditsText;
			}
		}
	}
}
