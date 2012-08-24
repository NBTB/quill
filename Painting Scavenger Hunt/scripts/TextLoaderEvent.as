package scripts
{
	import flash.events.Event;
	
	public class TextLoaderEvent extends Event
	{
		protected var textFilename:String = null;
		
		//event types
		public static const TEXT_FILE_IMPORTED:String = "Text file imported";
		public static const TEXT_FILE_IMPORT_FAILED:String = "Text file import failed";
		
		public function TextLoaderEvent(textFilename:String, type:String, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
			this.textFilename = textFilename;
		}
		
		public function getTextFilename():String	{	return textFilename;	};
	}
}