package {
	
	public class UtilityFunc {
		
		public function UtilityFunc() {
		}

		public static function xRandomInt (nMin, nMax) : int {
			// nMinからnMaxまでのランダムな整数を返す
			var nRandomInt = Math.floor(Math.random() * (nMax - nMin + 1)) + nMin; 
			return nRandomInt;
		}
		public static function Trace(str:String) : void {
			if(!Define.Release){
				trace(str);
			}
		}
	}
}