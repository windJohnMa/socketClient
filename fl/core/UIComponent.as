//Created by Action Script Viewer - http://www.buraks.com/asv
package fl.core {
    import flash.display.*;
    import flash.utils.*;
    import flash.events.*;
    import fl.managers.*;
    import flash.text.*;
    import fl.events.*;
    import flash.system.*;

    public class UIComponent extends Sprite {

        public static var inCallLaterPhase:Boolean = false;
        private static var defaultStyles:Object = {
            focusRectSkin:"focusRectSkin",
            focusRectPadding:2,
            textFormat:new TextFormat("_sans", 11, 0, false, false, false, "", "", TextFormatAlign.LEFT, 0, 0, 0, 0),
            disabledTextFormat:new TextFormat("_sans", 11, 0x999999, false, false, false, "", "", TextFormatAlign.LEFT, 0, 0, 0, 0),
            defaultTextFormat:new TextFormat("_sans", 11, 0, false, false, false, "", "", TextFormatAlign.LEFT, 0, 0, 0, 0),
            defaultDisabledTextFormat:new TextFormat("_sans", 11, 0x999999, false, false, false, "", "", TextFormatAlign.LEFT, 0, 0, 0, 0)
        };
        private static var focusManagers:Dictionary = new Dictionary(true);
        private static var focusManagerUsers:Dictionary = new Dictionary(true);
        public static var createAccessibilityImplementation:Function;

        public const version:String = "3.0.3.1";

        public var focusTarget:IFocusManagerComponent;
        protected var isLivePreview:Boolean = false;
        private var tempText:TextField;
        protected var instanceStyles:Object;
        protected var sharedStyles:Object;
        protected var callLaterMethods:Dictionary;
        protected var invalidateFlag:Boolean = false;
        protected var _enabled:Boolean = true;
        protected var invalidHash:Object;
        protected var uiFocusRect:DisplayObject;
        protected var isFocused:Boolean = false;
        private var _focusEnabled:Boolean = true;
        private var _mouseFocusEnabled:Boolean = true;
        protected var _width:Number;
        protected var _height:Number;
        protected var _x:Number;
        protected var _y:Number;
        protected var startWidth:Number;
        protected var startHeight:Number;
        protected var _imeMode:String = null;
        protected var _oldIMEMode:String = null;
        protected var errorCaught:Boolean = false;
        protected var _inspector:Boolean = false;

        public function UIComponent(){
            instanceStyles = {};
            sharedStyles = {};
            invalidHash = {};
            callLaterMethods = new Dictionary();
            StyleManager.registerInstance(this);
            configUI();
            invalidate(InvalidationType.ALL);
            tabEnabled = (this is IFocusManagerComponent);
            focusRect = false;
            if (tabEnabled){
                addEventListener(FocusEvent.FOCUS_IN, focusInHandler);
                addEventListener(FocusEvent.FOCUS_OUT, focusOutHandler);
                addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler);
                addEventListener(KeyboardEvent.KEY_UP, keyUpHandler);
            };
            initializeFocusManager();
            addEventListener(Event.ENTER_FRAME, hookAccessibility, false, 0, true);
        }
        public static function getStyleDefinition():Object{
            return (defaultStyles);
        }
        public static function mergeStyles(... _args):Object{
            var _local5:Object;
            var _local6:String;
            var _local2:Object = {};
            var _local3:uint = _args.length;
            var _local4:uint;
            while (_local4 < _local3) {
                _local5 = _args[_local4];
                for (_local6 in _local5) {
                    if (_local2[_local6] != null){
                    } else {
                        _local2[_local6] = _args[_local4][_local6];
                    };
                };
                _local4++;
            };
            return (_local2);
        }

        public function get componentInspectorSetting():Boolean{
            return (_inspector);
        }
        public function set componentInspectorSetting(_arg1:Boolean):void{
            _inspector = _arg1;
            if (_inspector){
                beforeComponentParameters();
            } else {
                afterComponentParameters();
            };
        }
        protected function beforeComponentParameters():void{
        }
        protected function afterComponentParameters():void{
        }
        public function get enabled():Boolean{
            return (_enabled);
        }
        public function set enabled(_arg1:Boolean):void{
            if (_arg1 == _enabled){
                return;
            };
            _enabled = _arg1;
            invalidate(InvalidationType.STATE);
        }
        public function setSize(_arg1:Number, _arg2:Number):void{
            _width = _arg1;
            _height = _arg2;
            invalidate(InvalidationType.SIZE);
            dispatchEvent(new ComponentEvent(ComponentEvent.RESIZE, false));
        }
        override public function get width():Number{
            return (_width);
        }
        override public function set width(_arg1:Number):void{
            if (_width == _arg1){
                return;
            };
            setSize(_arg1, height);
        }
        override public function get height():Number{
            return (_height);
        }
        override public function set height(_arg1:Number):void{
            if (_height == _arg1){
                return;
            };
            setSize(width, _arg1);
        }
        public function setStyle(_arg1:String, _arg2:Object):void{
            if ((((instanceStyles[_arg1] === _arg2)) && (!((_arg2 is TextFormat))))){
                return;
            };
            instanceStyles[_arg1] = _arg2;
            invalidate(InvalidationType.STYLES);
        }
        public function clearStyle(_arg1:String):void{
            setStyle(_arg1, null);
        }
        public function getStyle(_arg1:String):Object{
            return (instanceStyles[_arg1]);
        }
        public function move(_arg1:Number, _arg2:Number):void{
            _x = _arg1;
            _y = _arg2;
            super.x = Math.round(_arg1);
            super.y = Math.round(_arg2);
            dispatchEvent(new ComponentEvent(ComponentEvent.MOVE));
        }
        override public function get x():Number{
            return ((isNaN(_x)) ? super.x : _x);
        }
        override public function set x(_arg1:Number):void{
            move(_arg1, _y);
        }
        override public function get y():Number{
            return ((isNaN(_y)) ? super.y : _y);
        }
        override public function set y(_arg1:Number):void{
            move(_x, _arg1);
        }
        override public function get scaleX():Number{
            return ((width / startWidth));
        }
        override public function set scaleX(_arg1:Number):void{
            setSize((startWidth * _arg1), height);
        }
        override public function get scaleY():Number{
            return ((height / startHeight));
        }
        override public function set scaleY(_arg1:Number):void{
            setSize(width, (startHeight * _arg1));
        }
        protected function getScaleY():Number{
            return (super.scaleY);
        }
        protected function setScaleY(_arg1:Number):void{
            super.scaleY = _arg1;
        }
        protected function getScaleX():Number{
            return (super.scaleX);
        }
        protected function setScaleX(_arg1:Number):void{
            super.scaleX = _arg1;
        }
        override public function get visible():Boolean{
            return (super.visible);
        }
        override public function set visible(_arg1:Boolean):void{
            if (super.visible == _arg1){
                return;
            };
            super.visible = _arg1;
            var _local2:String = (_arg1) ? ComponentEvent.SHOW : ComponentEvent.HIDE;
            dispatchEvent(new ComponentEvent(_local2, true));
        }
        public function validateNow():void{
            invalidate(InvalidationType.ALL, false);
            draw();
        }
        public function invalidate(_arg1:String="all", _arg2:Boolean=true):void{
            invalidHash[_arg1] = true;
            if (_arg2){
                this.callLater(draw);
            };
        }
        public function setSharedStyle(_arg1:String, _arg2:Object):void{
            if ((((sharedStyles[_arg1] === _arg2)) && (!((_arg2 is TextFormat))))){
                return;
            };
            sharedStyles[_arg1] = _arg2;
            if (instanceStyles[_arg1] == null){
                invalidate(InvalidationType.STYLES);
            };
        }
        public function get focusEnabled():Boolean{
            return (_focusEnabled);
        }
        public function set focusEnabled(_arg1:Boolean):void{
            _focusEnabled = _arg1;
        }
        public function get mouseFocusEnabled():Boolean{
            return (_mouseFocusEnabled);
        }
        public function set mouseFocusEnabled(_arg1:Boolean):void{
            _mouseFocusEnabled = _arg1;
        }
        public function get focusManager():IFocusManager{
            var o:* = this;
            while (o) {
                if (UIComponent.focusManagers[o] != null){
                    return (IFocusManager(UIComponent.focusManagers[o]));
                };
                try {
                    o = o.parent;
                } catch(se:SecurityError) {
                    return (null);
                };
            };
            return (null);
        }
        public function set focusManager(_arg1:IFocusManager):void{
            UIComponent.focusManagers[this] = _arg1;
        }
        public function drawFocus(_arg1:Boolean):void{
            var _local2:Number;
            isFocused = _arg1;
            if (((!((uiFocusRect == null))) && (contains(uiFocusRect)))){
                removeChild(uiFocusRect);
                uiFocusRect = null;
            };
            if (_arg1){
                uiFocusRect = (getDisplayObjectInstance(getStyleValue("focusRectSkin")) as Sprite);
                if (uiFocusRect == null){
                    return;
                };
                _local2 = Number(getStyleValue("focusRectPadding"));
                uiFocusRect.x = -(_local2);
                uiFocusRect.y = -(_local2);
                uiFocusRect.width = (width + (_local2 * 2));
                uiFocusRect.height = (height + (_local2 * 2));
                addChildAt(uiFocusRect, 0);
            };
        }
        public function setFocus():void{
            if (stage){
                stage.focus = this;
            };
        }
        public function getFocus():InteractiveObject{
            if (stage){
                return (stage.focus);
            };
            return (null);
        }
        protected function setIMEMode(_arg1:Boolean){
            var enabled:* = _arg1;
            if (_imeMode != null){
                if (enabled){
                    IME.enabled = true;
                    _oldIMEMode = IME.conversionMode;
                    try {
                        if (((!(errorCaught)) && (!((IME.conversionMode == IMEConversionMode.UNKNOWN))))){
                            IME.conversionMode = _imeMode;
                        };
                        errorCaught = false;
                    } catch(e:Error) {
                        errorCaught = true;
                        throw (new Error(("IME mode not supported: " + _imeMode)));
                    };
                } else {
                    if (((!((IME.conversionMode == IMEConversionMode.UNKNOWN))) && (!((_oldIMEMode == IMEConversionMode.UNKNOWN))))){
                        IME.conversionMode = _oldIMEMode;
                    };
                    IME.enabled = false;
                };
            };
        }
        public function drawNow():void{
            draw();
        }
        protected function configUI():void{
            isLivePreview = checkLivePreview();
            var _local1:Number = rotation;
            rotation = 0;
            var _local2:Number = super.width;
            var _local3:Number = super.height;
            var _local4 = 1;
            super.scaleY = _local4;
            super.scaleX = _local4;
            setSize(_local2, _local3);
            move(super.x, super.y);
            rotation = _local1;
            startWidth = _local2;
            startHeight = _local3;
            if (numChildren > 0){
                removeChildAt(0);
            };
        }
        protected function checkLivePreview():Boolean{
            var className:* = null;
            if (parent == null){
                return (false);
            };
            try {
                className = getQualifiedClassName(parent);
            } catch(e:Error) {
            };
            return ((className == "fl.livepreview::LivePreviewParent"));
        }
        protected function isInvalid(_arg1:String, ... _args):Boolean{
            if (((invalidHash[_arg1]) || (invalidHash[InvalidationType.ALL]))){
                return (true);
            };
            while (_args.length > 0) {
                if (invalidHash[_args.pop()]){
                    return (true);
                };
            };
            return (false);
        }
        protected function validate():void{
            invalidHash = {};
        }
        protected function draw():void{
            if (isInvalid(InvalidationType.SIZE, InvalidationType.STYLES)){
                if (((isFocused) && (focusManager.showFocusIndicator))){
                    drawFocus(true);
                };
            };
            validate();
        }
        protected function getDisplayObjectInstance(_arg1:Object):DisplayObject{
            var skin:* = _arg1;
            var classDef:* = null;
            if ((skin is Class)){
                return ((new (skin)() as DisplayObject));
            };
            if ((skin is DisplayObject)){
                (skin as DisplayObject).x = 0;
                (skin as DisplayObject).y = 0;
                return ((skin as DisplayObject));
            };
            try {
                classDef = getDefinitionByName(skin.toString());
            } catch(e:Error) {
                try {
                    classDef = (loaderInfo.applicationDomain.getDefinition(skin.toString()) as Object);
                } catch(e:Error) {
                };
            };
            if (classDef == null){
                return (null);
            };
            return ((new (classDef)() as DisplayObject));
        }
        protected function getStyleValue(_arg1:String):Object{
            return (((instanceStyles[_arg1])==null) ? sharedStyles[_arg1] : instanceStyles[_arg1]);
        }
        protected function copyStylesToChild(_arg1:UIComponent, _arg2:Object):void{
            var _local3:String;
            for (_local3 in _arg2) {
                _arg1.setStyle(_local3, getStyleValue(_arg2[_local3]));
            };
        }
        protected function callLater(_arg1:Function):void{
            var fn:* = _arg1;
            if (inCallLaterPhase){
                return;
            };
            callLaterMethods[fn] = true;
            if (stage != null){
                try {
                    stage.addEventListener(Event.RENDER, callLaterDispatcher, false, 0, true);
                    stage.invalidate();
                } catch(se:SecurityError) {
                    addEventListener(Event.ENTER_FRAME, callLaterDispatcher, false, 0, true);
                };
            } else {
                addEventListener(Event.ADDED_TO_STAGE, callLaterDispatcher, false, 0, true);
            };
        }
        private function callLaterDispatcher(_arg1:Event):void{
            var method:* = null;
            var event:* = _arg1;
            if (event.type == Event.ADDED_TO_STAGE){
                try {
                    removeEventListener(Event.ADDED_TO_STAGE, callLaterDispatcher);
                    stage.addEventListener(Event.RENDER, callLaterDispatcher, false, 0, true);
                    stage.invalidate();
                    return;
                } catch(se1:SecurityError) {
                    addEventListener(Event.ENTER_FRAME, callLaterDispatcher, false, 0, true);
                };
            } else {
                event.target.removeEventListener(Event.RENDER, callLaterDispatcher);
                event.target.removeEventListener(Event.ENTER_FRAME, callLaterDispatcher);
                try {
                    if (stage == null){
                        addEventListener(Event.ADDED_TO_STAGE, callLaterDispatcher, false, 0, true);
                        return;
                    };
                } catch(se2:SecurityError) {
                };
            };
            inCallLaterPhase = true;
            var methods:* = callLaterMethods;
            for (method in methods) {
                method();
                delete methods[method];
            };
            inCallLaterPhase = false;
        }
        private function initializeFocusManager():void{
            var _local1:IFocusManager;
            var _local2:Dictionary;
            if (stage == null){
                addEventListener(Event.ADDED_TO_STAGE, addedHandler, false, 0, true);
            } else {
                createFocusManager();
                _local1 = focusManager;
                if (_local1 != null){
                    _local2 = focusManagerUsers[_local1];
                    if (_local2 == null){
                        _local2 = new Dictionary(true);
                        focusManagerUsers[_local1] = _local2;
                    };
                    _local2[this] = true;
                };
            };
            addEventListener(Event.REMOVED_FROM_STAGE, removedHandler);
        }
        private function addedHandler(_arg1:Event):void{
            removeEventListener(Event.ADDED_TO_STAGE, addedHandler);
            initializeFocusManager();
        }
        private function removedHandler(_arg1:Event):void{
            var _local3:Dictionary;
            var _local4:Boolean;
            var _local5:*;
            var _local6:*;
            var _local7:IFocusManager;
            removeEventListener(Event.REMOVED_FROM_STAGE, removedHandler);
            addEventListener(Event.ADDED_TO_STAGE, addedHandler);
            var _local2:IFocusManager = focusManager;
            if (_local2 != null){
                _local3 = focusManagerUsers[_local2];
                if (_local3 != null){
                    delete _local3[this];
                    _local4 = true;
                    for (_local5 in _local3) {
                        _local4 = false;
                        break;
                    };
                    if (_local4){
                        delete focusManagerUsers[_local2];
                        _local3 = null;
                    };
                };
                if (_local3 == null){
                    _local2.deactivate();
                    for (_local6 in focusManagers) {
                        _local7 = focusManagers[_local6];
                        if (_local2 == _local7){
                            delete focusManagers[_local6];
                        };
                    };
                };
            };
        }
        protected function createFocusManager():void{
            var stageAccessOK:* = true;
            try {
                stage.getChildAt(0);
            } catch(se:SecurityError) {
                stageAccessOK = false;
            };
            var myTopLevel:* = null;
            if (stageAccessOK){
                myTopLevel = stage;
            } else {
                myTopLevel = this;
                try {
                    while (myTopLevel.parent != null) {
                        myTopLevel = myTopLevel.parent;
                    };
                } catch(se:SecurityError) {
                };
            };
            if (focusManagers[myTopLevel] == null){
                focusManagers[myTopLevel] = new FocusManager(myTopLevel);
            };
        }
        protected function isOurFocus(_arg1:DisplayObject):Boolean{
            return ((_arg1 == this));
        }
        protected function focusInHandler(_arg1:FocusEvent):void{
            var _local2:IFocusManager;
            if (isOurFocus((_arg1.target as DisplayObject))){
                _local2 = focusManager;
                if (((_local2) && (_local2.showFocusIndicator))){
                    drawFocus(true);
                    isFocused = true;
                };
            };
        }
        protected function focusOutHandler(_arg1:FocusEvent):void{
            if (isOurFocus((_arg1.target as DisplayObject))){
                drawFocus(false);
                isFocused = false;
            };
        }
        protected function keyDownHandler(_arg1:KeyboardEvent):void{
        }
        protected function keyUpHandler(_arg1:KeyboardEvent):void{
        }
        protected function hookAccessibility(_arg1:Event):void{
            removeEventListener(Event.ENTER_FRAME, hookAccessibility);
            initializeAccessibility();
        }
        protected function initializeAccessibility():void{
            if (UIComponent.createAccessibilityImplementation != null){
                UIComponent.createAccessibilityImplementation(this);
            };
        }

    }
}//package fl.core 
