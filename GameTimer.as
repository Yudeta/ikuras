package{
	import flash.utils.getTimer;

	public class GameTimer{
		private var m_startTime:int = getTimer();
		private var m_stopTime:int;

		public function GameTimer() {
			Start();
		}

		public function Start():void {
			m_startTime = getTimer();
		}
		public function Stop():void {
			m_stopTime = getTimer();
		}
		public function Resume():void {
			var spaceTime:int = getTimer() - m_stopTime;
			m_startTime += spaceTime;
		}
		public function GetElapsedTime():int {
			var now:int = getTimer();
			return (now - m_startTime);
		}
    }
}