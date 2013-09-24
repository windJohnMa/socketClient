//Created by Action Script Viewer - http://www.buraks.com/asv
package fl.managers {
    import fl.controls.*;
    import flash.display.*;
    import flash.utils.*;
    import fl.core.*;
    import flash.events.*;
    import flash.text.*;
    import flash.ui.*;

    public class FocusManager implements IFocusManager {

        private var _form:DisplayObjectContainer;
        private var focusableObjects:Dictionary;
        private var focusableCandidates:Array;
        private var activated:Boolean = false;
        private var calculateCandidates:Boolean = true;
        private var lastFocus:InteractiveObject;
        private var _showFocusIndicator:Boolean = true;
        private var lastAction:String;
        private var defButton:Button;
        private var _defaultButton:Button;
        private var _defaultButtonEnabled:Boolean = true;

        public function FocusManager(_arg1:DisplayObjectContainer){
            focusableObjects = new Dictionary(true);
            if (_arg1 != null){
                _form = _arg1;
                activate();
            };
        }
        private function addedHandler(_arg1:Event):void{
            var _local2:DisplayObject = DisplayObject(_arg1.target);
            if (_local2.stage){
                addFocusables(DisplayObject(_arg1.target));
            };
        }
        private function removedHandler(_arg1:Event):void{
            var _local2:int;
            var _local4:InteractiveObject;
            var _local3:DisplayObject = DisplayObject(_arg1.target);
            if ((((_local3 is IFocusManagerComponent)) && ((focusableObjects[_local3] == true)))){
                if (_local3 == lastFocus){
                    IFocusManagerComponent(lastFocus).drawFocus(false);
                    lastFocus = null;
                };
                _local3.removeEventListener(Event.TAB_ENABLED_CHANGE, tabEnabledChangeHandler, false);
                delete focusableObjects[_local3];
                calculateCandidates = true;
            } else {
                if ((((_local3 is InteractiveObject)) && ((focusableObjects[_local3] == true)))){
                    _local4 = (_local3 as InteractiveObject);
                    if (_local4){
                        if (_local4 == lastFocus){
                            lastFocus = null;
                        };
                        delete focusableObjects[_local4];
                        calculateCandidates = true;
                    };
                    _local3.addEventListener(Event.TAB_ENABLED_CHANGE, tabEnabledChangeHandler, false, 0, true);
                };
            };
            removeFocusables(_local3);
        }
        private function addFocusables(_arg1:DisplayObject, _arg2:Boolean=false):void{
            var focusable:* = null;
            var io:* = null;
            var doc:* = null;
            var docParent:* = null;
            var i:* = 0;
            var child:* = null;
            var o:* = _arg1;
            var skipTopLevel:Boolean = _arg2;
            if (!skipTopLevel){
                if ((o is IFocusManagerComponent)){
                    focusable = IFocusManagerComponent(o);
                    if (focusable.focusEnabled){
                        if (((focusable.tabEnabled) && (isTabVisible(o)))){
                            focusableObjects[o] = true;
                            calculateCandidates = true;
                        };
                        o.addEventListener(Event.TAB_ENABLED_CHANGE, tabEnabledChangeHandler, false, 0, true);
                        o.addEventListener(Event.TAB_INDEX_CHANGE, tabIndexChangeHandler, false, 0, true);
                    };
                } else {
                    if ((o is InteractiveObject)){
                        io = (o as InteractiveObject);
                        if (((((io) && (io.tabEnabled))) && ((findFocusManagerComponent(io) == io)))){
                            focusableObjects[io] = true;
                            calculateCandidates = true;
                        };
                        io.addEventListener(Event.TAB_ENABLED_CHANGE, tabEnabledChangeHandler, false, 0, true);
                        io.addEventListener(Event.TAB_INDEX_CHANGE, tabIndexChangeHandler, false, 0, true);
                    };
                };
            };
            if ((o is DisplayObjectContainer)){
                doc = DisplayObjectContainer(o);
                o.addEventListener(Event.TAB_CHILDREN_CHANGE, tabChildrenChangeHandler, false, 0, true);
                docParent = null;
                try {
                    docParent = doc.parent;
                } catch(se:SecurityError) {
                    docParent = null;
                };
                if ((((((doc is Stage)) || ((docParent is Stage)))) || (doc.tabChildren))){
                    i = 0;
                    while (i < doc.numChildren) {
                        try {
                            child = doc.getChildAt(i);
                            if (child != null){
                                addFocusables(doc.getChildAt(i));
                            };
                        } catch(error:SecurityError) {
                        };
                        i = (i + 1);
                    };
                };
            };
        }
        private function removeFocusables(_arg1:DisplayObject):void{
            var _local2:Object;
            var _local3:DisplayObject;
            if ((_arg1 is DisplayObjectContainer)){
                _arg1.removeEventListener(Event.TAB_CHILDREN_CHANGE, tabChildrenChangeHandler, false);
                _arg1.removeEventListener(Event.TAB_INDEX_CHANGE, tabIndexChangeHandler, false);
                for (_local2 in focusableObjects) {
                    _local3 = DisplayObject(_local2);
                    if (DisplayObjectContainer(_arg1).contains(_local3)){
                        if (_local3 == lastFocus){
                            lastFocus = null;
                        };
                        _local3.removeEventListener(Event.TAB_ENABLED_CHANGE, tabEnabledChangeHandler, false);
                        delete focusableObjects[_local2];
                        calculateCandidates = true;
                    };
                };
            };
        }
        private function isTabVisible(_arg1:DisplayObject):Boolean{
            var p:* = null;
            var o:* = _arg1;
            try {
                p = o.parent;
                while (((((p) && (!((p is Stage))))) && (!(((p.parent) && ((p.parent is Stage))))))) {
                    if (!p.tabChildren){
                        return (false);
                    };
                    p = p.parent;
                };
            } catch(se:SecurityError) {
            };
            return (true);
        }
        private function isValidFocusCandidate(_arg1:DisplayObject, _arg2:String):Boolean{
            var _local3:IFocusManagerGroup;
            if (!isEnabledAndVisible(_arg1)){
                return (false);
            };
            if ((_arg1 is IFocusManagerGroup)){
                _local3 = IFocusManagerGroup(_arg1);
                if (_arg2 == _local3.groupName){
                    return (false);
                };
            };
            return (true);
        }
        private function isEnabledAndVisible(_arg1:DisplayObject):Boolean{
            var formParent:* = null;
            var tf:* = null;
            var sb:* = null;
            var o:* = _arg1;
            try {
                formParent = DisplayObject(form).parent;
                while (o != formParent) {
                    if ((o is UIComponent)){
                        if (!UIComponent(o).enabled){
                            return (false);
                        };
                    } else {
                        if ((o is TextField)){
                            tf = TextField(o);
                            if ((((tf.type == TextFieldType.DYNAMIC)) || (!(tf.selectable)))){
                                return (false);
                            };
                        } else {
                            if ((o is SimpleButton)){
                                sb = SimpleButton(o);
                                if (!sb.enabled){
                                    return (false);
                                };
                            };
                        };
                    };
                    if (!o.visible){
                        return (false);
                    };
                    o = o.parent;
                };
            } catch(se:SecurityError) {
            };
            return (true);
        }
        private function tabEnabledChangeHandler(_arg1:Event):void{
            calculateCandidates = true;
            var _local2:InteractiveObject = InteractiveObject(_arg1.target);
            var _local3 = (focusableObjects[_local2] == true);
            if (_local2.tabEnabled){
                if (((!(_local3)) && (isTabVisible(_local2)))){
                    if (!(_local2 is IFocusManagerComponent)){
                        _local2.focusRect = false;
                    };
                    focusableObjects[_local2] = true;
                };
            } else {
                if (_local3){
                    delete focusableObjects[_local2];
                };
            };
        }
        private function tabIndexChangeHandler(_arg1:Event):void{
            calculateCandidates = true;
        }
        private function tabChildrenChangeHandler(_arg1:Event):void{
            if (_arg1.target != _arg1.currentTarget){
                return;
            };
            calculateCandidates = true;
            var _local2:DisplayObjectContainer = DisplayObjectContainer(_arg1.target);
            if (_local2.tabChildren){
                addFocusables(_local2, true);
            } else {
                removeFocusables(_local2);
            };
        }
        public function activate():void{
            if (activated){
                return;
            };
            addFocusables(form);
            form.addEventListener(Event.ADDED, addedHandler, false, 0, true);
            form.addEventListener(Event.REMOVED, removedHandler, false, 0, true);
            try {
                form.stage.addEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, mouseFocusChangeHandler, false, 0, true);
                form.stage.addEventListener(FocusEvent.KEY_FOCUS_CHANGE, keyFocusChangeHandler, false, 0, true);
                form.stage.addEventListener(Event.ACTIVATE, activateHandler, false, 0, true);
                form.stage.addEventListener(Event.DEACTIVATE, deactivateHandler, false, 0, true);
            } catch(se:SecurityError) {
                form.addEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, mouseFocusChangeHandler, false, 0, true);
                form.addEventListener(FocusEvent.KEY_FOCUS_CHANGE, keyFocusChangeHandler, false, 0, true);
                form.addEventListener(Event.ACTIVATE, activateHandler, false, 0, true);
                form.addEventListener(Event.DEACTIVATE, deactivateHandler, false, 0, true);
            };
            form.addEventListener(FocusEvent.FOCUS_IN, focusInHandler, true, 0, true);
            form.addEventListener(FocusEvent.FOCUS_OUT, focusOutHandler, true, 0, true);
            form.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler, false, 0, true);
            form.addEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler, true, 0, true);
            activated = true;
            if (lastFocus){
                setFocus(lastFocus);
            };
        }
        public function deactivate():void{
            if (!activated){
                return;
            };
            focusableObjects = new Dictionary(true);
            focusableCandidates = null;
            lastFocus = null;
            defButton = null;
            form.removeEventListener(Event.ADDED, addedHandler, false);
            form.removeEventListener(Event.REMOVED, removedHandler, false);
            try {
                form.stage.removeEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, mouseFocusChangeHandler, false);
                form.stage.removeEventListener(FocusEvent.KEY_FOCUS_CHANGE, keyFocusChangeHandler, false);
                form.stage.removeEventListener(Event.ACTIVATE, activateHandler, false);
                form.stage.removeEventListener(Event.DEACTIVATE, deactivateHandler, false);
            } catch(se:SecurityError) {
            };
            form.removeEventListener(FocusEvent.MOUSE_FOCUS_CHANGE, mouseFocusChangeHandler, false);
            form.removeEventListener(FocusEvent.KEY_FOCUS_CHANGE, keyFocusChangeHandler, false);
            form.removeEventListener(Event.ACTIVATE, activateHandler, false);
            form.removeEventListener(Event.DEACTIVATE, deactivateHandler, false);
            form.removeEventListener(FocusEvent.FOCUS_IN, focusInHandler, true);
            form.removeEventListener(FocusEvent.FOCUS_OUT, focusOutHandler, true);
            form.removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler, false);
            form.removeEventListener(KeyboardEvent.KEY_DOWN, keyDownHandler, true);
            activated = false;
        }
        private function focusInHandler(_arg1:FocusEvent):void{
            var _local3:Button;
            if (!activated){
                return;
            };
            var _local2:InteractiveObject = InteractiveObject(_arg1.target);
            if (form.contains(_local2)){
                lastFocus = findFocusManagerComponent(InteractiveObject(_local2));
                if ((lastFocus is Button)){
                    _local3 = Button(lastFocus);
                    if (defButton){
                        defButton.emphasized = false;
                        defButton = _local3;
                        _local3.emphasized = true;
                    };
                } else {
                    if (((defButton) && (!((defButton == _defaultButton))))){
                        defButton.emphasized = false;
                        defButton = _defaultButton;
                        _defaultButton.emphasized = true;
                    };
                };
            };
        }
        private function focusOutHandler(_arg1:FocusEvent):void{
            if (!activated){
                return;
            };
            var _local2:InteractiveObject = (_arg1.target as InteractiveObject);
        }
        private function activateHandler(_arg1:Event):void{
            if (!activated){
                return;
            };
            var _local2:InteractiveObject = InteractiveObject(_arg1.target);
            if (lastFocus){
                if ((lastFocus is IFocusManagerComponent)){
                    IFocusManagerComponent(lastFocus).setFocus();
                } else {
                    form.stage.focus = lastFocus;
                };
            };
            lastAction = "ACTIVATE";
        }
        private function deactivateHandler(_arg1:Event):void{
            if (!activated){
                return;
            };
            var _local2:InteractiveObject = InteractiveObject(_arg1.target);
        }
        private function mouseFocusChangeHandler(_arg1:FocusEvent):void{
            if (!activated){
                return;
            };
            if ((_arg1.relatedObject is TextField)){
                return;
            };
            _arg1.preventDefault();
        }
        private function keyFocusChangeHandler(_arg1:FocusEvent):void{
            if (!activated){
                return;
            };
            showFocusIndicator = true;
            if ((((((_arg1.keyCode == Keyboard.TAB)) || ((_arg1.keyCode == 0)))) && (!(_arg1.isDefaultPrevented())))){
                setFocusToNextObject(_arg1);
                _arg1.preventDefault();
            };
        }
        private function keyDownHandler(_arg1:KeyboardEvent):void{
            if (!activated){
                return;
            };
            if (_arg1.keyCode == Keyboard.TAB){
                lastAction = "KEY";
                if (calculateCandidates){
                    sortFocusableObjects();
                    calculateCandidates = false;
                };
            };
            if (((((((defaultButtonEnabled) && ((_arg1.keyCode == Keyboard.ENTER)))) && (defaultButton))) && (defButton.enabled))){
                sendDefaultButtonEvent();
            };
        }
        private function mouseDownHandler(_arg1:MouseEvent):void{
            if (!activated){
                return;
            };
            if (_arg1.isDefaultPrevented()){
                return;
            };
            var _local2:InteractiveObject = getTopLevelFocusTarget(InteractiveObject(_arg1.target));
            if (!_local2){
                return;
            };
            showFocusIndicator = false;
            if (((((!((_local2 == lastFocus))) || ((lastAction == "ACTIVATE")))) && (!((_local2 is TextField))))){
                setFocus(_local2);
            };
            lastAction = "MOUSEDOWN";
        }
        public function get defaultButton():Button{
            return (_defaultButton);
        }
        public function set defaultButton(_arg1:Button):void{
            var _local2:Button = (_arg1) ? Button(_arg1) : null;
            if (_local2 != _defaultButton){
                if (_defaultButton){
                    _defaultButton.emphasized = false;
                };
                if (defButton){
                    defButton.emphasized = false;
                };
                _defaultButton = _local2;
                defButton = _local2;
                if (_local2){
                    _local2.emphasized = true;
                };
            };
        }
        public function sendDefaultButtonEvent():void{
            defButton.dispatchEvent(new MouseEvent(MouseEvent.CLICK));
        }
        private function setFocusToNextObject(_arg1:FocusEvent):void{
            if (!hasFocusableObjects()){
                return;
            };
            var _local2:InteractiveObject = getNextFocusManagerComponent(_arg1.shiftKey);
            if (_local2){
                setFocus(_local2);
            };
        }
        private function hasFocusableObjects():Boolean{
            var _local1:Object;
            for (_local1 in focusableObjects) {
                return (true);
            };
            return (false);
        }
        public function getNextFocusManagerComponent(_arg1:Boolean=false):InteractiveObject{
            var _local8:IFocusManagerGroup;
            if (!hasFocusableObjects()){
                return (null);
            };
            if (calculateCandidates){
                sortFocusableObjects();
                calculateCandidates = false;
            };
            var _local2:DisplayObject = form.stage.focus;
            _local2 = DisplayObject(findFocusManagerComponent(InteractiveObject(_local2)));
            var _local3 = "";
            if ((_local2 is IFocusManagerGroup)){
                _local8 = IFocusManagerGroup(_local2);
                _local3 = _local8.groupName;
            };
            var _local4:int = getIndexOfFocusedObject(_local2);
            var _local5:Boolean;
            var _local6:int = _local4;
            if (_local4 == -1){
                if (_arg1){
                    _local4 = focusableCandidates.length;
                };
                _local5 = true;
            };
            var _local7:int = getIndexOfNextObject(_local4, _arg1, _local5, _local3);
            return (findFocusManagerComponent(focusableCandidates[_local7]));
        }
        private function getIndexOfFocusedObject(_arg1:DisplayObject):int{
            var _local2:int = focusableCandidates.length;
            var _local3:int;
            _local3 = 0;
            while (_local3 < _local2) {
                if (focusableCandidates[_local3] == _arg1){
                    return (_local3);
                };
                _local3++;
            };
            return (-1);
        }
        private function getIndexOfNextObject(_arg1:int, _arg2:Boolean, _arg3:Boolean, _arg4:String):int{
            var _local7:DisplayObject;
            var _local8:IFocusManagerGroup;
            var _local9:int;
            var _local10:DisplayObject;
            var _local11:IFocusManagerGroup;
            var _local5:int = focusableCandidates.length;
            var _local6:int = _arg1;
            while (true) {
                if (_arg2){
                    _arg1--;
                } else {
                    _arg1++;
                };
                if (_arg3){
                    if (((_arg2) && ((_arg1 < 0)))){
                        break;
                    };
                    if (((!(_arg2)) && ((_arg1 == _local5)))){
                        break;
                    };
                } else {
                    _arg1 = ((_arg1 + _local5) % _local5);
                    if (_local6 == _arg1){
                        break;
                    };
                };
                if (isValidFocusCandidate(focusableCandidates[_arg1], _arg4)){
                    _local7 = DisplayObject(findFocusManagerComponent(focusableCandidates[_arg1]));
                    if ((_local7 is IFocusManagerGroup)){
                        _local8 = IFocusManagerGroup(_local7);
                        _local9 = 0;
                        while (_local9 < focusableCandidates.length) {
                            _local10 = focusableCandidates[_local9];
                            if ((_local10 is IFocusManagerGroup)){
                                _local11 = IFocusManagerGroup(_local10);
                                if ((((_local11.groupName == _local8.groupName)) && (_local11.selected))){
                                    _arg1 = _local9;
                                    break;
                                };
                            };
                            _local9++;
                        };
                    };
                    return (_arg1);
                };
            };
            return (_arg1);
        }
        private function sortFocusableObjects():void{
            var _local1:Object;
            var _local2:InteractiveObject;
            focusableCandidates = [];
            for (_local1 in focusableObjects) {
                _local2 = InteractiveObject(_local1);
                if (((((_local2.tabIndex) && (!(isNaN(Number(_local2.tabIndex)))))) && ((_local2.tabIndex > 0)))){
                    sortFocusableObjectsTabIndex();
                    return;
                };
                focusableCandidates.push(_local2);
            };
            focusableCandidates.sort(sortByDepth);
        }
        private function sortFocusableObjectsTabIndex():void{
            var _local1:Object;
            var _local2:InteractiveObject;
            focusableCandidates = [];
            for (_local1 in focusableObjects) {
                _local2 = InteractiveObject(_local1);
                if (((_local2.tabIndex) && (!(isNaN(Number(_local2.tabIndex)))))){
                    focusableCandidates.push(_local2);
                };
            };
            focusableCandidates.sort(sortByTabIndex);
        }
        private function sortByDepth(_arg1:InteractiveObject, _arg2:InteractiveObject):Number{
            var index:* = 0;
            var tmp:* = null;
            var tmp2:* = null;
            var aa:* = _arg1;
            var bb:* = _arg2;
            var val1:* = "";
            var val2:* = "";
            var zeros:* = "0000";
            var a:* = DisplayObject(aa);
            var b:* = DisplayObject(bb);
            try {
                while (((!((a == DisplayObject(form)))) && (a.parent))) {
                    index = getChildIndex(a.parent, a);
                    tmp = index.toString(16);
                    if (tmp.length < 4){
                        tmp2 = (zeros.substring(0, (4 - tmp.length)) + tmp);
                    };
                    val1 = (tmp2 + val1);
                    a = a.parent;
                };
            } catch(se1:SecurityError) {
            };
            try {
                while (((!((b == DisplayObject(form)))) && (b.parent))) {
                    index = getChildIndex(b.parent, b);
                    tmp = index.toString(16);
                    if (tmp.length < 4){
                        tmp2 = (zeros.substring(0, (4 - tmp.length)) + tmp);
                    };
                    val2 = (tmp2 + val2);
                    b = b.parent;
                };
            } catch(se2:SecurityError) {
            };
            return (((val1 > val2)) ? 1 : ((val1 < val2)) ? -1 : 0);
        }
        private function getChildIndex(_arg1:DisplayObjectContainer, _arg2:DisplayObject):int{
            return (_arg1.getChildIndex(_arg2));
        }
        private function sortByTabIndex(_arg1:InteractiveObject, _arg2:InteractiveObject):int{
            return (((_arg1.tabIndex > _arg2.tabIndex)) ? 1 : ((_arg1.tabIndex < _arg2.tabIndex)) ? -1 : sortByDepth(_arg1, _arg2));
        }
        public function get defaultButtonEnabled():Boolean{
            return (_defaultButtonEnabled);
        }
        public function set defaultButtonEnabled(_arg1:Boolean):void{
            _defaultButtonEnabled = _arg1;
        }
        public function get nextTabIndex():int{
            return (0);
        }
        public function get showFocusIndicator():Boolean{
            return (_showFocusIndicator);
        }
        public function set showFocusIndicator(_arg1:Boolean):void{
            _showFocusIndicator = _arg1;
        }
        public function get form():DisplayObjectContainer{
            return (_form);
        }
        public function set form(_arg1:DisplayObjectContainer):void{
            _form = _arg1;
        }
        public function getFocus():InteractiveObject{
            var _local1:InteractiveObject = form.stage.focus;
            return (findFocusManagerComponent(_local1));
        }
        public function setFocus(_arg1:InteractiveObject):void{
            if ((_arg1 is IFocusManagerComponent)){
                IFocusManagerComponent(_arg1).setFocus();
            } else {
                form.stage.focus = _arg1;
            };
        }
        public function showFocus():void{
        }
        public function hideFocus():void{
        }
        public function findFocusManagerComponent(_arg1:InteractiveObject):InteractiveObject{
            var component:* = _arg1;
            var p:* = component;
            try {
                while (component) {
                    if ((((component is IFocusManagerComponent)) && (IFocusManagerComponent(component).focusEnabled))){
                        return (component);
                    };
                    component = component.parent;
                };
            } catch(se:SecurityError) {
            };
            return (p);
        }
        private function getTopLevelFocusTarget(_arg1:InteractiveObject):InteractiveObject{
            var o:* = _arg1;
            try {
                while (o != InteractiveObject(form)) {
                    if ((((((((o is IFocusManagerComponent)) && (IFocusManagerComponent(o).focusEnabled))) && (IFocusManagerComponent(o).mouseFocusEnabled))) && (UIComponent(o).enabled))){
                        return (o);
                    };
                    o = o.parent;
                    if (o == null){
                        break;
                    };
                };
            } catch(se:SecurityError) {
            };
            return (null);
        }

    }
}//package fl.managers 
