package
{
	import flash.display.MovieClip;
	import flash.utils.Dictionary;

	public class GameInitiator extends MovieClip
	{
		var theGame:ScavengerHunt;
		private var _dict:Dictionary = new Dictionary(true);
		
		
		public function GameInitiator():void
		{
			theGame = new ScavengerHunt(this);
			_dict[theGame] = "GameExists";
			addChild(theGame);
		}
		
		public function reloadGame():void
		{
			removeChild(theGame);
			theGame = new ScavengerHunt(this);
			addChild(theGame);
		}
	}
}