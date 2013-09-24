//Created by Action Script Viewer - http://www.buraks.com/asv
package com {
    import flash.display.*;
    import flash.events.*;
    import bmhBase.woo.*;
    import com.information.*;
    import flash.net.*;
    import flash.external.*;

    public class xmlAnaly extends Sprite {

        public var myIp;
        public var liveAddr;
        public var host1;
        public var host2;
        public var port;
        public var backAddr;
        public var liveUp;
        public var liveDown;
        public var xmlloader;
        public var roomId;
        public var delay;
        public var chatHost;
        public var chatPort;
        public var testArr:Array;

        public function xmlAnaly(){
            var xmlURL:* = undefined;
            super();
            var backURL:* = "config.xml";
            var date:* = new Date();
            var yea:* = String(date.getFullYear());
            var mon:* = String((date.getMonth() + 1));
            var day:* = String(date.getDate());
            if (mon.length < 2){
                mon = ("0" + mon);
            };
            if (day.length < 2){
                day = ("0" + day);
            };
            var xmlHead:* = "http://live.baomihua.com/config/";
            xmlURL = (((((xmlHead + "?") + yea) + mon) + day) + int((Math.random() * 9999)));
            this.xmlloader = new URLLoader();
            this.roomId = Params.getJSVar("Page.masterRoomID");
            if (this.isDebug){
                this.xmlload(backURL);
            } else {
                this.xmlload(xmlURL);
            };
            this.xmlloader.addEventListener(IOErrorEvent.IO_ERROR, function (){
                if (!isDebug){
                    Debug.sendTrace("", ("xml加载失败，没有找到文件，xml地址：" + xmlURL), 1);
                };
            });
            this.xmlloader.addEventListener(SecurityErrorEvent.SECURITY_ERROR, function (){
                if (!isDebug){
                    Debug.sendTrace("", ("xml加载失败，安全策略错误，xml地址：" + xmlURL), 1);
                };
            });
            this.xmlloader.addEventListener(Event.COMPLETE, this.xmlloaded);
        }
        private function get isDebug():Boolean{
            var _local1:String = String(ExternalInterface.call("window.location.href.toString"));
            if (_local1.indexOf("baomihua.com") != -1){
                Debug.trace("xmlLoader", "当前为正式状态");
                return (false);
            };
            Debug.trace("xmlLoader", "当前为调试状态");
            return (true);
        }
        public function chatport():int{
            return (this.chatPort);
        }
        public function chathost():String{
            return (this.chatHost);
        }
        private function xmlload(_arg1){
            var _local3:URLVariables;
            var _local2:URLRequest = new URLRequest(_arg1);
            if (this.isDebug){
                _local2.method = "get";
            } else {
                _local2.method = "post";
                _local3 = new URLVariables();
                _local3.roomId = this.roomId;
                _local2.data = _local3;
            };
            this.xmlloader.load(_local2);
        }
        private function xmlloaded(_arg1:Event){
            var _local3:*;
            trace(3);
            var _local2:XML = XML(_arg1.currentTarget.data);
            Debug.trace("", String(_local2));
            this.myIp = String(_local2.ip);
            this.liveAddr = String(_local2.liveAddr);
            _local3 = String(_local2.msgAddr);
            this.liveUp = String(_local2.liveUp);
            this.liveDown = String(_local2.liveDown);
            this.backAddr = String(_local2.backAddr);
            _local3 = String(_local2.msgAddr);
            var _local4:* = _local3.split(",");
            this.host1 = _local4[0];
            this.host2 = _local4[1];
            this.delay = _local2.heartBeat;
            if (int(this.delay) == 0){
                this.delay = false;
            };
            var _local5:String = String(_local2.sockAddr);
            _local4 = _local5.split(":");
            this.chatHost = String(_local4[0]);
            this.chatPort = int(_local4[1]);
            this.testArr = String(_local2.testId).split(",");
            dispatchEvent(new Event("xmlLoaded"));
        }

    }
}//package com 
