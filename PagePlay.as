package  {

	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	
	public class PagePlay extends PageBase {
		
		public function PagePlay() {
		}

		//----------------------------
		// 以下、override必要
		//----------------------------
		public override function Start():void
		{
			GetMainClass().gotoAndStop("play");
			
			GetStage().addEventListener(MouseEvent.CLICK, OnClickTitleStartButton);
		}
		public override function End():void
		{
			GetStage().removeEventListener(MouseEvent.CLICK, OnClickTitleStartButton);
		}
		
		//----------------------------
		private function OnClickTitleStartButton(e:MouseEvent):void{
			SetNextPage(new PageEnding());
		}
	}
	
}
