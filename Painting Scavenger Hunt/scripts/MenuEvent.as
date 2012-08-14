package
{
	import flash.events.Event;
	
	public class MenuEvent extends Event
	{
		protected var targetMenu:BaseMenu;		//menu related to event (allows event to be dispatched from other locations)
		
		//event types
		public static const MENU_OPENED = "Menu Opened";
		public static const MENU_CLOSED = "Menu Closed";
		public static const CLOSE_MENUS_REQUEST = "Close all menus";
		public static const SPECIAL_OPEN_REQUEST = "Open menu under special circumstances"
		
		public function MenuEvent(targetMenu:BaseMenu, type:String, bubbles:Boolean = false, cancelable:Boolean = false)
		{
			super(type, bubbles, cancelable);
			this.targetMenu = targetMenu;
		}
		
		public function getTargetMenu():BaseMenu	{	return targetMenu;	};
	}
}