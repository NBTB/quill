package {
	import flash.display.*;
	import flash.events.*;
	import flash.ui.*;
	
	public class Sword extends SimpleButton{		
	
		public var captionText:String;		
		public var isOver:Boolean;
		public var clue:String;
		
		public function Sword(captionText:String, xPos:Number = 0, yPos:Number = 0){
			
			isOver = false;			
			this.captionText = captionText;
			x = xPos;
			y = yPos;
			clue = "To find me, you'll have to be pretty sharp, but not as sharp as me...";
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
			PaintingCanvas.clueCounter = 7;
			trace(PaintingCanvas.clueCounter);
			
			
		}
		
	}
	
	
}