package
{
	import flash.display.*;
	import flash.events.*;
	
	public class OOIDescriptionPane extends MovieClip
	{
		private var innerObjects:Array = null;		//list of display objects that populate the pane
		private var closeMenuButton:Sprite = null;
		
		public static const CLOSE_PANE = "Close Pane";
		
		public function OOIDescriptionPane(x:Number, y:Number, width:Number, height:Number)
		{
			//position pane
			this.x = x;
			this.y = y;
			
			//draw background
			graphics.lineStyle(1, 0x836A35);
			graphics.beginFill(0x2F2720);
			graphics.drawRect(0, 0, width, height);
			graphics.endFill();
			
			//create close button
			closeMenuButton = new Sprite();
			addChild(closeMenuButton);
			createCloseButton();
			
			//listen for close button click
			closeMenuButton.addEventListener(MouseEvent.MOUSE_DOWN, closeMenu);
		}
		
		private function createCloseButton():void
		{
			closeMenuButton.graphics.lineStyle(1, 0x000000);
			closeMenuButton.graphics.beginFill(0xFF0000);
			closeMenuButton.graphics.drawRect(width - 20, 10, 10, 10);
			closeMenuButton.graphics.endFill();
		}
		
		private function closeMenu(event:MouseEvent):void
		{
			dispatchEvent(new Event(CLOSE_PANE));
		}
	}
	
}