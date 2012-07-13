package
{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.display.Shape;

	public class LetterMenu extends BaseMenu
	{

		static var pieces:Array=new Array();//stores all of the letterPieces 
		
		public function LetterMenu(xPos:int):void
		{
			//this.addChild(menuBackground);
			super(xPos);
			createBackground(xPos);
		}

	
		
		override public function createBackground(xPos:int):void
		{
			//Set the background graphics
			menuBackground.graphics.lineStyle(1, 0x836A35);
			menuBackground.graphics.beginFill(0x2F2720);
			menuBackground.graphics.drawRect(0, 0, 300, 340);
			menuBackground.graphics.endFill();
			for(var i:Number = 0; i < pieces.length; i++)
			{
				addChild(pieces[i]);
			}
			createCloseButton(xPos - 200);
			//trace(pieces[0].name);
		}
		
		public function addPiece(newPiece:LetterPieces)
		{
			
			
			
		}
	}
}