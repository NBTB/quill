﻿package scripts
{
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	import flash.net.URLLoader;
	import flash.net.URLRequest;	
	import flash.geom.ColorTransform;


	public class LoadingMenu extends BaseMenu {	
		
		var loadLoader:Loader = new Loader();
		var startGameListener:MenuListener;
		
		var splashTitle:TextField = new TextField();
		var loadingText:TextField = new TextField();
		var splashTitleFormat:TextFormat = new TextFormat();

		public function LoadingMenu(xPos:int, yPos:int, widthVal:int, heightVal:int):void {
			super(xPos, yPos, widthVal, heightVal, false, false, false, 1);
			
			initText();
			init();
			
		}

		function init() 
		{
			addChild(splashTitle);
			addChild(loadingText);
			addChild(loadLoader);
		}
		
		
		function endLoad(e:Event)
		{
			startGameListener.triggerListener();
		}
		
		function getStartListener(theListener:MenuListener)
		{
			startGameListener = theListener;
		}
		
		function initText()
		{
			var url3:URLRequest=new URLRequest(FileFinder.completePath(FileFinder.INTERFACE, "loadingWheel.swf"));

			loadLoader.load(url3);
			loadLoader.scaleX=.6;
			loadLoader.scaleY=.6;
			loadLoader.x=450;
			loadLoader.y=170;
			
			//create variation of menu title format
			splashTitleFormat.align = TextFormatAlign.CENTER;
			splashTitleFormat.color = BaseMenu.titleFormat.color;
			splashTitleFormat.font = BaseMenu.titleFormat.font;
			splashTitleFormat.size = Number(BaseMenu.titleFormat.size) * 1.5;	
						
			//create title
			splashTitle.defaultTextFormat = splashTitleFormat;
			splashTitle.wordWrap = true;
			splashTitle.selectable = false;
			splashTitle.x = 410;
			splashTitle.y = 50;
			splashTitle.height = 168;
			splashTitle.width = 425;
			splashTitle.text = "The Night Before the Battle Scavenger Hunt";
			
			//create loading text field
			loadingText.defaultTextFormat = splashTitleFormat;
			loadingText.wordWrap = true;
			loadingText.selectable = false;
			loadingText.x = 410;
			loadingText.y = 370;
			loadingText.height = 168;
			loadingText.width = 425;
			loadingText.text = "Loading... Please Wait.";
		}
	}
}