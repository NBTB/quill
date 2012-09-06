package scripts
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
		var gameLoader:Loader = new Loader();											//Loader which allows the main game to load
		var context:LoaderContext = new LoaderContext();								//Context for the game's domain
		var gameName:URLRequest = new URLRequest("Painting Scavenger Hunt.swf");		//Path to the game's .swf
		
		//Function to load the game
		public function GameInitiator():void
		{			
			//set the domain, so they can refer to each other
			context.applicationDomain = ApplicationDomain.currentDomain;
			
			//load the game for the first time
			loadContent();			
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
			gameLoader.content.addEventListener(RestartEvent.RESTART_GAME, restartHandler);
		}
		
		//restart the game (currently non-functional)
		public function restartHandler(evt:RestartEvent)
		{			
			removeChild(gameLoader);
			gameLoader.unload();
			gameLoader = null;
			gameLoader = new Loader();
			
			loadContent();
		}
	}
}