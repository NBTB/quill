﻿package scripts
{
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	import flash.geom.*;


	public class IntroMenu extends BaseMenu {

		public var proceedButton:TextField = new TextField();		
		var resumeButton:TextField = new TextField();
		var controls:TextField = new TextField();
		public static var curSlide:Number;
		var theBackground:Shape = new Shape();
		var tutText:TextFormat = new TextFormat();
		var titleText:TextFormat = new TextFormat();
		var buttonFormat:TextFormat = new TextFormat();
		var titleField:TextField = new TextField();
		var magLoader:Loader = new Loader();
		var clueLoader:Loader = new Loader();
		var mouseLoader:Loader = new Loader();
		var mouseOverLoader:Loader = new Loader();
		public static var fromHelp:Boolean=false;
		
		var startGameListener:MenuListener;
		
		public function IntroMenu(xPos:int, yPos:int, widthVal:int, heightVal:int):void {
			super(xPos, yPos, widthVal, heightVal, false, false, false);
			
			
			initText();
			init();
			
		}

		function init() {

			//titleField.setTextFormat(titleText);
			controls.setTextFormat(tutText);
			controls.selectable=false;			
			
			
			//titleField.selectable=false;
			addChild(controls);
			addChild(proceedButton);
			
			curSlide=1;
			proceedButton.setTextFormat(buttonFormat);
			proceedButton.selectable=false;
			proceedButton.addEventListener(MouseEvent.ROLL_OVER, colorChange);
			proceedButton.addEventListener(MouseEvent.ROLL_OUT, revertColor);
			
			proceedButton.addEventListener(MouseEvent.MOUSE_DOWN,proceedFromTut);
		}
		
		function proceedFromTut(event:MouseEvent):void
		{			
			proceedButton.removeEventListener(MouseEvent.MOUSE_DOWN, proceedFromTut);
			closeMenu();
		}	
		
		function initText() 
		{

			buttonFormat.color=0xE5E5E5;
			buttonFormat.font="Gabriola";
			buttonFormat.size=36;

			titleText.color=0xE5E5E5;
			titleText.font="Gabriola";
			titleText.size=46;

			tutText.color=0xCC9933;
			tutText.font="Gabriola";
			tutText.size=28;
			tutText.align="center";

			titleField.x=570;
			titleField.width=300;
			titleField.text="Controls";

			proceedButton.x=width/2 - 50;
			proceedButton.y=415;
			proceedButton.height=50;
			proceedButton.width=275;
			proceedButton.text="Proceed";
			
			resumeButton.x=570;
			resumeButton.y=550;
			resumeButton.height=50;
			resumeButton.width=275;
			resumeButton.text="Resume Game";

			controls.x = 25;
			controls.y = 25;
			controls.width= width - 50;
			controls.height=800;
			controls.wordWrap=true;
			controls.text="Welcome to The Night Before The Battle Interactive Scavenger Hunt!\n  The objective of this game is to help you look more closely at this painting, in order to understand the importance of many of the paintings elements as well as gain knowledge of the history depicted in the artwork. Use your mouse to interact with objects on the canvas.  Hit 'Space' or the little icon in the bottom corner of your screen to toggle the magnifying glass to help you see things more clearly.  Follow the clues to progress through the scavenger hunt. Good Luck!";
		}
	}
}