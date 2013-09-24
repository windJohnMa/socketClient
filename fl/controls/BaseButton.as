//Created by Action Script Viewer - http://www.buraks.com/asv
package fl.controls {
    import flash.display.*;
    import flash.utils.*;
    import fl.core.*;
    import flash.events.*;
    import fl.events.*;

    public class BaseButton extends UIComponent {

        private static var defaultStyles:Object = {
            upSkin:"Button_upSkin",
            downSkin:"Button_downSkin",
            overSkin:"Button_overSkin",
            disabledSkin:"Button_disabledSkin",
            selectedDisabledSkin:"Button_selectedDisabledSkin",
            selectedUpSkin:"Button_selectedUpSkin",
            selectedDownSkin:"Button_selectedDownSkin",
            selectedOverSkin:"Button_selectedOverSkin",
            focusRectSkin:null,
            focusRectPadding:null,
            repeatDelay:500,
            repeatInterval:35
        };

        protected var background:DisplayObject;
        protected var mouseState:String;
        protected var _selected:Boolean = false;
        protected var _autoRepeat:Boolean = false;
        protected var pressTimer:Timer;
        private var _mouseStateLocked:Boolean = false;
        private var unlockedMouseState:String;

        public function BaseButton(){
            buttonMode = true;
            mouseChildren = false;
            useHandCursor = false;
            setupMouseEvents();
            setMouseState("up");
            pressTimer = new Timer(1, 0);
            pressTimer.addEventListener(TimerEvent.TIMER, buttonDown, false, 0, true);
        }
        public static function getStyleDefinition():Object{
            return (defaultStyles);
        }

        override public function get enabled():Boolean{
            return (super.enabled);
        }
        override public function set enabled(_arg1:Boolean):void{
            super.enabled = _arg1;
            mouseEnabled = _arg1;
        }
        public function get selected():Boolean{
            return (_selected);
        }
        public function set selected(_arg1:Boolean):void{
            if (_selected == _arg1){
                return;
            };
            _selected = _arg1;
            invalidate(InvalidationType.STATE);
        }
        public function get autoRepeat():Boolean{
            return (_autoRepeat);
        }
        public function set autoRepeat(_arg1:Boolean):void{
            _autoRepeat = _arg1;
        }
        public function set mouseStateLocked(_arg1:Boolean):void{
            _mouseStateLocked = _arg1;
            if (_arg1 == false){
                setMouseState(unlockedMouseState);
            } else {
                unlockedMouseState = mouseState;
            };
        }
        public function setMouseState(_arg1:String):void{
            if (_mouseStateLocked){
                unlockedMouseState = _arg1;
                return;
            };
            if (mouseState == _arg1){
                return;
            };
            mouseState = _arg1;
            invalidate(InvalidationType.STATE);
        }
        protected function setupMouseEvents():void{
            addEventListener(MouseEvent.ROLL_OVER, mouseEventHandler, false, 0, true);
            addEventListener(MouseEvent.MOUSE_DOWN, mouseEventHandler, false, 0, true);
            addEventListener(MouseEvent.MOUSE_UP, mouseEventHandler, false, 0, true);
            addEventListener(MouseEvent.ROLL_OUT, mouseEventHandler, false, 0, true);
        }
        protected function mouseEventHandler(_arg1:MouseEvent):void{
            if (_arg1.type == MouseEvent.MOUSE_DOWN){
                setMouseState("down");
                startPress();
            } else {
                if ((((_arg1.type == MouseEvent.ROLL_OVER)) || ((_arg1.type == MouseEvent.MOUSE_UP)))){
                    setMouseState("over");
                    endPress();
                } else {
                    if (_arg1.type == MouseEvent.ROLL_OUT){
                        setMouseState("up");
                        endPress();
                    };
                };
            };
        }
        protected function startPress():void{
            if (_autoRepeat){
                pressTimer.delay = Number(getStyleValue("repeatDelay"));
                pressTimer.start();
            };
            dispatchEvent(new ComponentEvent(ComponentEvent.BUTTON_DOWN, true));
        }
        protected function buttonDown(_arg1:TimerEvent):void{
            if (!_autoRepeat){
                endPress();
                return;
            };
            if (pressTimer.currentCount == 1){
                pressTimer.delay = Number(getStyleValue("repeatInterval"));
            };
            dispatchEvent(new ComponentEvent(ComponentEvent.BUTTON_DOWN, true));
        }
        protected function endPress():void{
            pressTimer.reset();
        }
        override protected function draw():void{
            if (isInvalid(InvalidationType.STYLES, InvalidationType.STATE)){
                drawBackground();
                invalidate(InvalidationType.SIZE, false);
            };
            if (isInvalid(InvalidationType.SIZE)){
                drawLayout();
            };
            super.draw();
        }
        protected function drawBackground():void{
            var _local1:String = (enabled) ? mouseState : "disabled";
            if (selected){
                _local1 = (("selected" + _local1.substr(0, 1).toUpperCase()) + _local1.substr(1));
            };
            _local1 = (_local1 + "Skin");
            var _local2:DisplayObject = background;
            background = getDisplayObjectInstance(getStyleValue(_local1));
            addChildAt(background, 0);
            if (((!((_local2 == null))) && (!((_local2 == background))))){
                removeChild(_local2);
            };
        }
        protected function drawLayout():void{
            background.width = width;
            background.height = height;
        }

    }
}//package fl.controls 
