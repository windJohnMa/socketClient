//Created by Action Script Viewer - http://www.buraks.com/asv
package fl.controls {
    import flash.display.*;
    import fl.core.*;
    import flash.events.*;
    import fl.events.*;

    public class UIScrollBar extends ScrollBar {

        private static var defaultStyles:Object = {};

        protected var _scrollTarget:DisplayObject;
        protected var inEdit:Boolean = false;
        protected var inScroll:Boolean = false;
        protected var _targetScrollProperty:String;
        protected var _targetMaxScrollProperty:String;

        public static function getStyleDefinition():Object{
            return (UIComponent.mergeStyles(defaultStyles, ScrollBar.getStyleDefinition()));
        }

        override public function set minScrollPosition(_arg1:Number):void{
            super.minScrollPosition = ((_arg1)<0) ? 0 : _arg1;
        }
        override public function set maxScrollPosition(_arg1:Number):void{
            var _local2:Number = _arg1;
            if (_scrollTarget != null){
                _local2 = Math.min(_local2, _scrollTarget[_targetMaxScrollProperty]);
            };
            super.maxScrollPosition = _local2;
        }
        public function get scrollTarget():DisplayObject{
            return (_scrollTarget);
        }
        public function set scrollTarget(_arg1:DisplayObject):void{
            var target:* = _arg1;
            if (_scrollTarget != null){
                _scrollTarget.removeEventListener(Event.CHANGE, handleTargetChange, false);
                _scrollTarget.removeEventListener(TextEvent.TEXT_INPUT, handleTargetChange, false);
                _scrollTarget.removeEventListener(Event.SCROLL, handleTargetScroll, false);
            };
            _scrollTarget = target;
            var blockProg:* = null;
            var textDir:* = null;
            var hasPixelVS:* = false;
            if (_scrollTarget != null){
                try {
                    if (_scrollTarget.hasOwnProperty("blockProgression")){
                        blockProg = _scrollTarget["blockProgression"];
                    };
                    if (_scrollTarget.hasOwnProperty("direction")){
                        textDir = _scrollTarget["direction"];
                    };
                    if (_scrollTarget.hasOwnProperty("pixelScrollV")){
                        hasPixelVS = true;
                    };
                } catch(e:Error) {
                    blockProg = null;
                    textDir = null;
                };
            };
            var scrollHoriz:* = (this.direction == ScrollBarDirection.HORIZONTAL);
            var rot:* = Math.abs(this.rotation);
            if (((scrollHoriz) && ((((blockProg == "rl")) || ((textDir == "rtl")))))){
                if ((((getScaleY() > 0)) && ((rotation == 90)))){
                    x = (x + width);
                };
                setScaleY(-1);
            } else {
                if (((((!(scrollHoriz)) && ((blockProg == "rl")))) && ((textDir == "rtl")))){
                    if ((((getScaleY() > 0)) && (!((rotation == 90))))){
                        y = (y + height);
                    };
                    setScaleY(-1);
                } else {
                    if (getScaleY() < 0){
                        if (scrollHoriz){
                            if (rotation == 90){
                                x = (x - width);
                            };
                        } else {
                            if (rotation != 90){
                                y = (y - height);
                            };
                        };
                    };
                    setScaleY(1);
                };
            };
            setTargetScrollProperties(scrollHoriz, blockProg, hasPixelVS);
            if (_scrollTarget != null){
                _scrollTarget.addEventListener(Event.CHANGE, handleTargetChange, false, 0, true);
                _scrollTarget.addEventListener(TextEvent.TEXT_INPUT, handleTargetChange, false, 0, true);
                _scrollTarget.addEventListener(Event.SCROLL, handleTargetScroll, false, 0, true);
            };
            invalidate(InvalidationType.DATA);
        }
        public function get scrollTargetName():String{
            return (_scrollTarget.name);
        }
        public function set scrollTargetName(_arg1:String):void{
            var target:* = _arg1;
            try {
                scrollTarget = parent.getChildByName(target);
            } catch(error:Error) {
                throw (new Error("ScrollTarget not found, or is not a valid target"));
            };
        }
        override public function get direction():String{
            return (super.direction);
        }
        override public function set direction(_arg1:String):void{
            var _local2:DisplayObject;
            if (isLivePreview){
                return;
            };
            if (((!(componentInspectorSetting)) && (!((_scrollTarget == null))))){
                _local2 = _scrollTarget;
                scrollTarget = null;
            };
            super.direction = _arg1;
            if (_local2 != null){
                scrollTarget = _local2;
            } else {
                updateScrollTargetProperties();
            };
        }
        public function update():void{
            inEdit = true;
            updateScrollTargetProperties();
            inEdit = false;
        }
        override protected function draw():void{
            if (isInvalid(InvalidationType.DATA)){
                updateScrollTargetProperties();
            };
            super.draw();
        }
        protected function updateScrollTargetProperties():void{
            var blockProg:* = null;
            var hasPixelVS:* = false;
            var pageSize:* = NaN;
            var minScroll:* = NaN;
            var minScrollVValue:* = undefined;
            if (_scrollTarget == null){
                setScrollProperties(pageSize, minScrollPosition, maxScrollPosition);
                scrollPosition = 0;
            } else {
                blockProg = null;
                hasPixelVS = false;
                try {
                    if (_scrollTarget.hasOwnProperty("blockProgression")){
                        blockProg = _scrollTarget["blockProgression"];
                    };
                    if (_scrollTarget.hasOwnProperty("pixelScrollV")){
                        hasPixelVS = true;
                    };
                } catch(e1:Error) {
                };
                setTargetScrollProperties((this.direction == ScrollBarDirection.HORIZONTAL), blockProg, hasPixelVS);
                if (_targetScrollProperty == "scrollH"){
                    minScroll = 0;
                    try {
                        if (((_scrollTarget.hasOwnProperty("controller")) && (_scrollTarget["controller"].hasOwnProperty("compositionWidth")))){
                            pageSize = _scrollTarget["controller"]["compositionWidth"];
                        } else {
                            pageSize = _scrollTarget.width;
                        };
                    } catch(e2:Error) {
                        pageSize = _scrollTarget.width;
                    };
                } else {
                    try {
                        if (blockProg != null){
                            minScrollVValue = _scrollTarget["pixelMinScrollV"];
                            if ((minScrollVValue is int)){
                                minScroll = minScrollVValue;
                            } else {
                                minScroll = 1;
                            };
                        } else {
                            minScroll = 1;
                        };
                    } catch(e3:Error) {
                        minScroll = 1;
                    };
                    pageSize = 10;
                };
                setScrollProperties(pageSize, minScroll, scrollTarget[_targetMaxScrollProperty]);
                scrollPosition = _scrollTarget[_targetScrollProperty];
            };
        }
        override public function setScrollProperties(_arg1:Number, _arg2:Number, _arg3:Number, _arg4:Number=0):void{
            var _local5:Number = _arg3;
            var _local6:Number = ((_arg2)<0) ? 0 : _arg2;
            if (_scrollTarget != null){
                _local5 = Math.min(_arg3, _scrollTarget[_targetMaxScrollProperty]);
            };
            super.setScrollProperties(_arg1, _local6, _local5, _arg4);
        }
        override public function setScrollPosition(_arg1:Number, _arg2:Boolean=true):void{
            super.setScrollPosition(_arg1, _arg2);
            if (!_scrollTarget){
                inScroll = false;
                return;
            };
            updateTargetScroll();
        }
        protected function updateTargetScroll(_arg1:ScrollEvent=null):void{
            if (inEdit){
                return;
            };
            _scrollTarget[_targetScrollProperty] = scrollPosition;
        }
        protected function handleTargetChange(_arg1:Event):void{
            inEdit = true;
            setScrollPosition(_scrollTarget[_targetScrollProperty], true);
            updateScrollTargetProperties();
            inEdit = false;
        }
        protected function handleTargetScroll(_arg1:Event):void{
            if (inDrag){
                return;
            };
            if (!enabled){
                return;
            };
            inEdit = true;
            updateScrollTargetProperties();
            scrollPosition = _scrollTarget[_targetScrollProperty];
            inEdit = false;
        }
        private function setTargetScrollProperties(_arg1:Boolean, _arg2:String, _arg3:Boolean=false):void{
            if (_arg2 == "rl"){
                if (_arg1){
                    _targetScrollProperty = (_arg3) ? "pixelScrollV" : "scrollV";
                    _targetMaxScrollProperty = (_arg3) ? "pixelMaxScrollV" : "maxScrollV";
                } else {
                    _targetScrollProperty = "scrollH";
                    _targetMaxScrollProperty = "maxScrollH";
                };
            } else {
                if (_arg1){
                    _targetScrollProperty = "scrollH";
                    _targetMaxScrollProperty = "maxScrollH";
                } else {
                    _targetScrollProperty = (_arg3) ? "pixelScrollV" : "scrollV";
                    _targetMaxScrollProperty = (_arg3) ? "pixelMaxScrollV" : "maxScrollV";
                };
            };
        }

    }
}//package fl.controls 
