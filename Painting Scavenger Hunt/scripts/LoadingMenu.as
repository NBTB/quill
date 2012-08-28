﻿package scripts
{
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	import flash.net.URLLoader;
	import flash.net.URLRequest;	
	import flash.geom.ColorTransform;


	public class LoadingMenu extends BaseMenu {

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
			loadingText.text = "Loading... Please Wait!";
		}
	}
}