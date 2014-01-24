﻿package scripts
{
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	import flash.geom.*;


	public class IntroMenu extends BaseMenu {

		private var proceedButton:TextButton = null;		//button to proceed to game		
		private var titleField:TextField = null;			//intro title field
		private var intro:TextField = null;					//intro text field
		private var isVisible:Boolean = true;
		private var spacebarPic:SimpleButton = null;
		public static var introTitle = null;				//intro title text
		public static var introText = null;					//intro body text
		
		public function IntroMenu(xPos:int, yPos:int, widthVal:int, heightVal:int):void
		{
			super(xPos, yPos, widthVal, heightVal, false, false, false);
		}
	
		public function init() 
		{
			addChild(titleField);
			addChild(intro);
			//addChild(proceedButton);
			
			//proceedButton.addEventListener(MouseEvent.MOUSE_DOWN, hideMenu);
		}
		
		public function initText() 
		{			
			var titleFormat:TextFormat = new TextFormat();
			titleFormat.color=BaseMenu.titleFormat.color;
			titleFormat.font=BaseMenu.titleFormat.font;
			titleFormat.size=Number(BaseMenu.titleFormat.size) * 1,5;
			titleFormat.align = TextFormatAlign.CENTER
			titleFormat.bold = BaseMenu.titleFormat.bold;
			titleFormat.underline = BaseMenu.titleFormat.italic;
			titleFormat.italic = BaseMenu.titleFormat.underline;
			
			titleField = new TextField();
			titleField.selectable = false;
			titleField.defaultTextFormat = titleFormat;
			titleField.embedFonts = true;
			titleField.autoSize = TextFieldAutoSize.CENTER;
			titleField.x=50;
			titleField.wordWrap = true;
			titleField.width=width - (titleField.x * 2);
			titleField.text=introTitle;
			
			proceedButton=new TextButton("Hide Help", textButtonFormat, textUpColor, textOverColor, textDownColor);
			proceedButton.x=(width / 2) - (proceedButton.width / 2);			
			proceedButton.y=height - proceedButton.height - 10;

			intro = new TextField();
			intro.selectable=false;			
			intro.defaultTextFormat = BaseMenu.bodyFormat;
			intro.embedFonts = true;
			intro.x = 10;
			intro.y = titleField.y + titleField.height + 10;
			intro.width=width - (intro.x * 2);
			intro.height=proceedButton.y - intro.y - 10;
			intro.wordWrap=true;
			intro.autoSize = TextFieldAutoSize.CENTER;
			intro.text=introText;
			
			spacebarPic = new SimpleButton();
			var spacebarPicLoader:ButtonBitmapLoader = new ButtonBitmapLoader();
			spacebarPicLoader.addEventListener(Event.COMPLETE,
				function(e:Event):void
				   {
						spacebarPic = new SimpleButton(new Bitmap(spacebarPicLoader.getUpImage()));
						spacebarPic.x = intro.x + 95;
						spacebarPic.y = intro.y + 203;
						spacebarPic.visible = true;
						addChild(spacebarPic);
				   });
			spacebarPicLoader.loadBitmaps(FileFinder.completePath(FileFinder.INTERFACE, "spacebar.png"));
		}
		
		public function hideMenu(e:MouseEvent):void {
			if(intro.visible) {
				intro.visible = false;
				spacebarPic.visible = false;
				proceedButton.setText("Show Help");
			}
			else {
				intro.visible = true;
				spacebarPic.visible = true;
				proceedButton.setText("Hide Help");
			}
		}
	}
}