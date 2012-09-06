package scripts
{
     
    import flash.events.Event;
     
    public class RestartEvent extends Event {
         
        public static const RESTART_GAME:String = "restartGame";
         
         
        public function RestartEvent(type:String, bubbles:Boolean=false, cancelable:Boolean=false) {
            super(type, bubbles, cancelable);
        }
        public override function clone():Event {
            return new RestartEvent(type, bubbles, cancelable);
        }
    }
}