package
{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.display.Shape;
	import flash.text.TextFormat;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;

	class MainMenu extends MovieClip
	{
		var menuBackground:Shape = new Shape();
		var menuButtonHelp:TextField = new TextField();
		var menuButtonClues:TextField = new TextField();
		var menuButtonRestart:TextField = new TextField();
		var menuButtonLetter:TextField = new TextField();
		var menuButtonObjects:TextField = new TextField();
		
		var helpMenu:HelpMenu;
		var cluesMenu:CluesMenu;
		
		var menuButtonFormat:TextFormat = new TextFormat();
		
		var buttonY:int = 380;

		public function MainMenu(startWTutorial:Boolean):void
		{
			helpMenu = new HelpMenu(0);
			cluesMenu = new CluesMenu(200);
			
			helpMenu.getBaseMenu(this);
			cluesMenu.getBaseMenu(this);
			
			this.addChild(menuBackground);
			this.addChild(menuButtonHelp);
			this.addChild(menuButtonClues);
			
			createBackground();
			formatText();
			
			menuButtonHelp.setTextFormat(menuButtonFormat);
			menuButtonClues.setTextFormat(menuButtonFormat);
			
			menuButtonHelp.addEventListener(MouseEvent.MOUSE_DOWN, clickHelpMenu);
			menuButtonClues.addEventListener(MouseEvent.MOUSE_DOWN, clickCluesMenu);
			menuButtonHelp.addEventListener(MouseEvent.ROLL_OVER, colorChange);
			menuButtonHelp.addEventListener(MouseEvent.ROLL_OUT, revertColor);
			menuButtonClues.addEventListener(MouseEvent.ROLL_OVER, colorChange);
			menuButtonClues.addEventListener(MouseEvent.ROLL_OUT, revertColor);
		}
		
		function formatText():void
		{
			menuButtonFormat.align = "center";
			menuButtonFormat.color = 0xE5E5E5;
			menuButtonFormat.font = "Gabriola";
			menuButtonFormat.size = 30;
			
			menuButtonHelp.y = buttonY;
			menuButtonHelp.x = 20;
			menuButtonHelp.height = 50;
			menuButtonHelp.width = 175;
			menuButtonHelp.text = "Help";
			
			menuButtonClues.y = buttonY;
			menuButtonClues.x = 200;
			menuButtonClues.height = 50;
			menuButtonClues.width = 175;
			menuButtonClues.text = "Clues";
		}
	
		//restarts the whole application
		function restart(event:MouseEvent):void
		{
			
		}
				
		//Tells the cluesMenu which clue to activate
		function activateClue():void
		{
			
		}
		
		function openCluesMenu():void
		{
			closeMenus();
			this.addChild(cluesMenu);
			cluesMenu.isOpen = true;
		}
		
		//Tells the cluesMenu when to activate
		function clickCluesMenu(event:MouseEvent):void
		{
			openCluesMenu();
		}
		
		function openHelpMenu():void
		{
			closeMenus();
			this.addChild(helpMenu);
			helpMenu.isOpen = true;
		}
		
		//Tells the helpMenu when to activate
		function clickHelpMenu(event:MouseEvent):void
		{
			openHelpMenu();
		}
		
		//Close all open menus, so there's no overlap when a new one is opened.
		function closeMenus():void
		{
			if (helpMenu.isOpen == true)
			{
				helpMenu.isOpen = false;
				removeChild(helpMenu);
			}
			if(cluesMenu.isOpen == true)
			{
				cluesMenu.isOpen = false;
				removeChild(cluesMenu);
			}
		}
		
		function createBackground():void
		{
			//Set the background graphics
			menuBackground.graphics.lineStyle(1, 0x836A35);
			menuBackground.graphics.beginFill(0x2F2720);
			menuBackground.graphics.drawRect(0, 392.5, 579.5, 41.5);
			menuBackground.graphics.endFill();
		}
		
		//changes the text color of the menu buttons to identify which one you're moused over
		public function colorChange(event:MouseEvent):void {
			var sender:TextField=event.target as TextField;

			var myColor:ColorTransform=sender.transform.colorTransform;
			myColor.color=0xFFC000;
			sender.transform.colorTransform=myColor;

		}
		
		//reverts the buttons back to their original colors
		public function revertColor(event:MouseEvent):void {
			var sender:TextField=event.target as TextField;
			var myColor:ColorTransform=sender.transform.colorTransform;
			myColor.color=0xFFFFFF;
			sender.transform.colorTransform=myColor;

		}
	}
}