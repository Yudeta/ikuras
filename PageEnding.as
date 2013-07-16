package  {

	import flash.display.MovieClip;
	import flash.events.MouseEvent;
	
	
	public class PageEnding extends PageBase {
		
		public function PageEnding() {
		}

		//----------------------------
		// 以下、override必要
		//----------------------------
		public override function Start():void
		{
			GetMainClass().gotoAndStop("ending");
			
			GetStage().addEventListener(MouseEvent.CLICK, OnClickTitleStartButton);
		}
		public override function End():void
		{
			GetStage().removeEventListener(MouseEvent.CLICK, OnClickTitleStartButton);
		}
		
		//----------------------------
		private function OnClickTitleStartButton(e:MouseEvent):void{
			SetNextPage(new PageTitle());
		}
	}
	
}
