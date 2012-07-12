package {
	import flash.display.*;
	import flash.events.*;
	import flash.ui.*;
	
	public class Skull extends SimpleButton{		
	
		public var captionText:String;
		public var isOver:Boolean;
		public var clue:String;
		
		public function Skull(captionText:String, xPos:Number = 0, yPos:Number = 0){
			
			isOver = false;			
			this.captionText = captionText;
			x = xPos;
			y = yPos;
			clue = "Seeing my face may make you feel grim, but I'll always greet you with a large grin...";
			addEventListener(MouseEvent.ROLL_OVER, mouseOvering);
			addEventListener(MouseEvent.ROLL_OUT, mouseOuting);
			addEventListener(MouseEvent.CLICK, select);
			
		}
		
		public function mouseOvering(event:MouseEvent):void {
			
			isOver = true;
		}
		
		public function mouseOuting(event:MouseEvent):void {
			
			isOver = false;
		}
		
		public function select(event:MouseEvent):void {
			PaintingCanvas.prevCounter = PaintingCanvas.clueCounter;
			PaintingCanvas.clueCounter = 0;
			trace(PaintingCanvas.clueCounter);
			
			
		}
		
	}
	
	
}