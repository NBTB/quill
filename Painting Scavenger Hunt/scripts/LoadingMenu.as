﻿package
{
	import flash.text.TextField;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	import flash.display.Shape;
	import flash.display.DisplayObject;
	import flash.text.TextFormat;
	import flash.events.MouseEvent;
	import flash.display.MovieClip;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	import flash.display.Loader;
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
		public static var fromHelp:Boolean=false;
		
		var startGameListener:MenuListener;
		
		var splashTitle:TextField = new TextField();
		var loadingText:TextField = new TextField();
		var splashTitleFormat:TextFormat = new TextFormat();

		public function LoadingMenu(xPos:int, yPos:int, widthVal:int, heightVal:int):void {
			super(xPos, yPos, widthVal, heightVal);
			
			initText();
			init();
			
		}

		function init() {

			
			splashTitle.setTextFormat(splashTitleFormat);
			loadingText.setTextFormat(splashTitleFormat);
			
			
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
			//Details regarding the title
			splashTitleFormat.align = "center";
			splashTitleFormat.color = 0xCC9933;
			splashTitleFormat.font = "Gabriola";
			splashTitleFormat.size = 44;
						
			//More details regarding the title
			splashTitle.wordWrap = true;
			splashTitle.selectable = false;
			splashTitle.x = 410;
			splashTitle.y = 50;
			splashTitle.height = 168;
			splashTitle.width = 425;
			splashTitle.text = "The Night Before the Battle Scavenger Hunt";
			
			loadingText.wordWrap = true;
			loadingText.selectable = false;
			loadingText.x = 410;
			loadingText.y = 370;
			loadingText.height = 168;
			loadingText.width = 425;
			loadingText.text = "Loading... Please Wait!";
			trace(loadingText.text);
		}
		
		override public function createCloseButton(placementRect):void {
			return;
		}
	}
}