package
{
	import flash.display.*;
	import flash.events.*;
	
	public class FakeAButton extends MovieClip
	{
		public var upState:DisplayObject = null;
		public var overState:DisplayObject = null;
		public var downState:DisplayObject = null;
		private var currentState:DisplayObject = null;
		private var currentStateNum:int = 0;
		
		private static const UP_STATE = 0;
		private static const OVER_STATE = 1;
		private static const DOWN_STATE = 2;
				
		public function FakeAButton(upState:DisplayObject = null, overState:DisplayObject = null, downState:DisplayObject = null)
		{
			//store states
			this.upState = upState;
			this.overState = overState;
			this.downState = downState;
			
			//listen for triggers of state change
			addEventListener(MouseEvent.MOUSE_OVER, function(e:MouseEvent):void	{	changeState(OVER_STATE);	});
			addEventListener(MouseEvent.MOUSE_OUT, function(e:MouseEvent):void	{	changeState(UP_STATE);		});
			addEventListener(MouseEvent.MOUSE_DOWN, function(e:MouseEvent):void	{	changeState(DOWN_STATE);	});
			addEventListener(MouseEvent.MOUSE_UP, function(e:MouseEvent):void	{	changeState(OVER_STATE);	});
			
			//start in up state
			changeState(UP_STATE);
		}
		
		private function changeState(newStateNum:int)
		{			
			//remove old state display object
			if(currentState)
				removeChild(currentState);
			
			//add new state display object
			switch(newStateNum)
			{
				case 0:
					if(upState)
					{
						addChild(upState);
						currentState = upState;
					}
					break;
				case 1:
					if(overState)
					{
						addChild(overState);
						currentState = overState;
					}
					break;
				case 2:
					if(downState)
					{
						addChild(downState);
						currentState = downState;
					}
					break;
			}
			
			//store new state number
			currentStateNum = newStateNum;
		}
		
		public function getUpState():DisplayObject		{	return upState;		}
		public function getOverState():DisplayObject	{	return downState;	}
		public function getDownState():DisplayObject	{	return overState;	}
		
		public function setUpState(newState:DisplayObject):void		
		{	
			upState = newState;		
			if(currentStateNum == UP_STATE)
				changeState(UP_STATE);
		}
		public function setOverState(newState:DisplayObject):void	
		{	
			overState = newState;	
			if(currentStateNum == OVER_STATE)
				changeState(OVER_STATE);
		}
		public function setDownState(newState:DisplayObject):void	
		{	
			downState = newState;	
			if(currentStateNum == DOWN_STATE)
				changeState(DOWN_STATE);
		}
	}
}