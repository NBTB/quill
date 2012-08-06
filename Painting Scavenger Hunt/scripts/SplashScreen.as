package
{
    import flash.text.TextField;
    import flash.display.Shape;
    import flash.display.DisplayObject;
    import flash.text.TextFormat;
    import flash.events.MouseEvent;
    import flash.display.MovieClip;
    import flash.events.Event;
    import flash.events.EventDispatcher;
    import flash.geom.ColorTransform;
     
//TODO: Add code to read in the About and Credit page information
  
  
    public class SplashScreen extends MovieClip
    {
        var theBackground:Shape = new Shape();                      //Background of the splash screen
        var splashTitle:TextField = new TextField();                //The title which appears on the splash screen
        var tut:TutorialMenu;
        var startGameListener:MenuListener;                         //Game listener which tells when the splash screen has finished
        var useTut:Boolean;                                         //Boolean which tracks whether the user wants to view the tutorial or not
        var gameReady:Boolean = false;                              //Indicates that the game is ready to start
        var firstStart:Boolean = true;                              //Indicates whether this is the first time starting the game or not
        var splashButtonStart:TextField = new TextField();          //Button to start the game
        var splashButtonAbout:TextField = new TextField();          //Button to About page
        var splashButtonCredits:TextField = new TextField();        //Button to read credits page
        var splashButtonTitle:TextField = new TextField();          //button to return to title page
        var splashButtonTutorial:TextField = new TextField();       //button to see tutorial
        var splashButtonSkip:TextField = new TextField();           //button to skip tutorial
        var proceedButton:TextField = new TextField();              //button to proceed to next page of tutorial
        var continueButton:TextField = new TextField();             //button to indicate tutorial is finished
        var controls:TextField = new TextField();                   //The info in the tutorial (to be removed?)
        var controls2:TextField = new TextField();                  //...Page 2
         
        var splashTitleFormat:TextFormat = new TextFormat();        //Format for the splash screen title
        var splashButtonFormat:TextFormat = new TextFormat();       //Format for the splash screen buttons
        var tutText:TextFormat = new TextFormat();                  //Format for the tutorial
         
        var buttonX:int = 285;                                      //The x location of the buttons
        var buttonSeparation = 75;                                  //The distance the buttons are spaced apart
        var buttonY1:int = 265;                                     //The first Y location
        var buttonY2:int = buttonY1+buttonSeparation;               //...second
        var buttonY3:int = buttonY2+buttonSeparation;               //...third
         
         
        public function SplashScreen(theTrigger:MenuListener)
        {
            //Copy of the MenuListener, to be triggered at start of game.
            startGameListener = theTrigger;
             
            //Add the elements of the SplashScreen to the game.
            this.addChild(theBackground);
            this.addChild(splashTitle);
             
            //Run starting functions to show screen correctly.
            formatText();
            mainSplashActivate();
            createBackground();
             
            //Make sure all the elements have their text formatted correctly.
            splashTitle.setTextFormat(splashTitleFormat);
            splashButtonStart.setTextFormat(splashButtonFormat);
            splashButtonAbout.setTextFormat(splashButtonFormat);
            splashButtonCredits.setTextFormat(splashButtonFormat);
            splashButtonTitle.setTextFormat(splashButtonFormat);
            splashButtonTutorial.setTextFormat(splashButtonFormat);
            splashButtonSkip.setTextFormat(splashButtonFormat);
             
            //make the buttons so the text cursor doesn't appear over them
            splashTitle.selectable = false;
            splashButtonStart.selectable = false;
            splashButtonAbout.selectable = false;
            splashButtonCredits.selectable = false;
            splashButtonTitle.selectable = false;
            splashButtonTutorial.selectable = false;
            splashButtonSkip.selectable = false;       
             
            //Event listeners for the different buttons in the project.
            splashButtonStart.addEventListener(MouseEvent.MOUSE_DOWN, tutorialStart);
            splashButtonAbout.addEventListener(MouseEvent.MOUSE_DOWN, aboutInfo);
            splashButtonCredits.addEventListener(MouseEvent.MOUSE_DOWN, creditsInfo);
            splashButtonTitle.addEventListener(MouseEvent.MOUSE_DOWN, mainSplash);
            splashButtonTutorial.addEventListener(MouseEvent.MOUSE_DOWN, startWithTut);
            splashButtonSkip.addEventListener(MouseEvent.MOUSE_DOWN, startNoTut);
             
            splashButtonStart.addEventListener(MouseEvent.ROLL_OVER, colorChange);
            splashButtonStart.addEventListener(MouseEvent.ROLL_OUT, revertColor);
             
            splashButtonAbout.addEventListener(MouseEvent.ROLL_OVER, colorChange);
            splashButtonAbout.addEventListener(MouseEvent.ROLL_OUT, revertColor);
             
            splashButtonCredits.addEventListener(MouseEvent.ROLL_OVER, colorChange);
            splashButtonCredits.addEventListener(MouseEvent.ROLL_OUT, revertColor);
             
            splashButtonTitle.addEventListener(MouseEvent.ROLL_OVER, colorChange);
            splashButtonTitle.addEventListener(MouseEvent.ROLL_OUT, revertColor);
             
            splashButtonTutorial.addEventListener(MouseEvent.ROLL_OVER, colorChange);
            splashButtonTutorial.addEventListener(MouseEvent.ROLL_OUT, revertColor);
             
            splashButtonSkip.addEventListener(MouseEvent.ROLL_OVER, colorChange);
            splashButtonSkip.addEventListener(MouseEvent.ROLL_OUT, revertColor);
             
            proceedButton.addEventListener(MouseEvent.ROLL_OVER, colorChange);
            proceedButton.addEventListener(MouseEvent.ROLL_OUT, revertColor);
             
            continueButton.addEventListener(MouseEvent.ROLL_OVER, colorChange);
            continueButton.addEventListener(MouseEvent.ROLL_OUT, revertColor);
        }
         
        //Runs if the user wanted to start the game with the tutorial
        function startWithTut(event:MouseEvent):void
        {
            //Function chosen if the user chooses to view the tutorial
            useTut = true;
            gameReady = true;
            removeChild(splashTitle);
            removeChild(splashButtonTutorial);
            removeChild(splashButtonSkip);                     
            tut = new TutorialMenu(0,0, stage.stageWidth, stage.stageHeight);
            addChild(tut);
            tut.proceedButton.addEventListener(MouseEvent.MOUSE_DOWN,proceedFromTut);
             
            addChild(controls);
            addChild(continueButton);
            continueButton.addEventListener(MouseEvent.MOUSE_DOWN, tutorialContinue);
        }
         
        //Triggers the end of the tutorial if the user decided to view it.
        function tutorialContinue(event:MouseEvent):void
        {          
            removeChild(controls);
            removeChild(continueButton);
            addChild(controls2);
            addChild(proceedButton);
            proceedButton.addEventListener(MouseEvent.MOUSE_DOWN, proceedFromTut);
        }
         
        //Sends the event signaling for the game to start.
        function proceedFromTut(event:MouseEvent):void
        {          
            startGameListener.triggerListener();
        }          
         
        //Sends the event signaling for the game to start.
        function startNoTut(event:MouseEvent):void
        {
            //Function chosen if the user chooses not to view the tutorial
            useTut = false;
            gameReady = true;
            startGameListener.triggerListener();
        }
         
        //Sets up text formatting
        function formatText():void
        {
            //Details regarding the title
            splashTitleFormat.align = "center";
            splashTitleFormat.color = 0xCC9933;
            splashTitleFormat.font = "Gabriola";
            splashTitleFormat.size = 44;
             
            //More details regarding the title
            splashTitle.wordWrap = true;
            splashTitle.selectable = false;
            splashTitle.x = 160;
            splashTitle.y = 110;
            splashTitle.height = 168;
            splashTitle.width = 425;
             
            //Details which apply to all of the buttons
            splashButtonFormat.align = "center";
            splashButtonFormat.color = 0xE5E5E5;
            splashButtonFormat.font = "Gabriola";
            splashButtonFormat.size = 36;
             
            //Details of the start game button
            splashButtonStart.x = buttonX;
            splashButtonStart.y = buttonY1;
            splashButtonStart.height = 50;
            splashButtonStart.width = 175;
            splashButtonStart.text = "Start Game";
            splashButtonStart.selectable = false;
             
            //Details of the about button
            splashButtonAbout.x = buttonX;
            splashButtonAbout.y = buttonY2;
            splashButtonAbout.height = 50;
            splashButtonAbout.width = 175;
            splashButtonAbout.text = "About";
            splashButtonAbout.selectable = false;
             
            //Details of the credits button
            splashButtonCredits.x = buttonX;
            splashButtonCredits.y = buttonY3;
            splashButtonCredits.height = 50;
            splashButtonCredits.width = 175;
            splashButtonCredits.text = "Credits";
            splashButtonCredits.selectable = false;
             
            //Details of the main page button
            splashButtonTitle.x = buttonX;
            splashButtonTitle.y = buttonY3;
            splashButtonTitle.height = 50;
            splashButtonTitle.width = 175;
            splashButtonTitle.text = "Main Page";
            splashButtonTitle.selectable = false;
             
            //Details of the view tutorial button
            splashButtonTutorial.x = buttonX-50;
            splashButtonTutorial.y = buttonY1;
            splashButtonTutorial.height = 50;
            splashButtonTutorial.width = 275;
            splashButtonTutorial.text = "View Tutorial";
            splashButtonTutorial.selectable = false;
             
            //Details of the skip tutorial button
            splashButtonSkip.x = buttonX-50;
            splashButtonSkip.y = buttonY2;
            splashButtonSkip.height = 50;
            splashButtonSkip.width = 275;
            splashButtonSkip.text = "Skip Tutorial";
            splashButtonSkip.selectable = false;
             
            tutText.color = 0xCC9933;
            tutText.font = "Gabriola";
            tutText.size = 32;         
             
            proceedButton.x = 500;
            proceedButton.y = 500;
            proceedButton.height = 50;
            proceedButton.width = 275;
            proceedButton.text = "Proceed";
            proceedButton.selectable = false;
             
            continueButton.x = 500;
            continueButton.y = 500;
            continueButton.height = 50;
            continueButton.width = 275;
            continueButton.text = "Continue Reading";
            continueButton.selectable = false;
             
            controls.width = 750;
            controls.height = 800;
            controls.wordWrap = true;
            controls.selectable = false;
            controls.text = "Welcome to The Night Before The Battle Interactive Scavenger Hunt.  The objective of this game is to help you look more closely at this painting, in order to understand the importance of many of the paintings elements as well as gain knowledge of the history depicted in the artwork.  In this games there is a collection of objects for you to discover throughout the painting. Left-clicking one of these objects will highlight it, and clicking again will open a description.";
             
            controls2.width = 750;
            controls2.height = 700;
            controls2.wordWrap = true;
            controls2.selectable = false;
            controls2.text = "In a few moments you will be given a clue to the first object you need to look for.  By clicking on the correct object that the riddle references, the object will be added to your collection.  You will also be given a brief description of the object, as well as some background on its history and its purpose in the painting.   Along with this description, you will be rewarded with a piece of a letter written by one of the soldiers in this painting.  The letter has been torn, and is missing several pieces.  As you solve riddles and uncover objects, you will be given new pieces of the letter until it is whole.  The next clue will be given to you when you can identify the object behind this first one. Click Proceed to begin.";
        }
         
        //Display the main splash page; secondary function with a mouse listener, since both are used.
        function mainSplash(event:MouseEvent):void
        {
            mainSplashActivate();
        }
         
        //sets up the main splash page
        function mainSplashActivate():void
        {
            //Set the title for the main splash page, and make sure formatting stays correct
            splashTitle.text = "The Night Before the Battle Scavenger Hunt";
            splashTitle.setTextFormat(splashTitleFormat);
             
            //Set which buttons are visible or not on the main splash page
            this.addChild(splashButtonAbout);
            this.addChild(splashButtonCredits);
            this.addChild(splashButtonStart);
            //Only remove child if it's coming from a page where it has been added.
            if (firstStart != true)
            {
                this.removeChild(splashButtonTitle);
            }
             
            //No longer the first time on page...
            firstStart = false;
        }
         
        //sets up the credits splash page
        function creditsInfo(event:MouseEvent):void
        {
            //Set which code buttons are visible or not on the credits part of the splash page
            addChild(splashButtonTitle);
            removeChild(splashButtonAbout);
            removeChild(splashButtonCredits);
            removeChild(splashButtonStart);
             
            //Set the title for the credits page, and make sure formatting stays correct
            splashTitle.text = "The Night Before the Battle Scavenger Hunt";
            splashTitle.setTextFormat(splashTitleFormat);
        }
  
        //sets up the about splash page
        function aboutInfo(event:MouseEvent):void
        {
            //Set which code buttons are visible or not on the about part of the splash page
            addChild(splashButtonTitle);
            removeChild(splashButtonAbout);
            removeChild(splashButtonCredits);
            removeChild(splashButtonStart);
             
            //Set the title for the about page, and make sure formatting stays correct
            splashTitle.text = "The Night Before the Battle Scavenger Hunt";
            splashTitle.setTextFormat(splashTitleFormat);
        }
         
        //Display the page asking whether the user wants to use the tutorial or not
        function tutorialStart(event:MouseEvent):void
        {
            //Set the title for the tutorial page, and make sure formatting stays correct
            splashTitle.text = "The Night Before the Battle Scavenger Hunt";
            splashTitle.setTextFormat(splashTitleFormat);
             
            //Set which code buttons are visible or not on the tutorial inquisition part of the splash page
            addChild(splashButtonTutorial);
            addChild(splashButtonSkip);
            removeChild(splashButtonAbout);
            removeChild(splashButtonCredits);
            removeChild(splashButtonStart);
        }
         
        //changes button color when hovered over
        public function colorChange(event:MouseEvent):void
        {
            var sender:TextField=event.target as TextField;
            var myColor:ColorTransform=sender.transform.colorTransform;
            myColor.color=0xFFC000;
            sender.transform.colorTransform=myColor;
        }
         
        //reverts the buttons back to their original colors
        public function revertColor(event:MouseEvent):void
        {
            var sender:TextField=event.target as TextField;
            var myColor:ColorTransform=sender.transform.colorTransform;
            myColor.color=0xFFFFFF;    
            sender.transform.colorTransform=myColor;
        }
         
        //creates the background
        function createBackground():void
        {
            theBackground.graphics.lineStyle(1, 0x836A35);
            theBackground.graphics.beginFill(0x2F2720);
            theBackground.graphics.drawRect(0, 0, 764, 572);
            theBackground.graphics.endFill();
        }
    }
}