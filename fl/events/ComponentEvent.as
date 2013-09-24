//Created by Action Script Viewer - http://www.buraks.com/asv
package fl.events {
    import flash.events.*;

    public class ComponentEvent extends Event {

        public static const BUTTON_DOWN:String = "buttonDown";
        public static const LABEL_CHANGE:String = "labelChange";
        public static const HIDE:String = "hide";
        public static const SHOW:String = "show";
        public static const RESIZE:String = "resize";
        public static const MOVE:String = "move";
        public static const ENTER:String = "enter";

        public function ComponentEvent(_arg1:String, _arg2:Boolean=false, _arg3:Boolean=false){
            super(_arg1, _arg2, _arg3);
        }
        override public function toString():String{
            return (formatToString("ComponentEvent", "type", "bubbles", "cancelable"));
        }
        override public function clone():Event{
            return (new ComponentEvent(type, bubbles, cancelable));
        }

    }
}//package fl.events 
