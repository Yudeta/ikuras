package  {

	import flash.display.MovieClip;
	import flash.display.Sprite;
	import flash.display.Stage;
	
	
	public class PageBase extends Sprite {
		
		private var m_stage:Stage = null;
		private var m_mainClass:MovieClip = null;
		
		public function PageBase() {
		}

		public function SetMainClass(mainClass:MovieClip):void{
			m_mainClass = mainClass;
		}
		public function SetStage(_stage:Stage):void{
			// SunSequenceはaddChildされていないのでstage==nullになっている。なので使うためにはstageを渡す必要がある。
			m_stage = _stage;
		}
		protected function GetMainClass():MovieClip{
			return m_mainClass;
		}
		protected function GetStage():Stage{
			return m_stage;
		}
		protected function SetNextPage(page:PageBase){
			m_mainClass.SetNextPage(page);
		}
		
		
		//----------------------------
		// 以下、override必要
		//----------------------------
		public function Start():void
		{
		}
		public function End():void
		{
		}
		
	}
	
}
