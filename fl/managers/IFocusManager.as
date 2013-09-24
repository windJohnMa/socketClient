//Created by Action Script Viewer - http://www.buraks.com/asv
package fl.managers {
    import fl.controls.*;
    import flash.display.*;

    public interface IFocusManager {

        function get defaultButton():Button;
        function set defaultButton(_arg1:Button):void;
        function get defaultButtonEnabled():Boolean;
        function set defaultButtonEnabled(_arg1:Boolean):void;
        function get nextTabIndex():int;
        function get showFocusIndicator():Boolean;
        function set showFocusIndicator(_arg1:Boolean):void;
        function getFocus():InteractiveObject;
        function setFocus(_arg1:InteractiveObject):void;
        function showFocus():void;
        function hideFocus():void;
        function activate():void;
        function deactivate():void;
        function findFocusManagerComponent(_arg1:InteractiveObject):InteractiveObject;
        function getNextFocusManagerComponent(_arg1:Boolean=false):InteractiveObject;
        function get form():DisplayObjectContainer;
        function set form(_arg1:DisplayObjectContainer):void;

    }
}//package fl.managers 
