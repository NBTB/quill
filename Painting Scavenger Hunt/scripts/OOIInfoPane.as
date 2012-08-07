package
{
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class OOIInfoPane extends BaseMenu
	{
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