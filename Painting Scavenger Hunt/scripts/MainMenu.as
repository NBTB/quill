package
{
	import flash.display.MovieClip;
	import flash.text.TextField;
	import flash.display.Shape;
	import flash.text.TextFormat;
	import flash.events.MouseEvent;
	import flash.geom.ColorTransform;
	import flash.geom.Rectangle;

	class MainMenu extends MovieClip
	{
		var menuBackground:Shape = new Shape();
		var menuButtonHelp:TextField = new TextField();
		var menuButtonClues:TextField = new TextField();
		var menuButtonRestart:TextField = new TextField();
		var menuButtonLetter:TextField = new TextField();
		var menuButtonObjects:TextField = new TextField();
		var recTransform:ColorTransform;
		
		var helpMenu:HelpMenu;
		var cluesMenu:CluesMenu;
		public var letterMenu:LetterMenu;
		public static var letterRec:Shape;
		
		var menuButtonFormat:TextFormat = new TextFormat();
		
		var buttonY:int = 390;

		public function MainMenu(startWTutorial:Boolean):void
		{
			//letterRec.graphics.beginFill(0x000000);
			//letterRec.graphics.drawRect(300, buttonY, 175, 50); 	
			//recTransform = letterRec.transform.colorTransform;
			//recTransform.color = 0x00CCFF;
			//letterRec.transform.colorTransform = recTransform; 
			
			
			
			helpMenu = new HelpMenu(0);
			cluesMenu = new CluesMenu(150);
			letterMenu = new LetterMenu(300);
			
			helpMenu.getBaseMenu(this);
			cluesMenu.getBaseMenu(this);
			letterMenu.getBaseMenu(this);
			
			this.addChild(menuBackground);
			this.addChild(menuButtonHelp);
			this.addChild(menuButtonClues);
			
			letterRec = new Shape();
			letterRec.graphics.beginFill(0x00CCFF); 
			letterRec.graphics.drawRect(325, buttonY, 125, 50); 
			letterRec.graphics.endFill();
			letterRec.visible = false;
			addChild(letterRec); 
			
			this.addChild(menuButtonLetter);
			
			
			createBackground();
			formatText();
			
			menuButtonHelp.setTextFormat(menuButtonFormat);
			menuButtonClues.setTextFormat(menuButtonFormat);
			menuButtonLetter.setTextFormat(menuButtonFormat);
			
			menuButtonHelp.addEventListener(MouseEvent.MOUSE_DOWN, clickHelpMenu);
			menuButtonClues.addEventListener(MouseEvent.MOUSE_DOWN, clickCluesMenu);
			menuButtonLetter.addEventListener(MouseEvent.MOUSE_DOWN, clickLetterMenu);
			menuButtonHelp.addEventListener(MouseEvent.ROLL_OVER, colorChange);
			menuButtonHelp.addEventListener(MouseEvent.ROLL_OUT, revertColor);
			menuButtonClues.addEventListener(MouseEvent.ROLL_OVER, colorChange);
			menuButtonClues.addEventListener(MouseEvent.ROLL_OUT, revertColor);
			menuButtonLetter.addEventListener(MouseEvent.ROLL_OVER, colorChange);
			menuButtonLetter.addEventListener(MouseEvent.ROLL_OUT, revertColor);
			
		}
		
		function formatText():void
		{
			menuButtonFormat.align = "center";
			menuButtonFormat.color = 0xE5E5E5;
			menuButtonFormat.font = "Gabriola";
			menuButtonFormat.size = 30;
			
			menuButtonHelp.y = buttonY;
			menuButtonHelp.x = 0;
			menuButtonHelp.height = 50;
			menuButtonHelp.width = 175;
			menuButtonHelp.text = "Help";
			
			menuButtonClues.y = buttonY;
			menuButtonClues.x = 150;
			menuButtonClues.height = 50;
			menuButtonClues.width = 175;
			menuButtonClues.text = "Clues";
			
			menuButtonLetter.y = buttonY;
			menuButtonLetter.x = 300;
			menuButtonLetter.height = 50;
			menuButtonLetter.width = 175;
			menuButtonLetter.text = "Letter";
		}
		
		function letterNotifyer():void
		{
			
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
		
		function openLetterMenu():void
		{
			closeMenus();
			this.addChild(letterMenu);
			letterMenu.isOpen = true;
			//the first piece of letter is always available
			letterMenu.pieces[0].visible = true;
		
			//when a new letter piece is rewarded, make it visible in the lette menu
			for(var i:Number = 0; i < ScavengerHunt.rewardCounter; i++)
			{
				trace(letterMenu.pieces[i].pieceName);
				letterMenu.pieces[i].visible = true;							
			}
		}
		
		//Tells the cluesMenu when to activate
		function clickLetterMenu(event:MouseEvent):void
		{
			openLetterMenu();
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
			if(letterMenu.isOpen == true)
			{
				letterMenu.isOpen = false;
				letterRec.visible = false;
				removeChild(letterMenu);
			}
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
		
		function createBackground():void
		{
			//Set the background graphics
			menuBackground.graphics.lineStyle(1, 0x836A35);
			menuBackground.graphics.beginFill(0x2F2720);
			menuBackground.graphics.drawRect(0, 392.5, 579.5, 41.5);
			menuBackground.graphics.endFill();
		}
	}
}