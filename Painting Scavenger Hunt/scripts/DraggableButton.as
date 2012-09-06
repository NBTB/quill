package scripts
{
	import flash.display.*
	import flash.events.*;
	import flash.geom.*;
	
	public class DraggableButton extends SimpleButton
	{
		private var drag:Boolean = false;		//flag if being dragged
		private var fromMouse:Point = null;		//store distance from mouse
		
		public function DraggableButton(upState:DisplayObject = null, overState:DisplayObject = null, downState:DisplayObject = null, hitTestState:DisplayObject = null)
		{
			super(upState, overState, downState, hitTestState);
			
			fromMouse = new Point();
			
			addEventListener(Event.ENTER_FRAME, enterFrame);
		}
		
		//start drag button
		public function startDrag():void
		{
			drag = true;
			fromMouse.x = x - parent.mouseX;
			fromMouse.y = y - parent.mouseY;
		}
		
		//stop dragging button
		public function stopDrag():void
		{
			drag = false;
		}
		
		//handle each new frame
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