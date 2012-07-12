package
{
    
    import flash.events.Event;
    import flash.events.EventDispatcher;
    
    public class MenuListener extends EventDispatcher {

		public static const GAME_START:String = 'game_started';

        public function MenuListener():void;
        
        public function triggerListener():void 
		{
			//If a MenuListener has its triggerListener function called, send out a GAME_START event.
            this.dispatchEvent(new Event(MenuListener.GAME_START));
        };
    };  
};