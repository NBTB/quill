package
{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.display.Shape;
	import flash.text.TextFormat;
	import flash.events.*;

	public class LetterMenu extends BaseMenu
	{

		var pieces:Array=new Array();//stores all of the letterPieces 
		public var nextButton:TextField;
		var buttonFormat:TextFormat = new TextFormat();
		
		public function LetterMenu(xPos:int):void
		{
			//this.addChild(menuBackground);
			super(xPos);
			createBackground(xPos);
			nextButton = new TextField();
			nextButton.text = "Next Letter";
			nextButton.x = 405;
			nextButton.y = 465;
			nextButton.width = 175;
			buttonFormat.color = 0xE5E5E5;
            buttonFormat.font = "Gabriola";
            buttonFormat.size = 30;
			nextButton.setTextFormat(buttonFormat);
			addChild(nextButton);
			nextButton.visible = false;
			nextButton.addEventListener(MouseEvent.MOUSE_DOWN, clickNext);
		}

	
		override public function createBackground(xPos:int):void
		{
			//Set the background graphics
			menuBackground.graphics.lineStyle(1, 0x836A35);
			menuBackground.graphics.beginFill(0x2F2720);
			menuBackground.graphics.drawRect(0, 0, 550, 515);
			menuBackground.graphics.endFill();
			createCloseButton(180);
		}
		
		public function addPiece(newPiece:LetterPieces)
		{
			var newID:int = newPiece.getID();
			var indexFound:Boolean = false;
			
			if(pieces.length > 0)
			{
				for(var i:int = 0; i < pieces.length && !indexFound; i++)
				{
					if(pieces[i].getID() > newID)
					{
						pieces.splice(i, 0, newPiece);
						indexFound = true;
					}
				}
				if(!indexFound)
					pieces.push(newPiece);
			}
			else
				pieces.push(newPiece);
				
			//add new object to list
			newPiece.width = 399;
			newPiece.height = 544;
            
            //add new object as a display list child
            addChild(newPiece); 
			
			
		}
		
		
		
		public override function createCloseButton(xPos):void
        {
            closeMenuButton.graphics.lineStyle(1, 0x000000);
            closeMenuButton.graphics.beginFill(0xFF0000);
            closeMenuButton.graphics.drawRect(xPos+340, 10, 10, 10);
            closeMenuButton.graphics.endFill();
        }
		
		function clickNext(event:MouseEvent):void
		{
			for(var i:Number = 0; i < pieces.length - 1; i++)
			{
				pieces[i].visible = !pieces[i].visible;
			}
			pieces[7].visible = !pieces[i].visible;
		}
	}
}