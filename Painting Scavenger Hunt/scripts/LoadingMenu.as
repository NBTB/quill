﻿package scripts
{
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	import flash.net.URLLoader;
	import flash.net.URLRequest;	
	import flash.geom.ColorTransform;


	public class LoadingMenu extends BaseMenu {	
		
		private var loadLoader:Loader = null;					//loader of loading animation
		
		private var splashTitle:TextField = null;				//title to display while loading
		private var loadingText:TextField = null;				//loading notification
		private var loadingScreenTextFormat:TextFormat = null;	//format of textfields on loading screen
		
		public static var loadingTitle:String = null

		public function LoadingMenu(xPos:int, yPos:int, widthVal:int, heightVal:int):void 
		{
			super(xPos, yPos, widthVal, heightVal, false, false, false, 1);
			
			initText();
			init();
		}

		private function init() 
		{
			addChild(splashTitle);
			addChild(loadingText);
			addChild(loadLoader);
		}
		
		private function initText()
		{
			var url3:URLRequest=new URLRequest(FileFinder.completePath(FileFinder.INTERFACE, "loadingWheel.swf"));

			loadLoader = new Loader();
			loadLoader.load(url3);
			loadLoader.scaleX=.6;
			loadLoader.scaleY=.6;
			loadLoader.x=450;
			loadLoader.y=170;
			
			//create variation of menu title format
			loadingScreenTextFormat = new TextFormat();
			loadingScreenTextFormat.align = TextFormatAlign.CENTER;
			loadingScreenTextFormat.color = BaseMenu.titleFormat.color;
			loadingScreenTextFormat.font = BaseMenu.titleFormat.font;
			loadingScreenTextFormat.size = Number(BaseMenu.titleFormat.size) * 1.5;	
						
			//create title
			splashTitle = new TextField();
			splashTitle.defaultTextFormat = loadingScreenTextFormat;
			splashTitle.embedFonts = true;
			splashTitle.wordWrap = true;
			splashTitle.selectable = false;
			splashTitle.x = 410;
			splashTitle.y = 50;
			splashTitle.height = 168;
			splashTitle.width = 425;
			splashTitle.text = loadingTitle;
			
			//create loading text field
			loadingText = new TextField();
			loadingText.defaultTextFormat = loadingScreenTextFormat;
			loadingText.embedFonts = true;
			loadingText.wordWrap = true;
			loadingText.selectable = false;
			loadingText.x = 410;
			loadingText.y = 370;
			loadingText.height = 168;
			loadingText.width = 425;
			loadingText.text = "Loading... Please Wait.";
		}
		
		public function fail()
		{
			loadingText.text = "Failed to load";
			if(loadLoader.parent)
				loadLoader.parent.removeChild(loadLoader);
		}
	}
}