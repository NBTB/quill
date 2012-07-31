package
{
	import flash.events.Event;
	import flash.net.URLLoader;
	import flash.net.URLRequest;
	public class OOIInfoImporter
	{
		public function importText(filename:String):void
		{
			var textLoader:URLLoader = new URLLoader();
			textLoader.addEventListener(Event.COMPLETE, function(e:Event):void
																		 {
																			 trace(e.target.data);
																		 });
			textLoader.load(new URLRequest(filename));
		}
	}
}