package
{
	import flash.display.MovieClip;
	import flash.text.*;
	import flash.events.*;
	import flash.display.Shape;
	
	class CluesMenu extends BaseMenu
	{
		public var clueText:TextField = new TextField();
		
		public function CluesMenu(xPos):void
		{
			super(xPos);
			//this.addChild(menuBackground);
			//createBackground();
			
			var clueTextFormat:TextFormat = new TextFormat("Arial", 14, 0xFFFFFFFF);
			clueText.defaultTextFormat = clueTextFormat;
			
			clueText.x = 210;
			clueText.y = 300;
			clueText.width = 150;
			
			addEventListener(Event.ADDED_TO_STAGE, addedToStage);
			
		}

		public function addedToStage(e:Event)
		{
			addChild(clueText);
		}
	
	}
}