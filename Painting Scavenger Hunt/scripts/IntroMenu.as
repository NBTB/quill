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
		var tutFormat:TextFormat = new TextFormat();
		var titleFormat:TextFormat = new TextFormat();
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

		function init() 
		{
			addChild(titleField);
			addChild(controls);
			addChild(proceedButton);
			
			curSlide=1;
			
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
			titleFormat.color=BaseMenu.titleFormat.color;
			titleFormat.font=BaseMenu.titleFormat.font;
			titleFormat.size=Number(BaseMenu.titleFormat.size) * 1,5;
			titleFormat.align = TextFormatAlign.CENTER
			titleFormat.bold = BaseMenu.titleFormat.bold;
			titleFormat.underline = BaseMenu.titleFormat.italic;
			titleFormat.italic = BaseMenu.titleFormat.underline;
			
			titleField.selectable = false;
			titleField.defaultTextFormat = titleFormat;
			titleField.autoSize = TextFieldAutoSize.CENTER;
			titleField.x=0;
			titleField.width=width - (titleField.x * 2);
			titleField.text="Welcome to The Night Before The Battle\nScavenger Hunt!";
			
			proceedButton.selectable=false;
			proceedButton.defaultTextFormat = BaseMenu.textButtonFormat;
			proceedButton.autoSize = TextFieldAutoSize.CENTER;
			proceedButton.x=10;			
			proceedButton.width=width - (proceedButton.x * 2);
			proceedButton.text="Proceed";
			proceedButton.y=height - proceedButton.height - 10;

			controls.selectable=false;			
			controls.defaultTextFormat = BaseMenu.bodyFormat;
			controls.x = 10;
			controls.y = titleField.y + titleField.height + 10;
			controls.width=width - (controls.x * 2);
			controls.height=proceedButton.y - controls.y - 10;
			controls.wordWrap=true;
			controls.autoSize = TextFieldAutoSize.CENTER;
			controls.text="The objective of this game is to help you look more closely at this painting, in order to understand the importance of many of the paintings elements as well as gain knowledge of the history depicted in the artwork. Use your mouse to interact with objects on the canvas. Tap the Spacebar or click the icon in the right corner of the main menu to toggle the magnifying glass and help you see the painting more clearly.  Follow the clues to progress through the scavenger hunt.\nGood Luck!";
		}
	}
}