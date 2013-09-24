//Created by Action Script Viewer - http://www.buraks.com/asv
package com.core.netSpeedTest {
    import flash.events.*;
    import flash.net.*;

    public class netSpeedTest extends EventDispatcher {

        private var addr1:String;
        private var addr2:String;
        private var loader1:URLLoader;
        private var loader2:URLLoader;
        private var target;
        private var port:Number;

        public function netSpeedTest(_arg1, _arg2, _arg3) {
            this.target = _arg3;
            this.addr1 = (("http://" + _arg1) + "/config.html");
			trace("addr01: "+addr1);
            this.loader1 = new URLLoader();
            this.loader1.load(new URLRequest(this.addr1));
            this.loader1.addEventListener(Event.COMPLETE, this.loaded1);
            this.loader2 = new URLLoader();
            if (((!((_arg2 == null))) && (!((_arg2 == undefined))))){
                this.addr2 = (("http://" + _arg2) + "/config.html");
                this.loader2.load(new URLRequest(this.addr2));
                this.loader2.addEventListener(Event.COMPLETE, this.loaded2);
            };
        }
        private function loaded1(_arg1:Event){
            this.port = int(_arg1.currentTarget.data);
            dispatchEvent(new Event("checkOk"));
            this.target.checkok(0);
            try {
                this.loader1.close();
                this.loader2.close();
                this.loader1 = null;
                this.loader2 = null;
            } catch(e) {
            };
        }
        private function loaded2(_arg1:Event){
            this.port = int(_arg1.currentTarget.data);
            dispatchEvent(new Event("checkOk"));
            this.target.checkok(1);
            try {
                this.loader1.close();
                this.loader2.close();
                this.loader1 = null;
                this.loader2 = null;
            } catch(e) {
            };
        }
        public function get myport():Number{
            return (this.port);
        }

    }
}//package com.core.netSpeedTest 
