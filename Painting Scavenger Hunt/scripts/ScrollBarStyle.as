package
{
	import flash.display.*;
	import flash.events.*;
	
	public class ScrollBarStyle extends EventDispatcher
	{
		private var upDownButtonStates:Array = null;
		private var scrollerStates:Array = null;
		
		private static const NUM_STATES = 4;
		
		//event types
		public static const UP_DOWN_BUTTON_STATES_CHANGED:String = "Up-Down states have changed";
		public static const SCROLL_BUTTON_STATES_CHANGED:String = "Up-Down states have changed";
		
		//button state enumeration
		public static const UP:int = 0;
		public static const OVER:int = 1;
		public static const DOWN:int = 2;
		public static const HITTEST:int = 3;
		
		public function ScrollBarStyle(upDownButtonStates:Array = null, scrollerStates:Array = null)
		{
			//create state arrays and populate them with null
			this.upDownButtonStates = new Array(NUM_STATES);
			for(var u:int = 0; u < NUM_STATES; u++)
					this.upDownButtonStates[u] = null;
			this.scrollerStates = new Array(NUM_STATES);
			for(var s:int = 0; s < NUM_STATES; s++)
					this.scrollerStates[s] = null;
			
			//if an array of up-down button states was given, store the elements
			if(upDownButtonStates)
			{
				for(var i:int = 0; i < NUM_STATES && i < upDownButtonStates.length; i++)
					this.upDownButtonStates[i] = upDownButtonStates[i];
			}
			
			//if an array of scroller states was given, store the elements
			if(scrollerStates)
			{
				for(var j:int = 0; j < NUM_STATES && j < scrollerStates.length; j++)
					this.scrollerStates[j] = scrollerStates[j];
			}
			
			//dispatch update events
			dispatchEvent(new Event(UP_DOWN_BUTTON_STATES_CHANGED));
			dispatchEvent(new Event(SCROLL_BUTTON_STATES_CHANGED));
		}
		
		public function getUpDownButtonState(buttonState:int):BitmapData
		{
			if(buttonState >= 0 && buttonState < NUM_STATES)
				return upDownButtonStates[buttonState];
			return null;
		}
		
		public function getScrollerState(buttonState:int):BitmapData
		{
			if(buttonState >= 0 && buttonState < NUM_STATES)
				return scrollerStates[buttonState];
			return null;
		}
		
		public function setUpDownButtonState(buttonState:int, stateDisplay:BitmapData):void
		{
			if(buttonState >= 0 && buttonState < NUM_STATES)
			{
				upDownButtonStates[buttonState] = stateDisplay;
				dispatchEvent(new Event(UP_DOWN_BUTTON_STATES_CHANGED));
			}
		}
		
		public function setScrollerState(buttonState:int, stateDisplay:BitmapData):void
		{
			if(buttonState >= 0 && buttonState < NUM_STATES)
			{
				scrollerStates[buttonState] = stateDisplay;
				dispatchEvent(new Event(SCROLL_BUTTON_STATES_CHANGED));
			}
		}
	}
}