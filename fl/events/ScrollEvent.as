//Created by Action Script Viewer - http://www.buraks.com/asv
package fl.events {
    import flash.events.*;

    public class ScrollEvent extends Event {

        public static const SCROLL:String = "scroll";

        private var _direction:String;
        private var _delta:Number;
        private var _position:Number;

        public function ScrollEvent(_arg1:String, _arg2:Number, _arg3:Number){
            super(ScrollEvent.SCROLL, false, false);
            _direction = _arg1;
            _delta = _arg2;
            _position = _arg3;
        }
        public function get direction():String{
            return (_direction);
        }
        public function get delta():Number{
            return (_delta);
        }
        public function get position():Number{
            return (_position);
        }
        override public function toString():String{
            return (formatToString("ScrollEvent", "type", "bubbles", "cancelable", "direction", "delta", "position"));
        }
        override public function clone():Event{
            return (new ScrollEvent(_direction, _delta, _position));
        }

    }
}//package fl.events 
