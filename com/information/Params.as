//Created by Action Script Viewer - http://www.buraks.com/asv
package com.information {
    import flash.external.*;

    public class Params {

        public static const videoW:Number = 460;
        public static const videoH:Number = 350;
        public static const videoX:Number = 3;
        public static const videoY:Number = 28;
        public static const cameraBandWidth_normal:Number = 0x7800;
        public static const cameraBandWidth_heigh:Number = 0x7800;
        public static const camera_quality_normal:Number = 0;
        public static const camera_quality_heigh:Number = 0;
        public static const camera_frameRate:Number = 15;
        public static const cam_width = 320;
        public static const cam_height = 240;
        public static const buffTime:Number = 3;
        public static const spare_server:String = "192.168.2.20";
        public static const upload_file_add:String = "http://192.168.2.60:81/PicUpLoad.aspx";

        public static function getParam(_arg1:String):String{
            var _local3:Array;
            var _local2:* = ExternalInterface.call("window.location.href.toString");
            if (_local2 != null){
                _local2 = _local2.slice(_local2.lastIndexOf(_arg1));
                _local3 = _local2.split("?");
                return (_local3[0].split("&")[0].split("#")[0].slice((_arg1.length + 1)));
            };
            return ("none");
        }
        public static function getJSVar(_arg1:String):String{
            var _local2:String = ("getJsVarByName" + new Date().getTime());
            ExternalInterface.call("eval", (((("function " + _local2) + "(){return ") + _arg1) + ";}"));
            return (String(ExternalInterface.call(_local2)));
        }

    }
}//package com.information 
