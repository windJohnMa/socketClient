package com
{
	import flash.utils.ByteArray;
	
	public class UTFCode {

		public function UTFCode() {
			// constructor code
		}
		
		public function coding(str:String):String {
			var desArr:Array = new Array();
			var des:String = "";
			var tmpArr:ByteArray = new ByteArray();
			tmpArr.writeMultiByte(str, "unicode");
			tmpArr.position = 0;
			for (var j = 0; j < tmpArr.length; j++ ) {
				desArr.push(tmpArr.readUnsignedByte().toString(16));
			}
			des = utf16EnCode(desArr);
			trace("UTF-16: " + des);
			return des;
		}
		
		private function utf16EnCode(arr:Array):String {
			var targetStr:String = "";
			var num01:String = "";
			var num02:String = "";
			for (var i:int = 0; i < arr.length; i += 2 ) {
				//高位
				if (String(arr[i + 1]).length == 0) {
					num01 = "";
				}else if(String(arr[i + 1]).length == 1) {
					num01 = "0" + String(arr[i + 1]);
				}else {
					num01 = String(arr[i + 1]);
				}
				//低位
				if (String(arr[i]).length == 1) {
					num02 =  "0" + String(arr[i]);
				}else if (String(arr[i]).length == 0) {
					num02 = "";
				}else {
					num02  = String(arr[i]);
				}
				if (num01 != "" && num02 != "") {
					targetStr += String("\\u" +num01 + num02);
				}
			}
			return targetStr;
		}
		
		/*
		{"Time":"10:46", "Type":1, "FromID":"41310693", "FromName":"花子生", "FromNo":"0",
		"Random":0.8778314131777734, "ToID":0, "ToName":"", "ToNo":0, "Code":101, "Content":"[狂笑][狂笑]",
		"badges":"0","source":103}
		*/
		private var _st01:String = "FromName";
		private var _st02:String = "ToName";
		private	var _st03:String = "Content";
		//"Content":0,
		private var _content:String = "\"Content\":0,";
		private var _end01:String = ",\"FromNo";
		private var _end02:String = ",\"ToNo";
		private var _end03:String = ",\"badges";
		public function msgCode(str:String):String {
			var msg:String = str;
			msg = this.coding(str);
			return msg;
		}

	}
	
}
