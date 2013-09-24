//Created by Action Script Viewer - http://www.buraks.com/asv
package main {
    import flash.display.*;
    import flash.utils.*;
    import flash.events.*;
    import woo.*;
    import bmhBase.woo.*;
    import com.information.*;
    import flash.net.*;
    import com.*;
    import flash.external.*;
    import flash.system.*;
	import com.UTFCode;

    public class socketClient extends Sprite {
		
		private var host0:String = "www.localhost.com";
		private var host1:String = "192.168.10.1";
		private var host2:String = "192.168.10.2";
		private var host3:String = "192.168.10.3";
        private var host4:String = "192.168.10.4";
	
        private var host;
        private var port;
		private var isUTF:uint = 0;
		private var utfCode:UTFCode;
		private var mySocket:Socket;
		private var byteBuffer:Buffer = new Buffer(this);
		
        public function socketClient() {
			Debug.trace("socketClient", "version：1.0.0");
			utfCode = new UTFCode();
            super();
            Security.allowDomain("*");
			this.addEventListener(Event.ADDED_TO_STAGE, addToStage);
            var userID:* = Params.getJSVar("Page.userID");
            if ((((((((int(userID) <= 0)) || ((userID == "null")))) || ((userID == null)))) || ((userID == "")))){
                this.init();
            } else {
                this.init();
            };
        }
		
		private function addToStage(e:Event):void {
			this.removeEventListener(Event.ADDED_TO_STAGE, addToStage);
			this.isUTF = int(stage.loaderInfo.parameters["isUTF"]);		  //通过参数传值
			Debug.trace("socketClient", "isUTF: " + isUTF);
		}
		
		
        private function init(){
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
			this.port = 8001;
			checkok(0);
        }
		
        public function checkok(stat:uint) {
            if (stat == 0){
                this.host = this.host0;
            } else {
                this.host = this.host1;
            };
            Debug.trace("socketClient", ("选择host:" + this.host));
            trace(this.host, this.port);
            this.mySocket = new Socket();
            this.connectToServer();	//连接Socket服务器
            this.mySocket.addEventListener(Event.CONNECT, this.conn);
			this.mySocket.addEventListener(Event.CLOSE, this.socketClose);
            this.mySocket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, this.securityFunc);
			this.mySocket.addEventListener(ProgressEvent.SOCKET_DATA, recSocketData);
            this.mySocket.addEventListener(IOErrorEvent.IO_ERROR, this.errorFunc);
        }
		
		private function socketClose(evt:Event):void {
			Debug.trace("socketClient: ", "服务器断开SOCKET连接");
			catchErr("服务器断开SOCKET连接");
			reConnection();
		}
		
		private function reConnection():void {
			switch(host) {
				case host1:
					host = host2;
					break;
				case host2:
					host = host3;
					break;
				case host3:
					host = host4;
					break;
				case host4:
					host = host1;
					break;
				default:
					host = host1;
			}
			trace("重新连接");
			try {
				trace(mySocket.connected);
				mySocket.close();
				Security.loadPolicyFile("live.baomihua.com/crossdomain.xml");
				mySocket.connect(host, port);
				trace(((("i'm connecting to:" + this.host) + ":") + this.port));
			}catch (e:Error) {
				trace("错误" + e.message);
				catchErr("重连出错" + e);
			}
		}
		
		private var checkLink:Boolean = true;
        private function conn(evt:Event){
            ExternalInterface.addCallback("sendMsg", this.sendMsg);
            Debug.trace("socketClient", "连接成功,注册方法sendMsg");
			Debug.trace("socketClient", "连接状态" + mySocket.connected);
			trace("连接状态： " + mySocket.connected);
			if (checkLink) {
				checkLink = false;
				addEventListener(Event.ENTER_FRAME, checkHandler);
			}
        }
		
		//连接状态监测
		private function checkHandler(evt:Event):void {
			if (mySocket.connected == false) {
				this.reConnection();
			}
		}
		
        private function connectToServer(){
            Security.loadPolicyFile("live.baomihua.com/crossdomain.xml");
            try {
                trace(((("i'm connecting to:" + this.host) + ":") + this.port));
                Debug.trace("socketClient", ((("i'm connecting to:" + this.host) + ":") + this.port));
                this.mySocket.connect(this.host, this.port);
            } catch(e) {
                ExternalInterface.call("receiveMsg", "error", "socket连接服务器失败,IO错误");
				catchErr("连接服务器失败" + e);
            };
        }
        private function securityFunc(evt:SecurityErrorEvent){
            Debug.trace("socketClient", "安全沙箱错误");
			catchErr("发生安全沙箱错误");
            trace("安全沙箱错误！");
			reConnection();
        }
        private function errorFunc(evt:IOErrorEvent){
            Debug.sendTrace("socketClient", ("I/O错误—" + evt.text), 1);
			catchErr("发生I/O错误");
            var errType:* = "error";
            var errMsg:* = "连接服务器失败！发生I/O错误";
			reConnection();
            ExternalInterface.call("receiveMsg", errType, errMsg);
        }
		
		//读取信息
		private var rendLne:uint = 0;
		private var rendNum:uint = 0;
		private function recSocketData(e:ProgressEvent):void {
			//从Socket中读取数据
			rendLne += this.mySocket.bytesAvailable;
			rendNum++;
			trace("××××××第" + rendNum + "次读取数据××××××");
			trace("可读长度：" + this.mySocket.bytesAvailable);
			trace("总长度：" + this.rendLne);
			var buffLen:int = this.mySocket.bytesAvailable;
			try {
				if (this.mySocket.bytesAvailable > 0 ) {
					trace("读取数据中...")
					var byte:ByteArray = new ByteArray();
					this.mySocket.readBytes(byte, 0, buffLen);
					byteBuffer.cacheBytes(byte);
				}
			}catch (e:Error) {
				trace("接收数据出错：" + e);
				catchErr("接受数据出错: " + e);
			}
			trace("缓冲池数据：" + this.byteBuffer.bytesAvailable);
			this.byteBuffer.splitBufferToPackage();
		}
		
		//发送消息
		private  var sendNum:uint = 0;
        public function sendMsg(msg:String){
            Debug.trace("socketClient发送数据", msg);
            ExternalInterface.call("ProcessWatch.writeLine(\"socket发送请求到扣费服务\")");
            if (this.mySocket.connected){
            } else {
				connectToServer();
				trace("未连接成功");
				return;
            };
            trace(("发送：" + msg));
            var baseMsg:String = Base64.encode(msg);
            var msgArr:ByteArray = new ByteArray();
            msgArr.writeUTF(baseMsg);
			//写入消息
            var socketMsg:ByteArray = new ByteArray();
            socketMsg.writeInt(int(msgArr.length));	//写入长度
            socketMsg.writeUTF(baseMsg);			//写入消息
            this.mySocket.writeBytes(socketMsg);
            this.mySocket.flush();
			sendNum++;
			trace("×××发送第" + sendNum + "条数据×××");
        }
		
		//调用JS
		public function jsPostData(msgType:String, receiveInfo:String):void {
			if (this.isUTF == 1) {
				var utfMSG:String = utfCode.msgCode(receiveInfo);
				Debug.trace("socketClient编码信息", utfMSG);
				ExternalInterface.call("receiveMsg", msgType, utfMSG);
			}else {
				ExternalInterface.call("receiveMsg", msgType, receiveInfo);
			}
		}
		
		//信息提交接口
		private var errURL:String = "http://datacollection.show.baomihua.com/Gateway.ashx?action=live.log.command&des=";
		private var errLoader:URLLoader;
		private var errRe:URLRequest;
		public function catchErr(str:String):void {
			try {
				var URLMsg:String = errURL + str;
				errRe = new URLRequest(URLMsg);
				errLoader = new URLLoader();
				errLoader.load(errRe);
				trace("调用接口");
			}catch (e) {
				trace("发生异常");
				trace(e);
				Debug.trace("socketClient", "XXXX连接日志出错XXXX");
			}
		}

    }
}
