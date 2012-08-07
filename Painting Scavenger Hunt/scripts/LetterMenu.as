﻿package
{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.display.Shape;
	import flash.text.TextFormat;
	import flash.geom.ColorTransform;
	import flash.events.*;

	public class LetterMenu extends BaseMenu
	{

		var pieces:Array=new Array();						//stores all of the letterPieces 
		public var nextButton:TextField;					//button to go to the next part of the letter, currently redundant?
		var buttonFormat:TextFormat = new TextFormat();		//formatting
		
		//Creates the letter menu
		public function LetterMenu(xPos:int, yPos:int, widthVal:int, heightVal:int):void
		{
			//Pass in variables to the base menu to create background
			super(xPos, yPos, widthVal, heightVal);
			
			//Create the next button
			nextButton = new TextField();
			nextButton.text = "Next Letter";
			nextButton.selectable = false;
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
			nextButton.addEventListener(MouseEvent.ROLL_OVER, colorChange);
			nextButton.addEventListener(MouseEvent.ROLL_OUT, revertColor);
		}
		
		//If a piece of the letter is unlocked, display it
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
			newPiece.width = 568;
			newPiece.height = 540;
            
            //add new object as a display list child
            addChild(newPiece); 
			
			
		}
		
		//changes the text color of the menu buttons to identify which one you're moused over
		/*public function colorChange(event:MouseEvent):void {
			var sender:TextField=event.target as TextField;
			var myColor:ColorTransform=sender.transform.colorTransform;
			myColor.color=0xCC9933;
			sender.transform.colorTransform=myColor;

		}
		
		//reverts the buttons back to their original colors
		public function revertColor(event:MouseEvent):void {
			var sender:TextField=event.target as TextField;
			var myColor:ColorTransform=sender.transform.colorTransform;	
			myColor.color=0xE5E5E5;		
			sender.transform.colorTransform=myColor;

		}*/
		
		//next piece is shown
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