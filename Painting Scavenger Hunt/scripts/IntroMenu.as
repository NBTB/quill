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
		private var titleBorderLoader:Loader = null;		//loader for title border image
		public static var introTitle = null;				//intro title text
		public static var introText = null;					//intro body text
		
		public function IntroMenu(xPos:int, yPos:int, widthVal:int, heightVal:int):void
		{
			super(xPos, yPos, widthVal, heightVal, false, false, false);
			changeBackgroundColor(BaseMenu.introMenuColor, 1);
		}
	
		public function init() 
		{
			addChild(titleField);
			addChild(titleBorderLoader);
			addChild(intro);
		}
		
		public function initText() 
		{			
			BaseMenu.titleFormat.color = BaseMenu.introFormat.color;
			BaseMenu.titleFormat.align = TextFormatAlign.CENTER;
			BaseMenu.titleFormat.size = Number(BaseMenu.titleFormat.size) * 1.2;
			
			titleField = new TextField();
			titleField.selectable = false;

			titleField.defaultTextFormat = BaseMenu.titleFormat;
			titleField.embedFonts = true;
			titleField.x = 0;
			titleField.y = 25;
			titleField.wordWrap = true;
			titleField.width= this.width;
			titleField.autoSize = TextFieldAutoSize.CENTER;
			titleField.text=introTitle;

			var bar = new Sprite();
			bar.graphics.moveTo(0, 0);
			addChild(bar);
			bar.graphics.beginFill(BaseMenu.menuColor, 1);
			bar.graphics.drawRect(20, 65, titleField.width - 40, 4);
			bar.graphics.endFill();

			intro = new TextField();
			intro.selectable=false;			
			intro.defaultTextFormat = BaseMenu.introFormat;
			intro.embedFonts = true;
			intro.x = 25;
			intro.y = titleField.y + 60;
			intro.width=360;
			intro.wordWrap=true;
			intro.autoSize = TextFieldAutoSize.CENTER;
			intro.text=introText;

			titleBorderLoader = new Loader();
			titleBorderLoader.load(new URLRequest(FileFinder.completePath(FileFinder.INTERFACE, "heading_separator.png")));
			titleBorderLoader.scaleX = 0.5;
			titleBorderLoader.x= titleField.x + ((titleField.width / 2) - 50);
			titleBorderLoader.y= titleField.y + 235;
			titleBorderLoader.alpha = 0.6;
		}
	}
}