//Created by Action Script Viewer - http://www.buraks.com/asv
package bmhBase.woo {
    import bmhBase.debug.*;

    public class Debug {

        public static var no_error_id:int = 0;

        public static function trace(_arg1:String, _arg2:String){
            var _local3:LocalDebug = new LocalDebug(6);
            _local3.trace(((_arg1 + ":") + _arg2), Debug.no_error_id, false);
            _local3 = null;
        }
        public static function sendTrace(_arg1:String, _arg2:String, _arg3:int){
            var _local4:LocalDebug = new LocalDebug(6);
            _local4.trace(((_arg1 + ":出现严重错误") + _arg2), _arg3, true);
            _local4 = null;
        }

    }
}//package bmhBase.woo 
