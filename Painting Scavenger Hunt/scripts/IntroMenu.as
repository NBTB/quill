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
        private var subTitle:TextField = null;              //intro sub-title text field
		private var isVisible:Boolean = true;
		private var titleBorder1:Loader = null;		        //loader for 1st title border image
        private var titleBorder2:Loader = null;		        //loader for 2nd title border image
		public static var introTitle = null;				//intro title text
		public static var introText = null;					//intro body text
        public static var introSubTitle = null;             //intro subtitle text

		public function IntroMenu(xPos:int, yPos:int, widthVal:int, heightVal:int):void
		{
			super(xPos, yPos, widthVal, heightVal, false, false, false);
			changeBackgroundColor(BaseMenu.introMenuColor, 1);
		}

		public function init()
		{
			addChild(titleField);
			addChild(titleBorder1);
            addChild(titleBorder2);
			addChild(intro);
            addChild(subTitle);
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
			titleField.y = 20;
			titleField.wordWrap = true;
			titleField.width = this.width;
			titleField.autoSize = TextFieldAutoSize.CENTER;
			titleField.text = introTitle;

            subTitle = new TextField();
            subTitle.selectable = false;
            BaseMenu.titleFormat.size = 24;
            subTitle.defaultTextFormat = BaseMenu.titleFormat;
            subTitle.embedFonts = true;
            subTitle.y = titleField.y + 40;
            subTitle.width = this.width;
            subTitle.wordWrap = true;
            subTitle.autoSize = TextFieldAutoSize.CENTER;
            subTitle.text = introSubTitle;

			intro = new TextField();
			intro.selectable = false;
			intro.defaultTextFormat = BaseMenu.introFormat;
			intro.embedFonts = true;
			intro.x = 40; //25 to left align to title
			intro.y = titleField.y + 100;
			intro.width = 368;
			intro.wordWrap = true;
			intro.autoSize = TextFieldAutoSize.CENTER;
			intro.text = introText;

			titleBorder1 = new Loader();
			titleBorder1.load(new URLRequest(FileFinder.completePath(FileFinder.INTERFACE, "heading_separator.png")));
			titleBorder1.x= 50;
			titleBorder1.y= titleField.y + 42;

            titleBorder2 = new Loader();
            titleBorder2.load(new URLRequest(FileFinder.completePath(FileFinder.INTERFACE, "heading_separator_2.png")));
            titleBorder2.x= 144;
            titleBorder2.y= titleField.y + 250;
		}
	}
}
