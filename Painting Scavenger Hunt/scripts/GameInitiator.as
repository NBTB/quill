package
{
    import flash.display.MovieClip;
    import flash.utils.Dictionary;
    import flash.display.Loader;
    import flash.system.LoaderContext;
    import flash.system.ApplicationDomain;
    import flash.net.URLRequest;
    import flash.events.Event;
    import flash.events.ProgressEvent;
    import flash.text.TextField;
  
    public class GameInitiator extends MovieClip
    {
        //var theGame:ScavengerHunt;       
        var gameLoader:Loader = new Loader();                                           //Loader which allows the main game to load
        var context:LoaderContext = new LoaderContext();                                //Context for the game's domain
        var gameName:URLRequest = new URLRequest("Painting Scavenger Hunt.swf");        //Path to the game's .swf
         
        //Function to load the game
        public function GameInitiator():void
        {
            //trace("Initial Load");
             
            //set the domain, so they can refer to each other
            context.applicationDomain = ApplicationDomain.currentDomain;
             
            /*TODO loadContent causing infinite loop and not creating hunt, temporary solution here*/
            //load the game for the first time
            //loadContent();
            var scavengerHunt:ScavengerHunt = new ScavengerHunt(this);
            addChild(scavengerHunt);
             
             
            //check for the restart event to restart the game
            this.addEventListener(RestartEvent.RESTART_GAME, restartHandler);
        }
         
        //when the game loader has correclty obtained the game, start it.
        public function loadContent()
        {
            gameLoader.contentLoaderInfo.addEventListener(Event.COMPLETE, onCompleteHandler);
            gameLoader.load(gameName, context);
        }
         
        //add the game as a child
        function onCompleteHandler(loadEvent:Event)
        {
            addChild(gameLoader);
        }
         
        //restart the game (currently non-functional)
        public function restartHandler(evt:RestartEvent)
        {
            //addChild(gameLoader);
            //removeChild(gameLoader.content);
             
            /*TODO this does not work in CS3, find alternative or upgrade*/
            //gameLoader.unloadAndStop();  //This works, but does not remove event listeners
             
            //TO BE REMOVED!!!!!
            var toBeRemovedRestartText:TextField = new TextField();
            toBeRemovedRestartText.text = "Currently, game does not restart correctly.  Please refresh the page.";
            toBeRemovedRestartText.width = 500;
            addChild(toBeRemovedRestartText);
            //TO BE REMOVED!!!!!
             
            //removeChild(gameLoader);
            //loadContent();
        }
  
        /*public function reloadGame():void
        {
            removeChild(theGame);
            theGame = new ScavengerHunt(this);
            addChild(theGame);
        }*/
    }
}