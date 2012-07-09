package
{
    
    import flash.events.Event;
    import flash.events.EventDispatcher;
    
    public class MenuListener extends EventDispatcher {

		public static const GAME_START:String = 'game_started';

        public function MenuListener():void;
        
        public function triggerListener():void 
		{
            this.dispatchEvent(new Event(MenuListener.GAME_START));
        };
    };  
};