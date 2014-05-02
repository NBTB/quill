﻿package scripts
{
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	import flash.geom.*;


	public class IntroMenu extends BaseMenu {
		
		private var titleField:TextField = null;			//intro title field
		private var intro:TextField = null;					//intro text field
		private var isVisible:Boolean = true;
		private var letterCaption:TextField = null;
		public static var introTitle = null;				//intro title text
		public static var introText = null;					//intro body text
		
		public function IntroMenu(xPos:int, yPos:int, widthVal:int, heightVal:int):void
		{
			super(xPos, yPos, widthVal, heightVal, false, false, false);
			changeBackgroundColor(0xc9ced3, 1);
		}
	
		public function init() 
		{
			addChild(titleField);
			addChild(intro);
			addChild(letterCaption);
		}
		
		public function initText() 
		{			
			var titleFormat:TextFormat = new TextFormat();
			titleFormat.color=BaseMenu.introFormat.color;
			titleFormat.font=BaseMenu.titleFormat.font;
			titleFormat.size=Number(BaseMenu.titleFormat.size) * 1.2;
			titleFormat.bold = BaseMenu.titleFormat.bold;
			titleFormat.underline = BaseMenu.titleFormat.underline;
			titleFormat.italic = BaseMenu.titleFormat.italic;
			
			titleField = new TextField();
			titleField.selectable = false;
			titleField.defaultTextFormat = titleFormat;
			titleField.embedFonts = true;
			titleField.x = 25;
			titleField.y = 25;
			titleField.wordWrap = true;
			titleField.width= 430;
			titleField.text=introTitle;

			intro = new TextField();
			intro.selectable=false;			
			intro.defaultTextFormat = BaseMenu.introFormat;
			intro.embedFonts = true;
			intro.x = 25;
			intro.y = titleField.y + 65;
			intro.width=360;
			intro.wordWrap=true;
			intro.autoSize = TextFieldAutoSize.CENTER;
			intro.text=introText;
			
			letterCaption = new TextField();
			letterCaption.selectable=false;			
			letterCaption.defaultTextFormat = BaseMenu.introFormat;
			letterCaption.embedFonts = true;
			letterCaption.x = 25;
			letterCaption.y = 400;
			letterCaption.width=width - (intro.x * 2);
			letterCaption.wordWrap=true;
			letterCaption.autoSize = TextFieldAutoSize.CENTER;
			letterCaption.text= "Inventory";
		}
	}
}