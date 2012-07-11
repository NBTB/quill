package {
	import flash.display.*;
	import flash.events.*;
	import flash.ui.*;
	
	public class Quill extends SimpleButton{		
	
		public var captionText:String;		
		public var isOver:Boolean;
		public var clue:String;

		
		public function Quill(captionText:String, xPos:Number = 0, yPos:Number = 0){
			
			isOver = false;			
			this.captionText = captionText;
			x = xPos;
			y = yPos;
			clue = "Once I helped in achieving flight, now I assist you when you write...";
			
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
			PaintingCanvas.clueCounter = 1;
			trace(PaintingCanvas.clueCounter);
			
			
		}
		
	}
	
	
}