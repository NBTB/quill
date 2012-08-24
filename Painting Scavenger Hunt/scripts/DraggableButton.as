package scripts
{
	import flash.display.*
	import flash.events.*;
	import flash.geom.*;
	
	public class DraggableButton extends SimpleButton
	{
		private var drag:Boolean = false;
		private var fromMouse:Point = null;
		
		public function DraggableButton(upState:DisplayObject = null, overState:DisplayObject = null, downState:DisplayObject = null, hitTestState:DisplayObject = null)
		{
			super(upState, overState, downState, hitTestState);
			
			fromMouse = new Point();
			
			addEventListener(Event.ENTER_FRAME, enterFrame);
		}
		
		public function startDrag():void
		{
			drag = true;
			fromMouse.x = x - parent.mouseX;
			fromMouse.y = y - parent.mouseY;
		}
		
		public function stopDrag():void
		{
			drag = false;
		}
		
		private function enterFrame(e:Event):void
		{
			if(drag && parent)
			{
				x = parent.mouseX +	fromMouse.x;
				y = parent.mouseY + fromMouse.y;
			}
		}
	}
}