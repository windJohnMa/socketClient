package com {

	import flash.display.BlendMode;
	import flash.utils.ByteArray;
	import flash.utils.Endian;
	import bmhBase.woo.Debug;
	import woo.Base64;
	/**
	* 服务器端返回的字节流缓冲池
	*/
	public class Buffer {
		
		private var _buffer:ByteArray;
		private var _obj:Object;

		public function Buffer(obj:Object) {
			_obj = obj;
			 _buffer = new ByteArray();
		}
  
		public function get bytesAvailable():uint {
			return _buffer == null ? 0 : _buffer.length;
		}
  
  
		/**
		* 将收到的字节流缓存到缓冲区
		* @param vBa:ByteArray 缓冲的字节流
		*@return
		*/
		public function cacheBytes(vBa:ByteArray):void {
			//trace("缓冲池剩余字节数......" + _buffer.length);
			vBa.position = 0;
			_buffer.position = 0;
			if(_buffer.length > 0){
				_buffer.position = _buffer.length;
			}
			
			_buffer.writeBytes(vBa,0,vBa.length);
			try{
				vBa.clear();
			}catch(e:Error){
				//trace("  1调用clear方法出错，可能是版本低于10。。。" + e.toString());
			}
			vBa = null;
			//trace("缓冲池中字节数 ----- " + _buffer.length);
		}
		
		/**
		* 将字节流分解成数据包
		* @return Array 解出来的数据包数组
		*/
		public function splitBufferToPackage():void {
	
			if(_buffer == null)
			return ;
			
			//从第一个字节开始读起
			_buffer.position = 0;
   
			//开始读取缓冲池
			if(_buffer.bytesAvailable > 0) {
			//循环读取里面的包
			while (true) {
				if(_buffer.bytesAvailable < 4)
				break;
     
				var totLen:int = _buffer.bytesAvailable; //剩余的总的长度
				var headMSG:ByteArray = new ByteArray();
				_buffer.readBytes(headMSG, 0, 4);
				var len:uint = uint((((headMSG[0] + (headMSG[1] = (headMSG[1] << 8))) + (headMSG[2] = (headMSG[2] << 16))) + (headMSG[3] = (headMSG[3] << 32))));
				trace("  读取一个包，包的长度   len: " + len + "   剩余长度：" + totLen);
				
				if (totLen >= len) {
					try {
						var msgData:String = _buffer.readUTFBytes(len);
						resolveMSG(msgData);
					}catch (e:Error) {
						Debug.trace("socketClient解包失败", "解包异常");
						var errMsg:String = "解包异常：" + e;
						_obj.catchErr(errMsg);
					}
				}else {
					//trace("  这不是一个完整的包，剩余的字节不够包的长度   len: " + len + "   剩余长度：" + totLen);
					//读取包长的时候，指针已经移动了，所以移回去
					if(_buffer.position >= 4)
					_buffer.position -= 4;
					break;
				}
			}
    
			//清空缓冲池中已经被读取的包的数据
			var leftbytes:uint = _buffer.bytesAvailable;
			//trace("  拆分包完毕，剩余的字节长度   len: " + leftbytes);
			if (leftbytes > 0) {
				//缓冲池中还有数据没有读取，则保留在缓冲池中，直到下次服务器端数据到达之后，触发读取
				var tmp:ByteArray = new ByteArray();
				_buffer.readBytes(tmp,0,leftbytes);
				//清楚缓冲区的字节
				try{
					_buffer.clear();
				}catch (e:Error) {
					trace("  2调用clear方法出错，可能是版本低于10。。。" + e.toString());
				}
     
				//将剩下的重新放回缓冲池
				_buffer = tmp;
				tmp = null;
				_buffer.position = 0;
			}else {
				//_buffer是空的了------
				//清楚缓冲区的字节-----
				try{
				_buffer.clear();
				}catch(e:Error){
					trace("  3调用clear方法出错，可能是版本低于10。。。" + e.toString());
				}
     
				_buffer = new ByteArray();
				_buffer.position = 0;
				}
			}
		}
		
		//分析数据
		//gift;46620d74-b5f3-3090-6827-d05699b1aa63|0|1,0:0:0|3154
		private var recNum:uint = 0;
		private function resolveMSG(receiveData:String):void {
			var headInfo:String = Base64.decode(receiveData);
			Debug.trace("socketClient报文信息", headInfo);
			//分析报文
			var packMsgArr:Array = headInfo.split(";");
			var msgType:String = packMsgArr[0];
			var msgString:* = packMsgArr[1];
			var numMSG:* = msgString.split("|");
			var streamNo:* = numMSG[0];
			var resultStatus:* = numMSG[1];
			var resultDescribe:* = numMSG[2];
			//组装数据
			var receiveInfo:String = "";
			var tagArr:Array
			if (msgType == "gift") {
				receiveInfo = ((((((("{" + "streamNo:\"") + streamNo) + "\",resultStatus:\"") + resultStatus) + "\",resultDescribe:\"") + resultDescribe) + "\"}");
			}else if (msgType == "tag") {
				tagArr  = resultDescribe.split(",");
				receiveInfo = ((((((((((((("{" + "streamNo:\"") + streamNo) + "\",resultStatus:\"") + resultStatus) + "\",giftId:\"") + tagArr[0]) + "\",giftName:\"") + tagArr[1]) + "\",receiverId:\"") + tagArr[2]) + "\",cmd:\"") + msgType) + "\"}");
			}else {
				tagArr  = resultDescribe.split(",");
				receiveInfo = ((((((((((((((((("{" + "streamNo:\"") + streamNo) + "\",resultStatus:\"") + resultStatus) + "\",giftid:\"") + tagArr[0]) + "\",giftname:\"") + tagArr[1]) + "\",giftnum:\"") + tagArr[2]) + "\",giftcoins:\"") + tagArr[3]) + "\",bocaiId:\"") + tagArr[4]) + "\",cmd:\"") + msgType) + "\"}");
			}
			//调用JS接口
			Debug.trace("socketClient组装信息", receiveInfo);
			recNum++;
			trace("***解析第" + recNum + "条数据***");
			trace("组装信息：" + receiveInfo);
			_obj.catchErr(receiveInfo);
			_obj.jsPostData(msgType, receiveInfo);
		}

	}
}