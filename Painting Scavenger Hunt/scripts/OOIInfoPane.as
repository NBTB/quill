package
{
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class OOIInfoPane extends BaseMenu
	{
		/*private var menuBackground:Shape = null;					//background of menu
		private var menuMask:Shape = null;							//mask of menu to determine what is seen
		private var contentContainer:MovieClip = null;				//container of display objects that populate the pane
		private var closeMenuButton:Sprite = null;					//button to close window
		private var scrollBar = null;								//scroll bar used to scroll through pane content
		private var scrollPoint:Point = null;						//translation of pane content due to scrolling
		private var paneDimensions:Point = null;					//visible dimensions of pane
		
		private static var titleFormat:TextFormat = new TextFormat("Arial", 30, 0xffffffff);
		private static var bodyFormat:TextFormat = new TextFormat("Arial", 20, 0xffffffff);
		private static var captionFormat:TextFormat = new TextFormat("Arial", 20, 0xffffffff, null, true);
		
		private static var scrollBarStyle = null;*/
		
		//event types
		public static const OPEN_PANE = "Open Pane";
		public static const CLOSE_PANE = "Close Pane";
		
		public function OOIInfoPane(x:Number, y:Number, widthVal:Number, heightVal:Number)
		{
			//call super constructor
			super(x, y, widthVal, heightVal);
		}
				
		/*TODO this should be be overriden, instead use BaseMenu events*/
		override protected function closeMenu():void
		{
			dispatchEvent(new Event(CLOSE_PANE));
		}
		
		public static function getTitleFormat():TextFormat		{	return titleFormat;		}
		public static function getBodyFormat():TextFormat		{	return bodyFormat;		}
		public static function getCaptionFormat():TextFormat	{	return captionFormat;	}
	}
}