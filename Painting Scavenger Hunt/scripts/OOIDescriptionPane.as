package
{
	import flash.display.*;
	import flash.events.*;
	import flash.text.*;
	import flash.geom.Point;
	
	public class OOIDescriptionPane extends MovieClip
	{
		private var listChildren:Array = null;		//list of display objects that populate the pane
		private var closeMenuButton:Sprite = null;
		
		private var titleFormat:TextFormat = new TextFormat("Arial", 30, 0xFFFFFFFF);
		private var bodyFormat:TextFormat = new TextFormat("Arial", 20, 0xFFFFFFFF);
		private var captionFormat:TextFormat = new TextFormat("Arial", 20, 0xFFFFFFFF, null, true);
		
		//event types
		public static const CLOSE_PANE = "Close Pane";
		
		public function OOIDescriptionPane(x:Number, y:Number, width:Number, height:Number)
		{
			//position pane
			this.x = x;
			this.y = y;
			
			//create list of child objects
			listChildren = new Array();
			
			//draw background
			graphics.lineStyle(1, 0x836A35);
			graphics.beginFill(0x2F2720);
			graphics.drawRect(0, 0, width, height);
			graphics.endFill();
			
			//create close button
			closeMenuButton = new Sprite();
			addChild(closeMenuButton);
			createCloseButton();
			
			//listen for close button click
			closeMenuButton.addEventListener(MouseEvent.CLICK, function(event:MouseEvent):void
																						 {
																							  closeMenu();
																						 });
																							
			
			//listen for being added to the stage
			addEventListener(Event.ADDED_TO_STAGE, function(e:Event):void
																	{
																		stage.addEventListener(KeyboardEvent.KEY_UP, handleKeysUp);
																	});
		}
		
		private function createCloseButton():void
		{
			closeMenuButton.graphics.lineStyle(1, 0x000000);
			closeMenuButton.graphics.beginFill(0xFF0000);
			closeMenuButton.graphics.drawRect(width - 20, 10, 10, 10);
			closeMenuButton.graphics.endFill();
		}
		
		
		private function handleKeysUp(e:KeyboardEvent)
		{
			if(e.charCode == 88 || e.charCode == 120) //'x'
				closeMenu()
		}
		
		private function closeMenu():void
		{
			dispatchEvent(new Event(CLOSE_PANE));
		}
		
		public function addListChild(child:DisplayObject, position:Point = null)
		{
			//add child to list objects 
			listChildren.push(child);			
			
			//position child and add it to the display list
			if(position)
			{
				child.x = position.x;
				child.y = position.y;
			}
			addChild(child);
		}
	}
	
	
	/*public function getTitleFormat():TextFormat		{	return titleFormat;		}
	public function getBodyFormat():TextFormat		{	return bodyFormat;		}
	public function getCaptionFormat():TextFormat	{	return captionFormat;	}*/
}