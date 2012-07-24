package
{
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	
	public class OOIInfoPane extends MovieClip
	{
		private var listChildren:Array = null;		//list of display objects that populate the pane
		private var closeMenuButton:Sprite = null;	//button to close window
		private var scrollBar = null;				//scroll bar used to scroll through pane content
		private var maxPoint:Point = null;			//bottom-right most point of the pane's content
		private var scrollPoint = null;				//translation of pane content due to scrolling
		
		private static var titleFormat:TextFormat = new TextFormat("Arial", 30, 0xffffffff);
		private static var bodyFormat:TextFormat = new TextFormat("Arial", 20, 0xffffffff);
		private static var captionFormat:TextFormat = new TextFormat("Arial", 20, 0xffffffff, null, true);
		
		private static var scrollBarStyle = null;
		
		//event types
		public static const OPEN_PANE = "Open Pane";
		public static const CLOSE_PANE = "Close Pane";
		
		public function OOIInfoPane(x:Number, y:Number, width:Number, height:Number)
		{
			//if the scroll bar style has not yet been setup, do so now
			if(!scrollBarStyle)
			{
				//create new style
				scrollBarStyle = new ScrollBarStyle();
				
				//load bitmaps to be used by up and down buttons
				var upDownBitmapLoader:ButtonBitmapLoader = new ButtonBitmapLoader();
				upDownBitmapLoader.addEventListener(Event.COMPLETE, function(e:Event):void
																					 {
																						//address loader
																						var bitmapLoader:ButtonBitmapLoader = ButtonBitmapLoader(e.target);
																						
																						//store up-down button states
																						scrollBarStyle.setUpDownButtonState(ScrollBarStyle.UP, bitmapLoader.getUpImage());
																						scrollBarStyle.setUpDownButtonState(ScrollBarStyle.OVER, bitmapLoader.getOverImage());
																						scrollBarStyle.setUpDownButtonState(ScrollBarStyle.DOWN, bitmapLoader.getDownImage());
																						scrollBarStyle.setUpDownButtonState(ScrollBarStyle.HITTEST, bitmapLoader.getHittestImage());								
																					 });
				upDownBitmapLoader.loadBitmaps("../assets/scrollbar up-down button up.png");
				
				//load bitmaps to be used by scroll button
				var scrollBitmapLoader:ButtonBitmapLoader = new ButtonBitmapLoader();
				scrollBitmapLoader.addEventListener(Event.COMPLETE, function(e:Event):void
																					 {
																						//address loader
																						var bitmapLoader:ButtonBitmapLoader = ButtonBitmapLoader(e.target);
																						
																						//store up-down button states
																						scrollBarStyle.setScrollButtonState(ScrollBarStyle.UP, bitmapLoader.getUpImage());
																						scrollBarStyle.setScrollButtonState(ScrollBarStyle.OVER, bitmapLoader.getOverImage());
																						scrollBarStyle.setScrollButtonState(ScrollBarStyle.DOWN, bitmapLoader.getDownImage());
																						scrollBarStyle.setScrollButtonState(ScrollBarStyle.HITTEST, bitmapLoader.getHittestImage());	
																					 });
				scrollBitmapLoader.loadBitmaps("../assets/scrollbar scroll button up.png");				
			}
			
			//position pane
			this.x = x;
			this.y = y;
			
			//create list of child objects
			listChildren = new Array();
			
			//draw background
			graphics.lineStyle(1, 0x836A35);
			graphics.beginFill(0x2F2720);
			graphics.drawRect(0, 0, width, height);
			graphics.endFill();
			
			//create close button
			closeMenuButton = new Sprite();
			addChild(closeMenuButton);
			createCloseButton();
			
			//create scroll bar
			scrollBar = new ScrollBar(new Rectangle(0, 100, 10, 200), scrollBarStyle);
			addChild(scrollBar);
			
			//currently no scrolling is available
			//scrollBar.visible = false;
			maxPoint = new Point(0, 0);
			scrollPoint = new Point(0, 0);
			
			//listen for close button click
			closeMenuButton.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void
																						 {
																							  closeMenu();
																						 });
																							
			
			//listen for being added to the stage
			addEventListener(Event.ADDED_TO_STAGE, function(e:Event):void
																	{
																		stage.addEventListener(KeyboardEvent.KEY_UP, handleKeysUp);
																	});
		}
		
		private function createCloseButton():void
		{
			closeMenuButton.graphics.lineStyle(1, 0x000000);
			closeMenuButton.graphics.beginFill(0xFF0000);
			closeMenuButton.graphics.drawRect(width - 20, 10, 10, 10);
			closeMenuButton.graphics.endFill();
		}
		
		
		private function handleKeysUp(e:KeyboardEvent)
		{
			if(e.charCode == 88 || e.charCode == 120) //'x'
				closeMenu()
		}
		
		private function closeMenu():void
		{
			dispatchEvent(new Event(CLOSE_PANE));
		}
		
		public function addListChild(child:DisplayObject, position:Point = null)
		{
			//set content to intial position
			scrollContent(new Point(-scrollPoint.x, -scrollPoint.y));
			
			//add child to list objects 
			listChildren.push(child);			
			
			//position child and add it to the display list
			if(position)
			{
				child.x = position.x;
				child.y = position.y;
			}
			addChild(child);
			
			//if the new child exceeds the current bottom-rightmost point, update max point
			if(child.x + child.width > maxPoint.x);
				maxPoint.x = child.x + child.width;
			if(child.y + child.height > maxPoint.y);
				maxPoint.y = child.y + child.height;
				
			//if the bottom-rightmost point exceeds the pane's own dimensions, make scrolling possible
			if(maxPoint.y > width)
				scrollBar.visible = true;
		}
		
		private function scrollContent(distance:Point):void
		{
			//move content
			for(var i = 0; i < listChildren.size; i++)
			{
				listChildren.x += distance.x;
				listChildren.y += distance.y;
			}
			
			//update total scroll distance
			scrollPoint += distance;						
		}
		
		public static function getTitleFormat():TextFormat		{	return titleFormat;		}
		public static function getBodyFormat():TextFormat		{	return bodyFormat;		}
		public static function getCaptionFormat():TextFormat	{	return captionFormat;	}
	}
}