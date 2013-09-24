﻿//Created by Action Script Viewer - http://www.buraks.com/asv
package fl.controls {
    import flash.display.*;
    import fl.core.*;
    import fl.managers.*;

    public class Button extends LabelButton implements IFocusManagerComponent {

        private static var defaultStyles:Object = {
            emphasizedSkin:"Button_emphasizedSkin",
            emphasizedPadding:2
        };
        public static var createAccessibilityImplementation:Function;

        protected var _emphasized:Boolean = false;
        protected var emphasizedBorder:DisplayObject;

        public static function getStyleDefinition():Object{
            return (UIComponent.mergeStyles(LabelButton.getStyleDefinition(), defaultStyles));
        }

        public function get emphasized():Boolean{
            return (_emphasized);
        }
        public function set emphasized(_arg1:Boolean):void{
            _emphasized = _arg1;
            invalidate(InvalidationType.STYLES);
        }
        override protected function draw():void{
            if (((isInvalid(InvalidationType.STYLES)) || (isInvalid(InvalidationType.SIZE)))){
                drawEmphasized();
            };
            super.draw();
            if (emphasizedBorder != null){
                setChildIndex(emphasizedBorder, (numChildren - 1));
            };
        }
        protected function drawEmphasized():void{
            var _local2:Number;
            if (emphasizedBorder != null){
                removeChild(emphasizedBorder);
            };
            emphasizedBorder = null;
            if (!_emphasized){
                return;
            };
            var _local1:Object = getStyleValue("emphasizedSkin");
            if (_local1 != null){
                emphasizedBorder = getDisplayObjectInstance(_local1);
            };
            if (emphasizedBorder != null){
                addChildAt(emphasizedBorder, 0);
                _local2 = Number(getStyleValue("emphasizedPadding"));
                emphasizedBorder.x = (emphasizedBorder.y = -(_local2));
                emphasizedBorder.width = (width + (_local2 * 2));
                emphasizedBorder.height = (height + (_local2 * 2));
            };
        }
        override public function drawFocus(_arg1:Boolean):void{
            var _local2:Number;
            var _local3:*;
            super.drawFocus(_arg1);
            if (_arg1){
                _local2 = Number(getStyleValue("emphasizedPadding"));
                if ((((_local2 < 0)) || (!(_emphasized)))){
                    _local2 = 0;
                };
                _local3 = getStyleValue("focusRectPadding");
                _local3 = ((_local3)==null) ? 2 : _local3;
                _local3 = (_local3 + _local2);
                uiFocusRect.x = -(_local3);
                uiFocusRect.y = -(_local3);
                uiFocusRect.width = (width + (_local3 * 2));
                uiFocusRect.height = (height + (_local3 * 2));
            };
        }
        override protected function initializeAccessibility():void{
            if (Button.createAccessibilityImplementation != null){
                Button.createAccessibilityImplementation(this);
            };
        }

    }
}//package fl.controls 
