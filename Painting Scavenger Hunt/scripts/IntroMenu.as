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
			changeBackgroundColor(0x635d52, 1);
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
			titleFormat.color=BaseMenu.titleFormat.color;
			titleFormat.font=BaseMenu.titleFormat.font;
			titleFormat.size=Number(BaseMenu.titleFormat.size) * 1,5;
			titleFormat.bold = BaseMenu.titleFormat.bold;
			titleFormat.underline = BaseMenu.titleFormat.italic;
			titleFormat.italic = BaseMenu.titleFormat.underline;
			
			titleField = new TextField();
			titleField.selectable = false;
			titleField.defaultTextFormat = titleFormat;
			titleField.embedFonts = true;
			titleField.autoSize = TextFieldAutoSize.CENTER;
			titleField.x = 15;
			titleField.wordWrap = true;
			titleField.width=width - (titleField.x * 2);
			titleField.text=introTitle;

			intro = new TextField();
			intro.selectable=false;			
			intro.defaultTextFormat = BaseMenu.bodyFormat;
			intro.embedFonts = true;
			intro.x = 10;
			intro.y = titleField.y + titleField.height + 10;
			intro.width=width - (intro.x * 2);
			intro.wordWrap=true;
			intro.autoSize = TextFieldAutoSize.CENTER;
			intro.text=introText;
			
			letterCaption = new TextField();
			letterCaption.selectable=false;			
			letterCaption.defaultTextFormat = BaseMenu.bodyFormat;
			letterCaption.embedFonts = true;
			letterCaption.x = 15;
			letterCaption.y = 400;
			letterCaption.width=width - (intro.x * 2);
			letterCaption.wordWrap=true;
			letterCaption.autoSize = TextFieldAutoSize.CENTER;
			letterCaption.text= "Inventory";
		}
	}
}